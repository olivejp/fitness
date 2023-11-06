import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnc_user/service/fitness-user.service.dart';
import 'package:fitnc_user/service/ref-exercice.service.dart';
import 'package:fitness_domain/domain/exercice.domain.dart';
import 'package:fitness_domain/service/abstract.service.dart';
import 'package:fitness_domain/service/auth.service.dart';
import 'package:get_it/get_it.dart';

class ExerciceService extends AbstractFitnessStorageService<Exercice> {
  final FitnessUserService fitnessUserService = GetIt.I.get();
  final AuthService authService = GetIt.I.get();
  final RefExerciceService refExerciceService = GetIt.I.get();
  final List<Exercice> _listExercice = [];
  StreamSubscription? str1;
  StreamSubscription? str2;

  @override
  Exercice fromJson(Map<String, dynamic> map) {
    return Exercice.fromJson(map);
  }

  @override
  Stream<List<Exercice>> listenAll() {
    return fitnessUserService.listenMyExercices();
  }

  @override
  CollectionReference<Object?> getCollectionReference() {
    return fitnessUserService.getMyExerciceReference();
  }

  @override
  String getStorageRef(User user, Exercice domain) {
    return 'users/${user.uid}/exercices/${domain.uid}/mainImage';
  }

  Stream<List<Exercice>> listenAllAndRef() {
    final StreamController<List<Exercice>> streamController = StreamController();

    streamController.onCancel = () {
      str1?.cancel();
      str2?.cancel();
    };

    str1 = refExerciceService.listenAll().listen((listRefExercice) {
      _listExercice.removeWhere((element) => element.origin == 'REF');
      _listExercice.addAll(listRefExercice);
      _listExercice.sort((a, b) => a.name.compareTo(b.name));
      streamController.sink.add(_listExercice);
    });

    str2 = fitnessUserService.listenMyExercices().listen((listExercice) {
      _listExercice.removeWhere((element) => element.origin != 'REF');
      _listExercice.addAll(listExercice);
      _listExercice.sort((a, b) => a.name.compareTo(b.name));
      streamController.sink.add(_listExercice);
    });

    return streamController.stream;
  }

  String getExerciceStoragePath(Exercice exercice) {
    User user = AuthService.getUserConnectedOrThrow();
    return 'users/${user.uid}/exercices/${exercice.uid}/mainImage';
  }
}
