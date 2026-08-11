import 'package:fitnc_user/di.dart';
import 'package:fitnc_user/domain/exercice.domain.dart';
import 'package:fitnc_user/domain/storage-file.domain.dart';
import 'package:fitnc_user/service/exercice.service.dart';
import 'package:flutter/foundation.dart';

class AddExerciseNotifier extends ChangeNotifier {
  AddExerciseNotifier(Exercice? initial) {
    exercise = ValueNotifier<Exercice>(initial ?? Exercice());
  }

  final ExerciceService exerciseService = di<ExerciceService>();

  late final ValueNotifier<Exercice> exercise;

  @override
  void dispose() {
    exercise.dispose();
    super.dispose();
  }

  Future<void> save() {
    return exerciseService.save(exercise.value);
  }

  void setStoragePair(StorageFile? storageFile) {
    exercise.value.storageFile = storageFile;
    // L'objet est muté sur place : ValueNotifier ne notifie que sur changement
    // de référence, il faut donc forcer.
    exercise.notifyListeners();
  }
}
