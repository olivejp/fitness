import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnc_user/service/fitness-user.service.dart';
import 'package:fitnc_user/service/workout-instance.service.dart';
import 'package:fitness_domain/domain/user.set.domain.dart';
import 'package:fitness_domain/domain/workout-instance.domain.dart';
import 'package:fitness_domain/service/abstract.service.dart';
import 'package:fitness_domain/service/auth.service.dart';
import 'package:get/get.dart';

class UserSetService extends AbstractFirebaseSubcollectionCrudService<UserSet, WorkoutInstance, WorkoutInstanceService> {
  final String collectionName = 'userSet';

  @override
  UserSet fromJson(Map<String, dynamic> map) {
    return UserSet.fromJson(map);
  }

  @override
  String getCollectionName() {
    return collectionName;
  }
}
