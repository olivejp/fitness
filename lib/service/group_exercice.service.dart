import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnc_user/service/fitness-user.service.dart';
import 'package:fitness_domain/domain/group_exercice.domain.dart';
import 'package:fitness_domain/service/abstract.service.dart';
import 'package:fitness_domain/service/auth.service.dart';
import 'package:get_it/get_it.dart';

class GroupExerciceService extends AbstractFitnessStorageService<GroupExercice> {
  final FitnessUserService fitnessUserService = GetIt.I.get();
  final AuthService authService = GetIt.I.get();

  @override
  GroupExercice fromJson(Map<String, dynamic> map) {
    return GroupExercice.fromJson(map);
  }

  @override
  Stream<List<GroupExercice>> listenAll() {
    return fitnessUserService.listenMyGroupExercices();
  }

  @override
  CollectionReference<Object?> getCollectionReference() {
    return fitnessUserService.getMyGroupExerciceReference();
  }

  @override
  String getStorageRef(User user, GroupExercice domain) {
    return 'users/${user.uid}/group_exercices/${domain.uid}/mainImage';
  }
}
