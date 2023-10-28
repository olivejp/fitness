import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:fitnc_user/page/workout/stepper.data.dart';
import 'package:fitnc_user/service/user-set.service.dart';
import 'package:fitnc_user/service/workout-instance.service.dart';
import 'package:fitness_domain/domain/user.set.domain.dart';
import 'package:fitness_domain/domain/workout-instance.domain.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

class WorkoutPageController extends ChangeNotifier {
  final WorkoutInstanceService service = GetIt.I.get();
  final UserSetService userSetService = GetIt.I.get();
  final RxInt initialPage = 0.obs;
  final RxBool bottomSheetIsExpanded = false.obs;
  final Rx<WorkoutInstance?> workoutInstance = WorkoutInstance().obs;
  final RxList<FitStepper> stepperList = <FitStepper>[].obs;
  final RxBool onRefresh = false.obs;
  final RxBool autoPlay = false.obs;
  final RxBool timerStarted = false.obs;
  late AudioPlayer? audioPlayer;
  late AudioCache? audioCache;
  final StopWatchTimer timer =
      StopWatchTimer(mode: StopWatchMode.countDown, presetMillisecond: StopWatchTimer.getMilliSecFromMinute(0));
  StreamSubscription? userSetSubscription;
  bool goToLastPage = false;
  int timerMillisecond = 0;
  int timerHour = 0;
  int timerMinute = 0;
  int timerSecond = 0;
  StreamSubscription? timerSubscription;

  WorkoutPageController() {
    // To play asset we need AudioCache. But AudioCache is not provided for Web.
    // see {https://github.com/bluefireteam/audioplayers/blob/master/packages/audioplayers/doc/audio_cache.md}
    if (kIsWeb) {
      audioPlayer = AudioPlayer();
    } else {
      audioCache = AudioCache();
    }
  }

  void init(WorkoutInstance workoutInstance, {bool goToLastPage = false}) {
    this.workoutInstance.value = workoutInstance;
    this.goToLastPage = goToLastPage;
    if (userSetSubscription != null) {
      userSetSubscription!.cancel();
    }

    // On écoute tous les userSet de ce workoutInstance.
    userSetSubscription = userSetService.listenAll(workoutInstance.uid!).listen((listUserSet) {
      for (var userSet in listUserSet) {
        int index = stepperList.indexWhere((stepper) => stepper.userSetUid == userSet.uid);
        if (index > -1) {
          stepperList[index].allExerciseDone = userSet.lines.isNotEmpty && userSet.lines.every((set) => set.checked);
        }
      }
      stepperList.refresh();
    });
  }

  void check() {
    if (autoPlay.value) {
      if (timer.isRunning) {
        stopTimer();
      }
      startTimer();
    }
  }

  void refreshWorkoutPage() {
    onRefresh.update((val) {
      val = !val!;
    });
  }

  Future<List<UserSet>> getAllUserSet() {
    return userSetService.orderByGet(workoutInstance.value!.uid!, 'createDate', false).then((listUserSet) {
      stepperList.clear();
      for (var element in listUserSet) {
        stepperList.add(FitStepper(
            userSetUid: element.uid,
            checked: false,
            allExerciseDone: element.lines.isNotEmpty && element.lines.every((line) => line.checked)));
      }
      if (goToLastPage) {
        changeStepper(stepperList.length - 1);
        initialPage.value = listUserSet.length - 1;
      } else {
        changeStepper(0);
        initialPage.value = 0;
      }
      return listUserSet;
    });
  }

  void changeStepper(int index) {
    for (int i = 0; i < stepperList.length; i++) {
      stepperList[i].checked = (i == index);
    }
    stepperList.refresh();
  }

  void startTimer() {
    timerStarted.value = true;
    timer.onStartTimer();
    timerSubscription = timer.rawTime.listen((event) {
      if (event == 0) {
        if (kIsWeb) {
          audioPlayer?.setSourceAsset('assets/notification.wav').then((value) => null);
        } else {
          audioCache?.load('notification.wav').then((value) => null);
        }

        changeTimer();
      }
    });
  }

  void stopTimer() {
    timerStarted.value = false;
    timer.onStopTimer();
    timerSubscription?.cancel();
  }

  void changeHour(int newValue) {
    timerHour = newValue;
    changeTimer();
  }

  void changeMinute(int newValue) {
    timerMinute = newValue;
    changeTimer();
  }

  void changeSecond(int newValue) {
    timerSecond = newValue;
    changeTimer();
  }

  void changeTimer() {
    stopTimer();
    timer.onResetTimer();
    timer.clearPresetTime();
    timer.setPresetHoursTime(timerHour);
    timer.setPresetMinuteTime(timerMinute);
    timer.setPresetSecondTime(timerSecond);
  }

  StopWatchTimer getTimer() {
    return timer;
  }
}
