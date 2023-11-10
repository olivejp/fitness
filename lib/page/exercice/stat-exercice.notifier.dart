// import 'package:charts_flutter/flutter.dart' as charts;
// import 'package:charts_flutter/flutter.dart';
import 'package:fitnc_user/service/user-set.service.dart';
import 'package:fitnc_user/service/workout-instance.service.dart';
import 'package:fitness_domain/domain/user.line.domain.dart';
import 'package:fitness_domain/domain/user.set.domain.dart';
import 'package:fitness_domain/domain/workout-instance.domain.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:tuple/tuple.dart';

enum TypeChart {
  volume,
  reps,
  weight,
}

/// Controller
class StatExercicePageNotifier extends ChangeNotifier {
  final UserSetService userSetService = GetIt.I.get();
  final WorkoutInstanceService workoutInstanceService = GetIt.I.get();

  Tuple2<String, DateTime> _dateSelected = Tuple2('', DateTime.now());
  UserSet _selectedUserSet = UserSet();
  TypeChart _typeChart = TypeChart.volume;

  TypeChart get typeChart => _typeChart;

  UserSet get selectedUserSet => _selectedUserSet;

  Tuple2<String, DateTime> get dateSelected => _dateSelected;

  set typeChart(TypeChart origin) {
    _typeChart = origin;
    notifyListeners();
  }

  set selectedUserSet(UserSet userSet) {
    _selectedUserSet = userSet;
    notifyListeners();
  }

  set dateSelected(Tuple2<String, DateTime> tuple) {
    _dateSelected = tuple;
    notifyListeners();
  }

  Future<List<UserSet>> getAllUserSetByExercice(String exerciceUid) {
    return userSetService.getForExercice(exerciceUid);
  }

  Future<WorkoutInstance?> getWorkoutInstance(String uidWorkout) {
    return workoutInstanceService.read(uidWorkout);
  }

  int getVolume(UserSet userSet) {
    int volume = 0;
    if (userSet.lines.isNotEmpty) {
      for (UserLine userLine in userSet.lines) {
        if (userLine.weight != null && userLine.reps != null) {
          volume += int.parse(userLine.weight!) * int.parse(userLine.reps!);
        }
      }
    }
    return volume;
  }

  int getMaxReps(UserSet userSet) {
    int maxReps = 0;
    if (userSet.lines.isNotEmpty) {
      for (UserLine userLine in userSet.lines) {
        if (userLine.reps != null) {
          int userLineReps = int.parse(userLine.reps!);
          maxReps = (userLineReps > maxReps) ? userLineReps : maxReps;
        }
      }
    }
    return maxReps;
  }

  int getMaxWeight(UserSet userSet) {
    int maxWeight = 0;
    if (userSet.lines.isNotEmpty) {
      for (UserLine userLine in userSet.lines) {
        if (userLine.weight != null) {
          int userLineReps = int.parse(userLine.weight!);
          maxWeight = (userLineReps > maxWeight) ? userLineReps : maxWeight;
        }
      }
    }
    return maxWeight;
  }
}
