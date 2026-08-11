import 'dart:async';

import 'package:fitnc_user/service/exercice.service.dart';
import 'package:fitnc_user/service/user-set.service.dart';
import 'package:fitnc_user/service/workout-instance.service.dart';
import 'package:fitnc_user/di.dart';
import 'package:fitnc_user/domain/exercice.domain.dart';
import 'package:fitnc_user/domain/user-line.domain.dart';
import 'package:fitnc_user/domain/user-set.domain.dart';
import 'package:flutter/foundation.dart';
import 'package:fitnc_user/page/workout-instance/workout-instance.notifier.dart';

class UserSetNotifier extends ChangeNotifier {
  UserSetNotifier({required this.pageController});

  final WorkoutInstanceService workoutInstanceService = di<WorkoutInstanceService>();
  final UserSetService userSetService = di<UserSetService>();
  final ExerciceService exerciseService = di<ExerciceService>();
  final WorkoutNotifier pageController;
  final ValueNotifier<UserSet> userSet = ValueNotifier<UserSet>(UserSet());
  final ValueNotifier<List<UserLine>> listLines =
      ValueNotifier<List<UserLine>>(<UserLine>[]);
  final int debounceTime = 200;
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    userSet.dispose();
    listLines.dispose();
    super.dispose();
  }

  void init(UserSet userSet) {
    if (userSet.lines.isEmpty) {
      userSet.lines.add(UserLine());
    }
    this.userSet.value = userSet;
  }

  void initList(List<UserLine> lines) {
    listLines.value = List<UserLine>.of(lines);
  }

  void addLine() {
    userSet.value.lines.add(UserLine());
    userSet.notifyListeners();
    initList(userSet.value.lines);
  }

  void afterDebounce(void Function() callback) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(Duration(milliseconds: debounceTime), () {
      callback.call();
    });
  }

  void removeLastLine() {
    userSet.value.lines.removeLast();
    userSet.notifyListeners();
    userSetService.save(userSet.value).then((value) {
      initList(userSet.value.lines);
    });
  }

  void changeReps(int index, String reps) {
    userSet.value.lines[index].reps = reps;
    afterDebounce(() {
      userSetService.save(userSet.value);
    });
  }

  void changeWeight(int index, String weight) {
    userSet.value.lines[index].weight = weight;
    afterDebounce(() {
      userSetService.save(userSet.value);
    });
  }

  void changeCheck(int index, bool checked) {
    userSet.value.lines[index].checked = checked;
    userSetService.save(userSet.value);
    initList(userSet.value.lines);
    if (checked) {
      pageController.check();
    }
  }

  void changeTime(int index, String value) {
    userSet.value.lines[index].time = value;
    afterDebounce(() {
      userSetService.save(userSet.value);
    });
  }

  void changeDist(int index, String value) {
    userSet.value.lines[index].dist = value;
    afterDebounce(() {
      userSetService.save(userSet.value);
    });
  }

  void checkAll() {
    for (final UserLine element in userSet.value.lines) {
      element.checked = true;
    }
    userSet.notifyListeners();
    userSetService.save(userSet.value);
    initList(userSet.value.lines);
  }

  void addComment(String? comment) {
    userSet.value.comment = comment;
    userSet.notifyListeners();
    userSetService.save(userSet.value);
  }

  Future<Exercice?> getExercise(String uidExercise) {
    return exerciseService.read(uidExercise);
  }
}
