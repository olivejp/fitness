import 'package:fitnc_user/enum/muscular_group.dart';
import 'package:fitnc_user/service/exercise.service.dart';
import 'package:fitness_domain/domain/exercise.domain.dart';
import 'package:fitness_domain/domain/storage-file.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class ExerciseDetailPageNotifier extends ChangeNotifier {
  final ExerciseService exerciseService = GetIt.I.get();

  Exercise exercise = Exercise();

  void init(Exercise? exercise, Stream<List<MuscularGroup>> stream) {
    if (exercise == null) {
      this.exercise = Exercise();
    } else {
      this.exercise = exercise;
    }

    stream.listen((event) {
      this.exercise.group = event.map((e) => e.name).toList();
      notifyListeners();
    });
  }

  Future<void> save() {
    if (exercise.origin == null || exercise.origin != 'REF') {
      return exerciseService.save(exercise);
    }
    return Future.value();
  }

  void setStoragePair(StorageFile? storageFile) {
    if (exercise.origin == null || exercise.origin != 'REF') {
      exercise.storageFile = storageFile;
      notifyListeners();
    }
  }

  void setGroup(List<String> value) {
    if (exercise.origin == null || exercise.origin != 'REF') {
      exercise.group = value;
      notifyListeners();
    }
  }
}
