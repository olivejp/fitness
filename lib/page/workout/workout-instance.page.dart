import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:fitnc_user/page/exercice/exercice-choice.dialog.dart';
import 'package:fitnc_user/page/workout/add_user_set.page.dart';
import 'package:fitnc_user/service/user-set.service.dart';
import 'package:fitnc_user/service/workout-instance.service.dart';
import 'package:fitness_domain/domain/user.set.domain.dart';
import 'package:fitness_domain/domain/workout-instance.domain.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:loading_animations/loading_animations.dart';
import 'package:localization/localization.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:provider/provider.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

import './stepper.data.dart';

class WorkoutPageController extends ChangeNotifier {
  final WorkoutInstanceService service = GetIt.I.get();
  final UserSetService userSetService = GetIt.I.get();

  final List<FitStepper> stepperList = <FitStepper>[];

  int initialPage = 0;
  bool bottomSheetIsExpanded = false;
  WorkoutInstance? workoutInstance = WorkoutInstance();
  bool onRefresh = false;
  bool autoPlay = false;
  bool timerStarted = false;

  final StopWatchTimer timer =
      StopWatchTimer(mode: StopWatchMode.countDown, presetMillisecond: StopWatchTimer.getMilliSecFromMinute(0));

  late AudioPlayer? audioPlayer;
  late AudioCache? audioCache;
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
    this.workoutInstance = workoutInstance;
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
      notifyListeners();
    });
  }

  void check() {
    if (autoPlay) {
      if (timer.isRunning) {
        stopTimer();
      }
      startTimer();
    }
  }

  void refreshWorkoutPage() {
    onRefresh = !onRefresh;
  }

  Future<List<UserSet>> getAllUserSet() {
    return userSetService.orderByGet(workoutInstance!.uid!, 'createDate', false).then((listUserSet) {
      stepperList.clear();
      for (var element in listUserSet) {
        stepperList.add(FitStepper(
            userSetUid: element.uid,
            checked: false,
            allExerciseDone: element.lines.isNotEmpty && element.lines.every((line) => line.checked)));
      }
      if (goToLastPage) {
        changeStepper(stepperList.length - 1);
        initialPage = listUserSet.length - 1;
      } else {
        changeStepper(0);
        initialPage = 0;
      }
      return listUserSet;
    });
  }

  void changeStepper(int index) {
    for (int i = 0; i < stepperList.length; i++) {
      stepperList[i].checked = (i == index);
    }
    notifyListeners();
  }

  void startTimer() {
    timerStarted = true;
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
    timerStarted = false;
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

class WorkoutPage extends StatelessWidget {
  const WorkoutPage({
    super.key,
    required this.instance,
    this.goToLastPage = false,
  });

  final WorkoutInstance instance;
  final bool goToLastPage;
  final double iconHorizontalPadding = 25;
  final double containerHeight = 60;
  final double containerMaxHeight = 250;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: WorkoutPageController(),
      builder: (context, child) {
        final WorkoutPageController notifierReadOnly = Provider.of<WorkoutPageController>(context, listen: false);
        notifierReadOnly.init(instance, goToLastPage: goToLastPage);
        return SafeArea(
          child: Scaffold(
            bottomSheet: BottomSheet(
              onClosing: () => print('close'),
              builder: (_) {
                return ChronoBottomSheet(
                    containerMaxHeight: containerMaxHeight,
                    containerHeight: containerHeight,
                    iconHorizontalPadding: iconHorizontalPadding);
              },
            ),
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              toolbarHeight: 70,
              title: Padding(
                padding: const EdgeInsets.only(top: 0),
                child: Text(
                  DateFormat('dd/MM/yy - kk:mm').format(instance.date!),
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(color: Theme.of(context).primaryColor),
                ),
              ),
              leading: IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.amber,
                  size: 36,
                ),
              ),
              actions: [
                PopupMenuButton<dynamic>(
                  iconSize: 36,
                  tooltip: 'showMore'.i18n(),
                  icon: const Icon(Icons.more_vert, color: Colors.grey),
                  itemBuilder: (_) => <PopupMenuItem<dynamic>>[
                    PopupMenuItem<dynamic>(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text('options'.i18n()),
                          const Icon(
                            Icons.more_vert,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                      onTap: () {},
                    ),
                  ],
                ),
              ],
            ),
            body: Column(
              children: <Widget>[
                Consumer<WorkoutPageController>(
                  builder: (context, notifier, child) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: notifier.stepperList.map(
                        (FitStepper e) {
                          return Icon(
                            e.checked ? Icons.circle : Icons.circle_outlined,
                            color: e.allExerciseDone ? Colors.green : Theme.of(context).primaryColor,
                          );
                        },
                      ).toList(),
                    );
                  },
                ),
                Flexible(
                  child: FutureBuilder<List<UserSet>>(
                    future: notifierReadOnly.getAllUserSet(),
                    builder: (_, snapshot) {
                      if (snapshot.hasError) {
                        return Column(
                          children: [
                            Expanded(
                              child: Center(
                                child: Text('Error : ${snapshot.error.toString()}'),
                              ),
                            ),
                          ],
                        );
                      }
                      if (snapshot.hasData) {
                        if (snapshot.data!.isNotEmpty) {
                          final List<UserSet> listUserSet = snapshot.data!;

                          final PageController pageController =
                              PageController(initialPage: notifierReadOnly.initialPage);
                          return PageView(
                            controller: pageController,
                            children: listUserSet.map((e) => OpenUserSetInstance(userSet: e)).toList(),
                            onPageChanged: (pageNumber) => notifierReadOnly.changeStepper(pageNumber),
                          );
                        }
                        if (snapshot.data!.isEmpty) {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              TextButton.icon(
                                label: Text(
                                  'addExercise'.i18n(),
                                  style: GoogleFonts.anton(),
                                ),
                                icon: const Icon(Icons.add_circle_outline),
                                onPressed: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => ExerciseChoiceDialog(
                                      workoutInstance: instance,
                                      popOnChoice: true,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }
                      }
                      return Column(
                        children: [
                          Expanded(
                            child: Center(
                              child: LoadingBouncingGrid.circle(
                                backgroundColor: Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class ChronoBottomSheet extends StatelessWidget {
  const ChronoBottomSheet({
    super.key,
    required this.containerMaxHeight,
    required this.containerHeight,
    required this.iconHorizontalPadding,
  });

  final double containerMaxHeight;
  final double containerHeight;
  final double iconHorizontalPadding;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 5,
      child: Consumer<WorkoutPageController>(
        builder: (context, controller, child) => AnimatedContainer(
          alignment: Alignment.topCenter,
          duration: const Duration(milliseconds: 150),
          height: controller.bottomSheetIsExpanded ? containerMaxHeight : containerHeight,
          child: Column(
            children: [
              SizedBox(
                height: containerHeight,
                child: Container(
                  color: Theme.of(context).primaryColor,
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                          padding: EdgeInsets.symmetric(horizontal: iconHorizontalPadding),
                          iconSize: 24,
                          color: Colors.white,
                          onPressed: () => controller.bottomSheetIsExpanded = !controller.bottomSheetIsExpanded,
                          icon: (controller.bottomSheetIsExpanded)
                              ? const Icon(Icons.keyboard_arrow_down)
                              : const Icon(Icons.keyboard_arrow_up)),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          StreamBuilder<int>(
                              stream: controller.getTimer().rawTime,
                              initialData: 0,
                              builder: (_, snapshot) {
                                if (snapshot.hasData) {
                                  final value = snapshot.data;
                                  final displayTime = StopWatchTimer.getDisplayTime(value!);
                                  return Text(
                                    displayTime,
                                    style: Theme.of(context).textTheme.displaySmall,
                                  );
                                }
                                return const Text('');
                              }),
                        ],
                      ),
                      (controller.timerStarted)
                          ? IconButton(
                              padding: EdgeInsets.symmetric(horizontal: iconHorizontalPadding),
                              iconSize: 28,
                              color: Colors.white,
                              onPressed: controller.stopTimer,
                              icon: const Icon(Icons.pause_circle_outline),
                            )
                          : IconButton(
                              padding: EdgeInsets.symmetric(horizontal: iconHorizontalPadding),
                              iconSize: 28,
                              color: Colors.white,
                              onPressed: controller.startTimer,
                              icon: const Icon(Icons.play_circle_outline),
                            )
                    ],
                  ),
                ),
              ),
              if (controller.bottomSheetIsExpanded)
                Flexible(
                  child: Container(
                    color: Theme.of(context).focusColor,
                    height: containerMaxHeight - containerHeight,
                    child: Column(
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Column(
                                children: [
                                  const Text('Heure'),
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: Colors.white,
                                    ),
                                    child: ScrollIncrementerWidget(
                                      onChanged: (int newValue) => controller.changeHour(newValue),
                                      initialValue: controller.timerHour,
                                      minValue: 0,
                                      maxValue: 23,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Padding(padding: EdgeInsets.all(10)),
                            Flexible(
                              child: Column(
                                children: [
                                  const Text('Minute'),
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: Colors.white,
                                    ),
                                    child: ScrollIncrementerWidget(
                                      onChanged: (int newValue) => controller.changeMinute(newValue),
                                      initialValue: controller.timerMinute,
                                      minValue: 0,
                                      maxValue: 59,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Padding(padding: EdgeInsets.all(10)),
                            Flexible(
                              child: Column(
                                children: [
                                  const Text('Seconde'),
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: Colors.white,
                                    ),
                                    child: ScrollIncrementerWidget(
                                      onChanged: (int newValue) => controller.changeSecond(newValue),
                                      initialValue: controller.timerSecond,
                                      minValue: 0,
                                      maxValue: 59,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Auto play'),
                            Checkbox(
                              value: controller.autoPlay,
                              onChanged: (bool? value) => controller.autoPlay = value ??= false,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class ScrollIncrementerWidget extends StatelessWidget {
  ScrollIncrementerWidget({
    super.key,
    required this.onChanged,
    this.initialValue = 0,
    required this.maxValue,
    required this.minValue,
  }) {
    vnIncrementer = ValueNotifier(initialValue);
  }

  final int initialValue;
  final int maxValue;
  final int minValue;
  final void Function(int newValue) onChanged;
  late final ValueNotifier<int> vnIncrementer;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: vnIncrementer,
      builder: (_, value, __) => NumberPicker(
        selectedTextStyle: Theme.of(context).textTheme.displaySmall?.copyWith(color: Theme.of(context).primaryColor),
        textStyle: Theme.of(context).textTheme.displaySmall?.copyWith(fontSize: 23),
        itemHeight: 35,
        zeroPad: true,
        infiniteLoop: true,
        value: value,
        minValue: minValue,
        maxValue: maxValue,
        onChanged: (value) {
          vnIncrementer.value = value;
          onChanged(value);
        },
      ),
    );
  }
}
