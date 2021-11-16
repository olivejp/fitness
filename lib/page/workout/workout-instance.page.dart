import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:fitnc_user/page/exercice/exercice-choice.dialog.dart';
import 'package:fitnc_user/page/workout/add_user_set.page.dart';
import 'package:fitnc_user/service/user-set.service.dart';
import 'package:fitnc_user/service/workout-instance.service.dart';
import 'package:fitness_domain/domain/user.set.domain.dart';
import 'package:fitness_domain/domain/workout-instance.domain.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:loading_animations/loading_animations.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

class Stepper {
  Stepper(
      {this.checked = false,
      required this.userSetUid,
      this.allExerciseDone = false});

  bool checked;
  String? userSetUid;
  bool allExerciseDone;
}

class WorkoutPageController extends GetxController {
  final WorkoutInstanceService service = Get.find();
  final UserSetService userSetService = Get.find();
  final RxInt initialPage = 0.obs;
  final RxBool bottomSheetIsExpanded = false.obs;
  final Rx<WorkoutInstance?> workoutInstance = WorkoutInstance().obs;
  final RxList<Stepper> stepperList = <Stepper>[].obs;
  final RxBool onRefresh = false.obs;
  final RxBool autoPlay = false.obs;
  final RxBool timerStarted = false.obs;
  final AudioPlayer audioPlayer = AudioPlayer(mode: PlayerMode.LOW_LATENCY);
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

  void init(WorkoutInstance workoutInstance, {bool goToLastPage = false}) {
    this.workoutInstance.value = workoutInstance;
    this.goToLastPage = goToLastPage;
    if (userSetSubscription != null) {
      userSetSubscription!.cancel();
    }

    // On écoute tous les userSet de ce workoutInstance.
    userSetSubscription =
        userSetService.listenAll(workoutInstance.uid!).listen((listUserSet) {
      for (var userSet in listUserSet) {
        int index = stepperList
            .indexWhere((stepper) => stepper.userSetUid == userSet.uid);
        if (index > -1) {
          stepperList[index].allExerciseDone = userSet.lines.isNotEmpty &&
              userSet.lines.every((set) => set.checked);
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
    return userSetService
        .orderByGet(workoutInstance.value!.uid!, 'createDate', false)
        .then((listUserSet) {
      stepperList.clear();
      for (var element in listUserSet) {
        stepperList.add(Stepper(
            userSetUid: element.uid,
            checked: false,
            allExerciseDone: element.lines.isNotEmpty &&
                element.lines.every((line) => line.checked)));
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
    timer.onExecute.add(StopWatchExecute.start);
    timerSubscription = timer.rawTime.listen((event) {
      if (event == 0) {
        audioPlayer
            .play('sounds/notification.wav', isLocal: true)
            .then((value) => null);
        changeTimer();
      }
    });
  }

  void stopTimer() {
    timerStarted.value = false;
    timer.onExecute.add(StopWatchExecute.stop);
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
    timer.onExecute.add(StopWatchExecute.reset);
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
  WorkoutPage({Key? key, required this.instance, this.goToLastPage = false})
      : super(key: key) {
    controller.init(instance, goToLastPage: goToLastPage);
  }

  final WorkoutPageController controller = Get.put(WorkoutPageController());
  final WorkoutInstance instance;
  final bool goToLastPage;
  final double iconHorizontalPadding = 25;
  final double containerHeight = 60;
  final double containerMaxHeight = 250;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        // ATTENTION Il faut laisser cette ligne car sinon l'obx ne sera jamais déclenché.
        bool onRefresh = controller.onRefresh.value;
        return SafeArea(
          child: Scaffold(
            bottomSheet: BottomSheet(
              onClosing: () => print('close'),
              builder: (_) {
                return ChronoBottomSheet(
                    controller: controller,
                    containerMaxHeight: containerMaxHeight,
                    containerHeight: containerHeight,
                    iconHorizontalPadding: iconHorizontalPadding);
              },
            ),
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              toolbarHeight: 70,
              elevation: 0,
              title: Padding(
                padding: const EdgeInsets.only(top: 0),
                child: Text(
                  DateFormat('dd/MM/yy - kk:mm').format(instance.date!),
                  style: Theme.of(context)
                      .textTheme
                      .headline3
                      ?.copyWith(color: Theme.of(context).primaryColor),
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
                  tooltip: 'showMore'.tr,
                  icon: const Icon(Icons.more_vert, color: Colors.grey),
                  itemBuilder: (_) => <PopupMenuItem<dynamic>>[
                    PopupMenuItem<dynamic>(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text('options'.tr),
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
                Obx(
                  () {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: controller.stepperList.map(
                        (Stepper e) {
                          return Icon(
                            e.checked ? Icons.circle : Icons.circle_outlined,
                            color: e.allExerciseDone
                                ? Colors.green
                                : Theme.of(context).primaryColor,
                          );
                        },
                      ).toList(),
                    );
                  },
                ),
                Flexible(
                  child: FutureBuilder<List<UserSet>>(
                    future: controller.getAllUserSet(),
                    builder: (_, snapshot) {
                      if (snapshot.hasError) {
                        return Column(
                          children: [
                            Expanded(
                              child: Center(
                                child: Text(
                                    'Error : ${snapshot.error.toString()}'),
                              ),
                            ),
                          ],
                        );
                      }
                      if (snapshot.hasData) {
                        if (snapshot.data!.isNotEmpty) {
                          List<UserSet> listUserSet = snapshot.data!;
                          return Obx(() {
                            final PageController pageController =
                                PageController(
                                    initialPage: controller.initialPage.value);
                            return PageView(
                              controller: pageController,
                              children: listUserSet
                                  .map((e) => OpenUserSetInstance(userSet: e))
                                  .toList(),
                              onPageChanged: (pageNumber) =>
                                  controller.changeStepper(pageNumber),
                            );
                          });
                        }
                        if (snapshot.data!.isEmpty) {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              TextButton.icon(
                                label: Text('addExercise'.tr),
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
    Key? key,
    required this.controller,
    required this.containerMaxHeight,
    required this.containerHeight,
    required this.iconHorizontalPadding,
  }) : super(key: key);

  final WorkoutPageController controller;
  final double containerMaxHeight;
  final double containerHeight;
  final double iconHorizontalPadding;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 5,
      child: Obx(
        () => AnimatedContainer(
          alignment: Alignment.topCenter,
          duration: const Duration(milliseconds: 150),
          height: controller.bottomSheetIsExpanded.value
              ? containerMaxHeight
              : containerHeight,
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
                        padding: EdgeInsets.symmetric(
                            horizontal: iconHorizontalPadding),
                        iconSize: 24,
                        color: Colors.white,
                        onPressed: () => controller.bottomSheetIsExpanded
                            .value = !controller.bottomSheetIsExpanded.value,
                        icon: Obx(() {
                          if (controller.bottomSheetIsExpanded.value) {
                            return const Icon(Icons.keyboard_arrow_down);
                          } else {
                            return const Icon(Icons.keyboard_arrow_up);
                          }
                        }),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          StreamBuilder<int>(
                              stream: controller.getTimer().rawTime,
                              initialData: 0,
                              builder: (_, snapshot) {
                                if (snapshot.hasData) {
                                  final value = snapshot.data;
                                  final displayTime =
                                      StopWatchTimer.getDisplayTime(value!);
                                  return Text(
                                    displayTime,
                                    style:
                                        Theme.of(context).textTheme.headline3,
                                  );
                                }
                                return const Text('');
                              }),
                        ],
                      ),
                      Obx(() {
                        if (controller.timerStarted.value) {
                          return IconButton(
                            padding: EdgeInsets.symmetric(
                                horizontal: iconHorizontalPadding),
                            iconSize: 28,
                            color: Colors.white,
                            onPressed: controller.stopTimer,
                            icon: const Icon(Icons.pause_circle_outline),
                          );
                        } else {
                          return IconButton(
                            padding: EdgeInsets.symmetric(
                                horizontal: iconHorizontalPadding),
                            iconSize: 28,
                            color: Colors.white,
                            onPressed: controller.startTimer,
                            icon: const Icon(Icons.play_circle_outline),
                          );
                        }
                      }),
                    ],
                  ),
                ),
              ),
              if (controller.bottomSheetIsExpanded.value)
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
                                      onChanged: (int newValue) =>
                                          controller.changeHour(newValue),
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
                                      onChanged: (int newValue) =>
                                          controller.changeMinute(newValue),
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
                                      onChanged: (int newValue) =>
                                          controller.changeSecond(newValue),
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
                              value: controller.autoPlay.value,
                              onChanged: (bool? value) =>
                                  controller.autoPlay.value = value ??= false,
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
    Key? key,
    required this.onChanged,
    this.initialValue = 0,
    required this.maxValue,
    required this.minValue,
  }) : super(key: key) {
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
        selectedTextStyle: Theme.of(context)
            .textTheme
            .headline3
            ?.copyWith(color: Theme.of(context).primaryColor),
        textStyle:
            Theme.of(context).textTheme.headline3?.copyWith(fontSize: 23),
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
