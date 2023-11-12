import 'dart:async';

import 'package:fitnc_user/page/workout/workout-instance.page.dart';
import 'package:fitnc_user/service/debug_printer.dart';
import 'package:fitnc_user/service/exercice.service.dart';
import 'package:fitnc_user/service/user-set.service.dart';
import 'package:fitnc_user/service/workout-instance.service.dart';
import 'package:fitness_domain/domain/exercice.domain.dart';
import 'package:fitness_domain/domain/user.line.domain.dart';
import 'package:fitness_domain/domain/user.set.domain.dart';
import 'package:fitness_domain/enum/dist_unit.enum.dart';
import 'package:fitness_domain/enum/time_unit.enum.dart';
import 'package:fitness_domain/enum/weight_unit.enum.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

class UserSetController extends ChangeNotifier {
  final WorkoutInstanceService workoutInstanceService = GetIt.I.get();
  final UserSetService userSetService = GetIt.I.get();
  final ExerciceService exerciseService = GetIt.I.get();

  final List<UserLine> listLines = <UserLine>[];
  final int debounceTime = 200;

  UserSet userSet = UserSet();
  Timer? _debounce;

  void init(UserSet userSet) {
    if (userSet.lines.isEmpty) {
      userSet.lines.add(UserLine());
    }
    this.userSet = userSet;
  }

  void initList(List<UserLine> lines, bool notify) {
    listLines.clear();
    listLines.addAll(lines);
    if (notify) {
      notifyListeners();
    }
  }

  void addLine() {
    userSet.lines.add(UserLine());
    initList(userSet.lines, true);
  }

  void afterDebounce(void Function() callback) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(Duration(milliseconds: debounceTime), () {
      callback.call();
    });
  }

  void removeLastLine() {
    userSet.lines.removeAt(userSet.lines.length - 1);
    userSetService.save(userSet).then((value) {
      initList(userSet.lines, true);
    });
  }

  void changeReps(int index, String reps) {
    userSet.lines[index].reps = reps;
    afterDebounce(() {
      userSetService.save(userSet).then((value) => DebugPrinter.printLn('Reps saved'));
    });
  }

  void changeWeight(int index, String weight) {
    userSet.lines[index].weight = weight;
    afterDebounce(() {
      userSetService.save(userSet).then((value) => DebugPrinter.printLn('Weight saved'));
    });
  }

  void changeWeightUnit(int index, WeightUnit unit) {
    userSet.lines[index].weightUnit = unit;
    userSetService.save(userSet).then((value) => DebugPrinter.printLn('Weight unit saved'));
  }

  void changeCheck(BuildContext context, int index, bool checked) {
    userSet.lines[index].checked = checked;
    userSetService.save(userSet).then((value) => notifyListeners());
    initList(userSet.lines, true);
    if (checked) {
      Provider.of<WorkoutPageNotifier>(context, listen: false).check();
    }
  }

  void changeTime(int index, String value) {
    userSet.lines[index].time = value;
    afterDebounce(() {
      userSetService.save(userSet).then((value) => DebugPrinter.printLn('Time saved'));
    });
  }

  void changeTimeUnit(int index, TimeUnit unit) {
    userSet.lines[index].timeUnit = unit;
    userSetService.save(userSet).then((value) => DebugPrinter.printLn('Time unit saved'));
  }

  void changeDist(int index, String value) {
    userSet.lines[index].dist = value;
    afterDebounce(() {
      userSetService.save(userSet).then((value) => DebugPrinter.printLn('Dist saved'));
    });
  }

  void changeDistUnit(int index, DistUnit unit) {
    userSet.lines[index].distUnit = unit;
    userSetService.save(userSet).then((value) => DebugPrinter.printLn('Dist unit saved'));
  }

  void changeRestTime(int index, String value) {
    userSet.lines[index].restTime = value;
    afterDebounce(() {
      userSetService.save(userSet).then((value) => DebugPrinter.printLn('Rest Time saved'));
    });
  }

  void changeRestTimeUnit(int index, TimeUnit unit) {
    userSet.lines[index].restTimeUnit = unit;
    userSetService.save(userSet).then((value) => DebugPrinter.printLn('Rest Time unit saved'));
  }

  void checkAll() {
    for (var element in userSet.lines) {
      element.checked = true;
    }
    userSetService.save(userSet).then((value) => notifyListeners());
    initList(userSet.lines, true);
  }

  void addComment(String? comment) {
    userSet.comment = comment;
    userSetService.save(userSet).then((value) => notifyListeners());
  }

  Future<Exercice?> getExercise(String uidExercise) {
    return exerciseService.read(uidExercise);
  }

  Future<String> getExerciseImageUrl() async {
    final Exercice? exercise = await getExercise(userSet.uidExercice);
    if (exercise != null && exercise.imageUrl != null) {
      return exercise.imageUrl!;
    }
    return '';
  }
}
