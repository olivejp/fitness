import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnc_user/service/fitness-user.service.dart';
import 'package:fitnc_user/di.dart';
import 'package:fitnc_user/domain/workout-instance.domain.dart';
import 'package:fitnc_user/service/abstract.service.dart';
import 'package:fitnc_user/service/auth.service.dart';

class WorkoutInstanceService extends AbstractFitnessStorageService<WorkoutInstance> {
  final FitnessUserService fitnessUserService = di<FitnessUserService>();
  final AuthService authService = di<AuthService>();

  Stream<List<WorkoutInstance>> listenByDate(DateTime dateTime) {
    DateTime dateMinus = DateTime(dateTime.year, dateTime.month, dateTime.day);
    DateTime dateMax = DateTime(dateTime.year, dateTime.month, dateTime.day, 23, 59, 59);
    return whereListen(
      'date',
      isGreaterThanOrEqualTo: dateMinus.millisecondsSinceEpoch,
      isLessThanOrEqualTo: dateMax.millisecondsSinceEpoch,
    );
  }

  String getWorkoutStoragePath(WorkoutInstance workout) {
    User user = AuthService.getUserConnectedOrThrow();
    return 'users/${user.uid}/workouts/${workout.uid}/mainImage';
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
}
