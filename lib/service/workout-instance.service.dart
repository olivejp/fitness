import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnc_user/service/fitness-user.service.dart';
import 'package:fitness_domain/domain/workout-instance.domain.dart';
import 'package:fitness_domain/service/abstract.service.dart';
import 'package:fitness_domain/service/auth.service.dart';
import 'package:get/get.dart';

class WorkoutInstanceService extends AbstractFitnessStorageService<WorkoutInstance> {
  final FitnessUserService fitnessUserService = Get.find();
  final AuthService authService = Get.find();

  Stream<List<WorkoutInstance>> listenByDate(DateTime dateTime) {
    DateTime dateMinus = DateTime(dateTime.year, dateTime.month, dateTime.day);
    DateTime dateMax = DateTime(dateTime.year, dateTime.month, dateTime.day, 23, 59, 59);
    return getCollectionReference()
        .where('date', isGreaterThanOrEqualTo: dateMinus.millisecondsSinceEpoch, isLessThanOrEqualTo: dateMax.millisecondsSinceEpoch)
        .snapshots()
        .map((event) => event.docs.map((e) => WorkoutInstance.fromJson(e.data() as Map<String, dynamic>)).toList());
  }

  @override
  WorkoutInstance fromJson(Map<String, dynamic> map) {
    return WorkoutInstance.fromJson(map);
  }

  @override
  Stream<List<WorkoutInstance>> listenAll() {
    return fitnessUserService.listenMyWorkoutInstance();
  }

  @override
  CollectionReference<Object?> getCollectionReference() {
    return fitnessUserService.getMyWorkoutInstanceReference();
  }

  @override
  String getStorageRef(User user, WorkoutInstance domain) {
    return 'trainers/${user.uid}/workouts/${domain.uid}/mainImage';
  }

  String getWorkoutStoragePath(WorkoutInstance workout) {
    final User? user = authService.getCurrentUser();
    if (user == null) throw Exception('Aucun utilisateur connecté');
    return 'users/${user.uid}/workouts/${workout.uid}/mainImage';
  }
}
