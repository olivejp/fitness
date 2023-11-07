import 'package:fitnc_user/service/exercice.service.dart';
import 'package:fitnc_user/service/muscular_group.service.dart';
import 'package:fitness_domain/domain/exercice.domain.dart';
import 'package:fitness_domain/domain/storage-file.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class ExerciseDetailPageNotifier extends ChangeNotifier {
  final ExerciceService exerciseService = GetIt.I.get();

  Exercice exercise = Exercice();

  void init(Exercice? exercise, Stream<List<MuscularGroup>> stream) {
    if (exercise == null) {
      this.exercise = Exercice();
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
