// import 'package:charts_flutter/flutter.dart' as charts;
// import 'package:charts_flutter/flutter.dart';
import 'package:fitnc_user/service/user-set.service.dart';
import 'package:fitnc_user/service/workout-instance.service.dart';
import 'package:fitness_domain/domain/user.line.domain.dart';
import 'package:fitness_domain/domain/user.set.domain.dart';
import 'package:fitness_domain/domain/workout-instance.domain.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
  final Rx<Tuple2<String, DateTime>> dateSelected = Tuple2('', DateTime.now()).obs;
  final Rx<TypeChart> typeChart = TypeChart.volume.obs;
  final Rx<UserSet> selectedUserSet = UserSet().obs;

  Future<List<UserSet>> getAllUserSetByExercice(String exerciceUid) {
    return userSetService.getForExercice(exerciceUid);
  }

  Future<WorkoutInstance?> getWorkoutInstance(String uidWorkout) {
    return workoutInstanceService.read(uidWorkout);
  }
  //
  // List<charts.Series<TimeSeries, DateTime>> toChartSeries(String exerciceUid, List<TimeSeries> data) {
  //   data.sort((a, b) => a.time.compareTo(b.time));
  //   return [
  //     charts.Series<TimeSeries, DateTime>(
  //       id: exerciceUid,
  //       colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
  //       domainFn: (TimeSeries sales, _) => sales.time,
  //       measureFn: (TimeSeries sales, _) => sales.total,
  //       data: data,
  //     )
  //   ];
  // }

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

// List<charts.Series<TimeSeries, DateTime>> getWorkoutVolume(List<UserSet> listUserSet, Exercice exercice) {
//   if (listUserSet.isEmpty) {
//     return [];
//   }
//
//   final String exerciceUid = exercice.uid!;
//   final data = <TimeSeries>[];
//   for (UserSet userSet in listUserSet) {
//     data.add(TimeSeries<UserSet>(userSet.date!, getVolume(userSet), userSet));
//   }
//
//   return toChartSeries(exerciceUid, data);
// }

// List<charts.Series<TimeSeries, DateTime>> getWorkoutMaxReps(List<UserSet> listUserSet, Exercice exercice) {
//   if (listUserSet.isEmpty) {
//     return [];
//   }
//
//   final String exerciceUid = exercice.uid!;
//   final data = <TimeSeries>[];
//   for (UserSet userSet in listUserSet) {
//     data.add(TimeSeries<UserSet>(userSet.date!, getMaxReps(userSet), userSet));
//   }
//
//   return toChartSeries(exerciceUid, data);
// }

// List<charts.Series<TimeSeries, DateTime>> getWorkoutMaxWeight(List<UserSet> listUserSet, Exercice exercice) {
//   if (listUserSet.isEmpty) {
//     return [];
//   }
//
//   final String exerciceUid = exercice.uid!;
//   final data = <TimeSeries>[];
//   for (UserSet userSet in listUserSet) {
//     data.add(TimeSeries<UserSet>(userSet.date!, getMaxWeight(userSet), userSet));
//   }
//
//   return toChartSeries(exerciceUid, data);
// }
}
