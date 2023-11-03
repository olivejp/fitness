import 'package:fitnc_user/service/exercice.service.dart';
import 'package:fitness_domain/domain/exercice.domain.dart';
import 'package:fitness_domain/domain/storage-file.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class ExerciseDetailPageNotifier extends ChangeNotifier {
  final ExerciceService exerciseService = GetIt.I.get();

  Exercice exercise = Exercice();

  void init(Exercice? exercise) {
    if (exercise == null) {
      this.exercise = Exercice();
    } else {
      this.exercise = exercise;
    }
  }

  Future<void> save() {
    return exerciseService.save(exercise);
  }

  void setStoragePair(StorageFile? storageFile) {
    exercise.storageFile = storageFile;
    notifyListeners();
  }

  void setGroup(String? value) {
    exercise.group = value;
    notifyListeners();
  }
}
