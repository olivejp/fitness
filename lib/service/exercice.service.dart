import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnc_user/service/fitness-user.service.dart';
import 'package:fitness_domain/domain/exercice.domain.dart';
import 'package:fitness_domain/service/abstract.service.dart';
import 'package:fitness_domain/service/auth.service.dart';
import 'package:get/get.dart';

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
  String getStorageRef(User user, Exercice domain) {
    return 'trainers/${user.uid}/exercices/${domain.uid}/mainImage';
  }

  String getExerciceStoragePath(Exercice exercice) {
    User user = AuthService.getUserConnectedOrThrow();
    return 'users/${user.uid}/exercices/${exercice.uid}/mainImage';
  }
}
