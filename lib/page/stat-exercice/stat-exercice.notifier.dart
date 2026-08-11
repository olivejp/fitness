import 'package:community_charts_flutter/community_charts_flutter.dart' as charts;
import 'package:fitnc_user/di.dart';
import 'package:fitnc_user/domain/exercice.domain.dart';
import 'package:fitnc_user/domain/user-line.domain.dart';
import 'package:fitnc_user/domain/user-set.domain.dart';
import 'package:fitnc_user/domain/workout-instance.domain.dart';
import 'package:fitnc_user/service/user-set.service.dart';
import 'package:fitnc_user/service/workout-instance.service.dart';
import 'package:fitnc_user/widget/time-series-chart.widget.dart';
import 'package:flutter/foundation.dart';
import 'package:tuple/tuple.dart';

enum TypeChart {
  volume,
  reps,
  weight,
}

class StatExerciceNotifier extends ChangeNotifier {
  final UserSetService userSetService = di<UserSetService>();
  final WorkoutInstanceService workoutInstanceService = di<WorkoutInstanceService>();
  final ValueNotifier<Tuple2<String, DateTime>> dateSelected =
      ValueNotifier<Tuple2<String, DateTime>>(Tuple2('', DateTime.now()));
  final ValueNotifier<TypeChart> typeChart =
      ValueNotifier<TypeChart>(TypeChart.volume);
  final ValueNotifier<UserSet> selectedUserSet =
      ValueNotifier<UserSet>(UserSet());

  @override
  void dispose() {
    dateSelected.dispose();
    typeChart.dispose();
    selectedUserSet.dispose();
    super.dispose();
  }

  Future<List<UserSet>> getAllUserSetByExercice(String exerciceUid) {
    return userSetService.getForExercice(exerciceUid);
  }

  Future<WorkoutInstance?> getWorkoutInstance(String uidWorkout) {
    return workoutInstanceService.read(uidWorkout);
  }

  List<charts.Series<TimeSeries, DateTime>> toChartSeries(String exerciceUid, List<TimeSeries> data) {
    data.sort((a, b) => a.time.compareTo(b.time));
    return [
      charts.Series<TimeSeries, DateTime>(
        id: exerciceUid,
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (TimeSeries sales, _) => sales.time,
        measureFn: (TimeSeries sales, _) => sales.total,
        data: data,
      )
    ];
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

  List<charts.Series<TimeSeries, DateTime>> getWorkoutVolume(List<UserSet> listUserSet, Exercice exercice) {
    if (listUserSet.isEmpty) {
      return [];
    }

    final String exerciceUid = exercice.uid!;
    final data = <TimeSeries>[];
    for (UserSet userSet in listUserSet) {
      data.add(TimeSeries<UserSet>(userSet.date!, getVolume(userSet), userSet));
    }

    return toChartSeries(exerciceUid, data);
  }

  List<charts.Series<TimeSeries, DateTime>> getWorkoutMaxReps(List<UserSet> listUserSet, Exercice exercice) {
    if (listUserSet.isEmpty) {
      return [];
    }

    final String exerciceUid = exercice.uid!;
    final data = <TimeSeries>[];
    for (UserSet userSet in listUserSet) {
      data.add(TimeSeries<UserSet>(userSet.date!, getMaxReps(userSet), userSet));
    }

    return toChartSeries(exerciceUid, data);
  }

  List<charts.Series<TimeSeries, DateTime>> getWorkoutMaxWeight(List<UserSet> listUserSet, Exercice exercice) {
    if (listUserSet.isEmpty) {
      return [];
    }

    final String exerciceUid = exercice.uid!;
    final data = <TimeSeries>[];
    for (UserSet userSet in listUserSet) {
      data.add(TimeSeries<UserSet>(userSet.date!, getMaxWeight(userSet), userSet));
    }

    return toChartSeries(exerciceUid, data);
  }
}
