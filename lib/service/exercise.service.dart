import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnc_user/service/fitness-user.service.dart';
import 'package:fitnc_user/service/ref-exercise.service.dart';
import 'package:fitnc_user/service/user-set.service.dart';
import 'package:fitnc_user/service/workout-instance.service.dart';
import 'package:fitness_domain/domain/exercise.domain.dart';
import 'package:fitness_domain/domain/user.set.domain.dart';
import 'package:fitness_domain/domain/workout-instance.domain.dart';
import 'package:fitness_domain/service/abstract.service.dart';
import 'package:fitness_domain/service/auth.service.dart';
import 'package:get_it/get_it.dart';

class ExerciseService extends AbstractFitnessStorageService<Exercise> {
  final FitnessUserService fitnessUserService = GetIt.I.get();
  final AuthService authService = GetIt.I.get();
  final RefExerciseService refExerciseService = GetIt.I.get();
  final WorkoutInstanceService workoutInstanceService = GetIt.I.get();
  final UserSetService userSetService = GetIt.I.get();
  final List<Exercise> _listExercise = [];
  StreamSubscription? str1;
  StreamSubscription? str2;

  @override
  Exercise fromJson(Map<String, dynamic> map) {
    return Exercise.fromJson(map);
  }

  @override
  Stream<List<Exercise>> listenAll() {
    return fitnessUserService.listenMyExercises();
  }

  @override
  CollectionReference<Object?> getCollectionReference() {
    return fitnessUserService.getMyExerciseReference();
  }

  @override
  String getStorageRef(User user, Exercise domain) {
    return 'users/${user.uid}/exercices/${domain.uid}/mainImage';
  }

  Stream<List<Exercise>> listenAllAndRef() {
    final StreamController<List<Exercise>> streamController = StreamController();

    streamController.onCancel = () {
      str1?.cancel();
      str2?.cancel();
    };

    str1 = refExerciseService.listenAll().listen((listRefExercise) {
      _listExercise.removeWhere((element) => element.origin == 'REF');
      _listExercise.addAll(listRefExercise);
      _listExercise.sort((a, b) => a.name.compareTo(b.name));
      streamController.sink.add(_listExercise);
    });

    str2 = fitnessUserService.listenMyExercises().listen((listExercise) {
      _listExercise.removeWhere((element) => element.origin != 'REF');
      _listExercise.addAll(listExercise);
      _listExercise.sort((a, b) => a.name.compareTo(b.name));
      streamController.sink.add(_listExercise);
    });

    return streamController.stream;
  }

  String getExerciseStoragePath(Exercise exercice) {
    User user = AuthService.getUserConnectedOrThrow();
    return 'users/${user.uid}/exercices/${exercice.uid}/mainImage';
  }

  @override
  Future<void> delete(Exercise domain) async {
    // Can't delete exercise if referenced into an userSet.
    List<WorkoutInstance> listWorkoutInstance = await workoutInstanceService.getAll();
    for (var workoutInstance in listWorkoutInstance) {
      String? rootDomainUid = workoutInstance.uid;
      if (rootDomainUid != null) {
        List<UserSet> listUserSet = await userSetService.getAll(rootDomainUid);
        for (var userSet in listUserSet) {
          if (userSet.uidExercise == domain.uid) {
            return Future.error('exerciseUsedInUserSet');
          }
        }
      }
    }
    return super.delete(domain);
  }
}
