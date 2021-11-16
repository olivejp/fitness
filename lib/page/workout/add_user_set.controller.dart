import 'dart:async';

import 'package:fitnc_user/page/workout/workout-instance.page.dart';
import 'package:fitnc_user/service/exercice.service.dart';
import 'package:fitnc_user/service/user-set.service.dart';
import 'package:fitnc_user/service/workout-instance.service.dart';
import 'package:fitness_domain/domain/exercice.domain.dart';
import 'package:fitness_domain/domain/user.line.domain.dart';
import 'package:fitness_domain/domain/user.set.domain.dart';
import 'package:get/get.dart';

class UserSetController extends GetxController {
  final WorkoutInstanceService workoutInstanceService = Get.find();
  final UserSetService userSetService = Get.find();
  final ExerciceService exerciseService = Get.find();
  final WorkoutPageController pageController = Get.find();
  final Rx<UserSet> userSet = UserSet().obs;
  final RxList<UserLine> listLines = <UserLine>[].obs;
  final int debounceTime = 200;
  Timer? _debounce;

  void init(UserSet userSet) {
    if (userSet.lines.isEmpty) {
      userSet.lines.add(UserLine());
    }
    this.userSet.value = userSet;
  }

  void initList(List<UserLine> lines) {
    listLines.clear();
    listLines.addAll(lines);
    listLines.refresh();
  }

  void addLine() {
    userSet.update((val) {
      val!.lines.add(UserLine());
    });
    initList(userSet.value.lines);
  }

  void afterDebounce(void Function() callback) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(Duration(milliseconds: debounceTime), () {
      callback.call();
    });
  }

  void removeLastLine() {
    userSet.update((val) {
      val!.lines.removeAt(val.lines.length - 1);
    });
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
    userSet.update((val) {
      for (var element in val!.lines) {
        element.checked = true;
      }
    });
    userSetService.save(userSet.value);
    initList(userSet.value.lines);
  }

  void addComment(String? comment) {
    userSet.update((val) {
      val?.comment = comment;
    });
    userSetService.save(userSet.value);
  }

  Future<Exercice?> getExercise(String uidExercise) {
    return exerciseService.read(uidExercise);
  }
}
