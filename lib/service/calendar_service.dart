import 'package:fitnc_user/page/exercice/exercice-choice.dialog.dart';
import 'package:fitnc_user/widget/workout_type_choice.widget.dart';
import 'package:fitness_domain/domain/workout-instance.domain.dart';
import 'package:fitness_domain/enum/type_workout.enum.dart';
import 'package:flutter/material.dart';

class WorkoutUtility {
  static void goToWorkoutTypeChoice({
    required BuildContext context,
    required TypeWorkoutTapCallback onTypeWorkoutChoice,
  }) {
    showDialog(
      context: context,
      useRootNavigator: true,
      builder: (context) => AlertDialog(
        contentPadding: EdgeInsets.zero,
        content: WorkoutTypeChoice(onTap: onTypeWorkoutChoice),
      ),
    );
  }

  static void goToExerciseChoiceDialog({
    required BuildContext context,
    DateTime? dateTime,
    WorkoutInstance? workoutInstance,
    bool isCreation = false,
    bool popOnChoice = false,
    TypeWorkout? typeWorkout,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ExerciseChoiceDialog(
          isCreation: isCreation,
          date: dateTime,
          workoutInstance: workoutInstance,
          popOnChoice: popOnChoice,
          typeWorkout: typeWorkout,
        ),
      ),
    );
  }
}
