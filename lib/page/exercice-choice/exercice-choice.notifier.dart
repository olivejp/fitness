import 'package:fitnc_user/di.dart';
import 'package:fitnc_user/domain/exercice.domain.dart';
import 'package:fitnc_user/domain/user-set.domain.dart';
import 'package:fitnc_user/domain/workout-instance.domain.dart';
import 'package:fitnc_user/mixin/search.mixin.dart';
import 'package:fitnc_user/page/workout-instance/workout-instance.page.dart';
import 'package:fitnc_user/service/exercice.service.dart';
import 'package:fitnc_user/service/user-set.service.dart';
import 'package:fitnc_user/service/workout-instance.service.dart';
import 'package:flutter/material.dart';

class ExerciseChoiceNotifier extends ChangeNotifier
    with SearchMixin<Exercice> {
  ExerciseChoiceNotifier() {
    initSearchList(getStreamList: service.listenAll);
  }

  final ExerciceService service = di<ExerciceService>();
  final UserSetService userSetService = di<UserSetService>();
  final WorkoutInstanceService workoutInstanceService = di<WorkoutInstanceService>();
  final ValueNotifier<List<Exercice>> listChosen =
      ValueNotifier<List<Exercice>>(<Exercice>[]);

  @override
  void dispose() {
    listChosen.dispose();
    super.dispose();
  }

  Future<WorkoutInstance> createNewWorkoutInstance(DateTime dateTime) async {
    DateTime now = DateTime.now();
    WorkoutInstance instance = WorkoutInstance();
    instance.date = DateTime(
      dateTime.year,
      dateTime.month,
      dateTime.day,
      now.hour,
      now.minute,
      now.second,
    );
    workoutInstanceService.create(instance);
    return instance;
  }

  Stream<List<Exercice>> listenAllExercise() {
    return service.listenAll();
  }

  bool isChosen(Exercice exercise) {
    return listChosen.value
        .any((Exercice element) => element.uid == exercise.uid);
  }

  void toggle(Exercice exercise) {
    final List<Exercice> updated = List<Exercice>.of(listChosen.value);
    if (isChosen(exercise)) {
      updated.removeWhere((Exercice element) => element.uid == exercise.uid);
    } else {
      updated.add(exercise);
    }
    listChosen.value = updated;
  }

  void validate(
    BuildContext context,
    bool popOnChoice,
    WorkoutInstance workoutInstance,
    VoidCallback? onValidated,
  ) {
    _addUserSet(workoutInstance).then(
      (userSet) {
        if (popOnChoice) {
          // Ouvert depuis la séance : c'est elle qui fournit de quoi se
          // rafraîchir. Ouvert depuis le calendrier, il n'y a rien à notifier.
          onValidated?.call();
          Navigator.of(context).pop();
        } else {
          Navigator.of(context).pop();
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => WorkoutPage(
                instance: workoutInstance,
                goToLastPage: true,
              ),
            ),
          );
        }
      },
    );
  }

  Future<void> _addUserSet(WorkoutInstance workoutInstance) async {
    for (Exercice exercise in listChosen.value) {
      final UserSet userSet = UserSet(
          uidExercice: exercise.uid!,
          uidWorkout: workoutInstance.uid!,
          nameExercice: exercise.name,
          imageUrlExercice: exercise.imageUrl,
          typeExercice: exercise.typeExercice,
          date: workoutInstance.date);
      userSetService.save(userSet);
    }
  }
}
