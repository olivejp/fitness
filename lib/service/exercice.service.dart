import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnc_user/service/fitness-user.service.dart';
import 'package:fitness_domain/domain/exercice.domain.dart';
import 'package:fitness_domain/service/abstract.service.dart';
import 'package:fitness_domain/service/auth.service.dart';
import 'package:get/get.dart';

abstract class ChildFirestoreCollectionService<U extends AbstractFirebaseCrudService> extends AbstractFitnessStorageService<Exercice> {
  U parentService = Get.find();
}

class ExerciceService extends AbstractFitnessStorageService<Exercice> {
  final FitnessUserService fitnessUserService = Get.find();
  final AuthService authService = Get.find();

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
  String getStorageRef(User user, Exercice exercice) {
    return 'trainers/${user.uid}/exercices/${exercice.uid}/mainImage';
  }

  String getExerciceStoragePath(Exercice exercice) {
    final User? user = authService.getCurrentUser();
    if (user == null) throw Exception('Aucun utilisateur connecté');
    return 'users/${user.uid}/exercices/${exercice.uid}/mainImage';
  }
}
