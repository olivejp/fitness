import 'package:fitnc_user/service/exercice.service.dart';
import 'package:fitness_domain/domain/exercice.domain.dart';
import 'package:fitness_domain/domain/storage-file.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';

class AddExercisePageNotifier extends ChangeNotifier {
  final ExerciceService exerciseService = GetIt.I.get();

  final Rx<Exercice> exercise = Exercice().obs;

  void init(Exercice? exercise) {
    if (exercise == null) {
      this.exercise.value = Exercice();
    } else {
      this.exercise.value = exercise;
    }
  }

  Future<void> save() {
    return exerciseService.save(exercise.value);
  }

  void setStoragePair(StorageFile? storageFile) {
    exercise.update((val) {
      if (val != null) {
        val.storageFile = storageFile;
      }
    });
  }
}
