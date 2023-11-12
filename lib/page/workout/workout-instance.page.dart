import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitnc_user/page/workout/add_user_set.page.dart';
import 'package:fitnc_user/service/calendar_service.dart';
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

class WorkoutPageNotifier extends ChangeNotifier {
  final WorkoutInstanceService service = GetIt.I.get();
  final UserSetService userSetService = GetIt.I.get();

  final List<FitStepper> stepperList = <FitStepper>[];

  int initialPage = 0;
  bool _bottomSheetIsExpanded = false;
  WorkoutInstance? workoutInstance = WorkoutInstance();
  bool onRefresh = false;
  bool _autoPlay = false;
  bool timerStarted = false;

  bool get autoPlay => _autoPlay;

  set autoPlay(bool check) {
    _autoPlay = check;
    notifyListeners();
  }

  bool get bottomSheetIsExpanded => _bottomSheetIsExpanded;

  set bottomSheetIsExpanded(bool isExpanded) {
    _bottomSheetIsExpanded = isExpanded;
    notifyListeners();
  }

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

  WorkoutPageNotifier() {
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
    timerSubscription?.cancel();
    timerSubscription = timer.rawTime.listen((event) {
      if (event == 0) {
        if (kIsWeb) {
          audioPlayer?.setSource(AssetSource('assets/notification.wav')).then((value) {});
        } else {
          audioCache?.load('notification.wav').then((value) {});
        }
        changeTimer();
        notifyListeners();
      }
    });
    notifyListeners();
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
      value: WorkoutPageNotifier(),
      builder: (context, child) {
        final WorkoutPageNotifier notifierReadOnly = Provider.of<WorkoutPageNotifier>(context, listen: false);
        notifierReadOnly.init(instance, goToLastPage: goToLastPage);
        return SafeArea(
          child: Scaffold(
            bottomSheet: BottomSheet(
              onClosing: () => print('close'),
              builder: (_) {
                return ChronoBottomSheet(
                  containerMaxHeight: containerMaxHeight,
                  containerHeight: containerHeight,
                  iconHorizontalPadding: iconHorizontalPadding,
                );
              },
            ),
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              toolbarHeight: 70,
              title: Padding(
                padding: const EdgeInsets.only(top: 0),
                child: Text(
                  DateFormat('dd/MM/yy - kk:mm').format(
                      DateTime.fromMicrosecondsSinceEpoch((instance.date! as Timestamp).microsecondsSinceEpoch)),
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(color: Theme.of(context).primaryColor),
                ),
              ),
              leading: IconButton(
                onPressed: Navigator.of(context).pop,
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

                          return SingleChildScrollView(
                            child: Column(
                              children: listUserSet.map((userSet) {
                                final ValueNotifier isExpandedNotifier = ValueNotifier<bool>(false);
                                return ValueListenableBuilder(
                                  valueListenable: isExpandedNotifier,
                                  builder: (_, isExpanded, __) => InkWell(
                                    onTap: () => isExpandedNotifier.value = !isExpandedNotifier.value,
                                    child: Material(
                                      elevation: 1.0,
                                      child: Column(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  userSet.nameExercice!,
                                                  style: GoogleFonts.antonio(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.w900,
                                                  ),
                                                ),
                                                IconButton(
                                                  onPressed: () => isExpandedNotifier.value = !isExpandedNotifier.value,
                                                  icon: Icon(
                                                    isExpandedNotifier.value
                                                        ? Icons.arrow_circle_up_sharp
                                                        : Icons.arrow_circle_down_sharp,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          if (isExpanded) OpenUserSetInstance(userSet: userSet)
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
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
                                  style: GoogleFonts.antonio(),
                                ),
                                icon: const Icon(Icons.add_circle_outline),
                                onPressed: () => WorkoutUtility.goToExerciseChoiceDialog(
                                  context: context,
                                  workoutInstance: instance,
                                  isCreation: false,
                                  popOnChoice: false,
                                  dateTime: null,
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
      child: Consumer<WorkoutPageNotifier>(
        builder: (_, notifier, __) => AnimatedContainer(
          alignment: Alignment.topCenter,
          duration: const Duration(milliseconds: 150),
          height: notifier.bottomSheetIsExpanded ? containerMaxHeight : containerHeight,
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
                          onPressed: () => notifier.bottomSheetIsExpanded = !notifier.bottomSheetIsExpanded,
                          icon: (notifier.bottomSheetIsExpanded)
                              ? const Icon(Icons.keyboard_arrow_down)
                              : const Icon(Icons.keyboard_arrow_up)),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          StreamBuilder<int>(
                              stream: notifier.getTimer().rawTime,
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
                      (notifier.timerStarted)
                          ? IconButton(
                              padding: EdgeInsets.symmetric(horizontal: iconHorizontalPadding),
                              iconSize: 28,
                              color: Colors.white,
                              onPressed: notifier.stopTimer,
                              icon: const Icon(Icons.pause_circle_outline),
                            )
                          : IconButton(
                              padding: EdgeInsets.symmetric(horizontal: iconHorizontalPadding),
                              iconSize: 28,
                              color: Colors.white,
                              onPressed: notifier.startTimer,
                              icon: const Icon(Icons.play_circle_outline),
                            )
                    ],
                  ),
                ),
              ),
              if (notifier.bottomSheetIsExpanded)
                Flexible(
                  child: Container(
                    color: Theme.of(context).focusColor,
                    height: containerMaxHeight - containerHeight,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text('Heure'),
                                    Flexible(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(5),
                                          color: Colors.white,
                                        ),
                                        child: ScrollIncrementerWidget(
                                          onChanged: (int newValue) => notifier.changeHour(newValue),
                                          initialValue: notifier.timerHour,
                                          minValue: 0,
                                          maxValue: 23,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Padding(padding: EdgeInsets.all(10)),
                              Flexible(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text('Minute'),
                                    Flexible(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(5),
                                          color: Colors.white,
                                        ),
                                        child: ScrollIncrementerWidget(
                                          onChanged: (int newValue) => notifier.changeMinute(newValue),
                                          initialValue: notifier.timerMinute,
                                          minValue: 0,
                                          maxValue: 59,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Padding(padding: EdgeInsets.all(10)),
                              Flexible(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text('Seconde'),
                                    Flexible(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(5),
                                          color: Colors.white,
                                        ),
                                        child: ScrollIncrementerWidget(
                                          onChanged: (int newValue) => notifier.changeSecond(newValue),
                                          initialValue: notifier.timerSecond,
                                          minValue: 0,
                                          maxValue: 59,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Auto play'),
                            Checkbox(
                              value: notifier.autoPlay,
                              onChanged: (bool? value) => notifier.autoPlay = value ?? false,
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
