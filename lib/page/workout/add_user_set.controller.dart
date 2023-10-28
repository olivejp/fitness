import 'dart:async';

import 'package:fitnc_user/page/workout/workout-instance.page.dart';
import 'package:fitnc_user/service/exercice.service.dart';
import 'package:fitnc_user/service/user-set.service.dart';
import 'package:fitnc_user/service/workout-instance.service.dart';
import 'package:fitness_domain/domain/exercice.domain.dart';
import 'package:fitness_domain/domain/user.line.domain.dart';
import 'package:fitness_domain/domain/user.set.domain.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';

class UserSetController extends ChangeNotifier {
  final WorkoutInstanceService workoutInstanceService = GetIt.I.get();
  final UserSetService userSetService = GetIt.I.get();
  final ExerciceService exerciseService = GetIt.I.get();
  final WorkoutPageController pageController = GetIt.I.get();

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

  void initList(List<UserLine> lines) {
    listLines.clear();
    listLines.addAll(lines);
    notifyListeners();
  }

  void addLine() {
    userSet.lines.add(UserLine());
    initList(userSet.lines);
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
      initList(userSet.lines);
    });
  }

  void changeReps(int index, String reps) {
    userSet.lines[index].reps = reps;
    afterDebounce(() {
      userSetService.save(userSet).then((value) => notifyListeners());
    });
  }

  void changeWeight(int index, String weight) {
    userSet.lines[index].weight = weight;
    afterDebounce(() {
      userSetService.save(userSet).then((value) => notifyListeners());
    });
  }

  void changeCheck(int index, bool checked) {
    userSet.lines[index].checked = checked;
    userSetService.save(userSet).then((value) => notifyListeners());
    initList(userSet.lines);
    if (checked) {
      pageController.check();
    }
  }

  void changeTime(int index, String value) {
    userSet.lines[index].time = value;
    afterDebounce(() {
      userSetService.save(userSet).then((value) => notifyListeners());
    });
  }

  void changeDist(int index, String value) {
    userSet.lines[index].dist = value;
    afterDebounce(() {
      userSetService.save(userSet).then((value) => notifyListeners());
    });
  }

  void checkAll() {
    for (var element in userSet.lines) {
      element.checked = true;
    }
    userSetService.save(userSet).then((value) => notifyListeners());
    initList(userSet.lines);
  }

  void addComment(String? comment) {
    userSet.comment = comment;
    userSetService.save(userSet).then((value) => notifyListeners());
  }

  Future<Exercice?> getExercise(String uidExercise) {
    return exerciseService.read(uidExercise);
  }
}
