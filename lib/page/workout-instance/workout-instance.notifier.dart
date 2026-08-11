import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:fitnc_user/di.dart';
import 'package:fitnc_user/domain/user-set.domain.dart';
import 'package:fitnc_user/domain/workout-instance.domain.dart';
import 'package:fitnc_user/service/user-set.service.dart';
import 'package:fitnc_user/service/workout-instance.service.dart';
import 'package:flutter/foundation.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

class WorkoutStepper {
  WorkoutStepper(
      {this.checked = false,
      required this.userSetUid,
      this.allExerciseDone = false});

  bool checked;
  String? userSetUid;
  bool allExerciseDone;
}

class WorkoutNotifier extends ChangeNotifier {
  WorkoutNotifier() {
    // Depuis audioplayers 1.0, AudioCache n'est plus un lecteur mais un simple
    // résolveur d'assets : AudioPlayer.play(AssetSource(...)) fonctionne sur
    // toutes les plateformes, web compris, sans branche spécifique.
    audioPlayer.setPlayerMode(PlayerMode.lowLatency);
  }

  final WorkoutInstanceService service = di<WorkoutInstanceService>();
  final UserSetService userSetService = di<UserSetService>();
  final ValueNotifier<int> initialPage = ValueNotifier<int>(0);
  final ValueNotifier<bool> bottomSheetIsExpanded = ValueNotifier<bool>(false);
  final ValueNotifier<WorkoutInstance?> workoutInstance =
      ValueNotifier<WorkoutInstance?>(WorkoutInstance());
  final ValueNotifier<List<WorkoutStepper>> stepperList =
      ValueNotifier<List<WorkoutStepper>>(<WorkoutStepper>[]);
  final ValueNotifier<bool> autoPlay = ValueNotifier<bool>(false);
  final ValueNotifier<bool> timerStarted = ValueNotifier<bool>(false);
  final AudioPlayer audioPlayer = AudioPlayer();
  final StopWatchTimer timer = StopWatchTimer(
      mode: StopWatchMode.countDown,
      presetMillisecond: StopWatchTimer.getMilliSecFromMinute(0));
  StreamSubscription? userSetSubscription;
  bool goToLastPage = false;
  int timerMillisecond = 0;
  int timerHour = 0;
  int timerMinute = 0;
  int timerSecond = 0;
  StreamSubscription? timerSubscription;

  ///
  /// StopWatchTimer et AudioPlayer tiennent des ressources natives : sans
  /// dispose() explicite, chaque séance ouverte en laissait une paire derrière
  /// elle, avec ses deux souscriptions encore actives.
  ///
  @override
  void dispose() {
    userSetSubscription?.cancel();
    timerSubscription?.cancel();
    timer.dispose();
    audioPlayer.dispose();
    initialPage.dispose();
    bottomSheetIsExpanded.dispose();
    workoutInstance.dispose();
    stepperList.dispose();
    autoPlay.dispose();
    timerStarted.dispose();
    super.dispose();
  }

  void init(WorkoutInstance workoutInstance, {bool goToLastPage = false}) {
    this.workoutInstance.value = workoutInstance;
    this.goToLastPage = goToLastPage;
    if (userSetSubscription != null) {
      userSetSubscription!.cancel();
    }

    // On écoute tous les userSet de ce workoutInstance.
    userSetSubscription =
        userSetService.listenAll(workoutInstance.uid!).listen((listUserSet) {
      final List<WorkoutStepper> steps = List<WorkoutStepper>.of(stepperList.value);
      for (final UserSet userSet in listUserSet) {
        final int index = steps
            .indexWhere((WorkoutStepper stepper) => stepper.userSetUid == userSet.uid);
        if (index > -1) {
          steps[index].allExerciseDone = userSet.lines.isNotEmpty &&
              userSet.lines.every((set) => set.checked);
        }
      }
      stepperList.value = steps;
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

  /// Force le rechargement des séries de la séance.
  void refreshWorkoutPage() {
    notifyListeners();
  }

  Future<List<UserSet>> getAllUserSet() {
    return userSetService
        .orderByGet(workoutInstance.value!.uid!, 'createDate', false)
        .then((listUserSet) {
      stepperList.value = listUserSet
          .map((UserSet element) => WorkoutStepper(
              userSetUid: element.uid,
              checked: false,
              allExerciseDone: element.lines.isNotEmpty &&
                  element.lines.every((line) => line.checked)))
          .toList();
      if (goToLastPage) {
        changeStepper(stepperList.value.length - 1);
        initialPage.value = listUserSet.length - 1;
      } else {
        changeStepper(0);
        initialPage.value = 0;
      }
      return listUserSet;
    });
  }

  void changeStepper(int index) {
    final List<WorkoutStepper> steps = List<WorkoutStepper>.of(stepperList.value);
    for (int i = 0; i < steps.length; i++) {
      steps[i].checked = (i == index);
    }
    stepperList.value = steps;
  }

  void startTimer() {
    timerStarted.value = true;
    timer.onStartTimer();
    timerSubscription = timer.rawTime.listen((event) {
      if (event == 0) {
        // Le préfixe par défaut d'AssetSource est 'assets/', le fichier déclaré
        // dans le pubspec est donc résolu tel quel.
        audioPlayer.play(AssetSource('notification.wav'));

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
