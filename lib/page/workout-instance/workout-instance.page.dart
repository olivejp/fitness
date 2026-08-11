
import 'package:fitnc_user/l10n/l10n.dart';
import 'package:fitnc_user/page/exercice-choice/exercice-choice.widget.dart';
import 'package:fitnc_user/page/add-user-set/add-user-set.page.dart';
import 'package:fitnc_user/domain/user-set.domain.dart';
import 'package:fitnc_user/domain/workout-instance.domain.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loading_animations/loading_animations.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:fitnc_user/page/workout-instance/workout-instance.notifier.dart';

class WorkoutPage extends StatefulWidget {
  const WorkoutPage(
      {Key? key, required this.instance, this.goToLastPage = false})
      : super(key: key);

  final WorkoutInstance instance;
  final bool goToLastPage;

  @override
  State<WorkoutPage> createState() => _WorkoutPageState();
}

class _WorkoutPageState extends State<WorkoutPage> {
  late final WorkoutNotifier notifier;
  final double iconHorizontalPadding = 25;
  final double containerHeight = 60;
  final double containerMaxHeight = 250;

  WorkoutInstance get instance => widget.instance;

  @override
  void initState() {
    super.initState();
    notifier = WorkoutNotifier();
    notifier.init(instance, goToLastPage: widget.goToLastPage);
  }

  ///
  /// Le notifier est détruit avec la page : son dispose() libère chrono,
  /// lecteur audio et souscriptions.
  ///
  @override
  void dispose() {
    notifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: notifier,
      builder: (_, __) {
        return SafeArea(
          child: Scaffold(
            bottomSheet: BottomSheet(
              onClosing: () => print('close'),
              builder: (_) {
                return ChronoBottomSheet(
                    notifier: notifier,
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
                      .displaySmall
                      ?.copyWith(color: Theme.of(context).colorScheme.primary),
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
                  tooltip: context.l10n.showMore,
                  icon: const Icon(Icons.more_vert, color: Colors.grey),
                  itemBuilder: (_) => <PopupMenuItem<dynamic>>[
                    PopupMenuItem<dynamic>(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(context.l10n.options),
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
                ValueListenableBuilder<List<WorkoutStepper>>(
                  valueListenable: notifier.stepperList,
                  builder: (_, List<WorkoutStepper> steps, __) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: steps.map(
                        (WorkoutStepper e) {
                          return Icon(
                            e.checked ? Icons.circle : Icons.circle_outlined,
                            color: e.allExerciseDone
                                ? Colors.green
                                : Theme.of(context).colorScheme.primary,
                          );
                        },
                      ).toList(),
                    );
                  },
                ),
                Flexible(
                  child: FutureBuilder<List<UserSet>>(
                    future: notifier.getAllUserSet(),
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
                          return UserSetPageView(
                            listUserSet: snapshot.data!,
                            initialPage: notifier.initialPage.value,
                            onPageChanged: notifier.changeStepper,
                            pageController: notifier,
                          );
                        }
                        if (snapshot.data!.isEmpty) {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              TextButton.icon(
                                label: Text(context.l10n.addExercise),
                                icon: const Icon(Icons.add_circle_outline),
                                onPressed: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => ExerciseChoiceDialog(
                                      workoutInstance: instance,
                                      popOnChoice: true,
                                      onValidated:
                                          notifier.refreshWorkoutPage,
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
                                backgroundColor: Theme.of(context).colorScheme.primary,
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

///
/// Porte le PageController des séances. Il était auparavant instancié dans un
/// builder Obx : un nouveau notifier à chaque émission, jamais disposé, et la
/// position de page perdue à chaque rafraîchissement.
///
class UserSetPageView extends StatefulWidget {
  const UserSetPageView({
    Key? key,
    required this.listUserSet,
    required this.initialPage,
    required this.onPageChanged,
    required this.pageController,
  }) : super(key: key);

  final List<UserSet> listUserSet;
  final int initialPage;
  final void Function(int pageNumber) onPageChanged;
  final WorkoutNotifier pageController;

  @override
  State<UserSetPageView> createState() => _UserSetPageViewState();
}

class _UserSetPageViewState extends State<UserSetPageView> {
  late final PageController pageController;

  @override
  void initState() {
    super.initState();
    pageController = PageController(initialPage: widget.initialPage);
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: pageController,
      onPageChanged: widget.onPageChanged,
      children: widget.listUserSet
          .map((UserSet userSet) => OpenUserSetInstance(
                userSet: userSet,
                pageController: widget.pageController,
              ))
          .toList(),
    );
  }
}

class ChronoBottomSheet extends StatelessWidget {
  const ChronoBottomSheet({
    Key? key,
    required this.notifier,
    required this.containerMaxHeight,
    required this.containerHeight,
    required this.iconHorizontalPadding,
  }) : super(key: key);

  final WorkoutNotifier notifier;
  final double containerMaxHeight;
  final double containerHeight;
  final double iconHorizontalPadding;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 5,
      child: ValueListenableBuilder<bool>(
        valueListenable: notifier.bottomSheetIsExpanded,
        builder: (_, bool isExpanded, __) => AnimatedContainer(
          alignment: Alignment.topCenter,
          duration: const Duration(milliseconds: 150),
          height: isExpanded ? containerMaxHeight : containerHeight,
          child: Column(
            children: [
              SizedBox(
                height: containerHeight,
                child: Container(
                  color: Theme.of(context).colorScheme.primary,
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        padding: EdgeInsets.symmetric(
                            horizontal: iconHorizontalPadding),
                        iconSize: 24,
                        color: Colors.white,
                        onPressed: () =>
                            notifier.bottomSheetIsExpanded.value = !isExpanded,
                        icon: isExpanded
                            ? const Icon(Icons.keyboard_arrow_down)
                            : const Icon(Icons.keyboard_arrow_up),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          StreamBuilder<int>(
                              stream: notifier.getTimer().rawTime,
                              initialData: 0,
                              builder: (_, snapshot) {
                                if (snapshot.hasData) {
                                  final value = snapshot.data;
                                  final displayTime =
                                      StopWatchTimer.getDisplayTime(value!);
                                  return Text(
                                    displayTime,
                                    style:
                                        Theme.of(context).textTheme.displaySmall,
                                  );
                                }
                                return const Text('');
                              }),
                        ],
                      ),
                      ValueListenableBuilder<bool>(
                          valueListenable: notifier.timerStarted,
                          builder: (_, bool started, __) {
                        if (started) {
                          return IconButton(
                            padding: EdgeInsets.symmetric(
                                horizontal: iconHorizontalPadding),
                            iconSize: 28,
                            color: Colors.white,
                            onPressed: notifier.stopTimer,
                            icon: const Icon(Icons.pause_circle_outline),
                          );
                        } else {
                          return IconButton(
                            padding: EdgeInsets.symmetric(
                                horizontal: iconHorizontalPadding),
                            iconSize: 28,
                            color: Colors.white,
                            onPressed: notifier.startTimer,
                            icon: const Icon(Icons.play_circle_outline),
                          );
                        }
                      }),
                    ],
                  ),
                ),
              ),
              if (isExpanded)
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
                                          notifier.changeHour(newValue),
                                      initialValue: notifier.timerHour,
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
                                          notifier.changeMinute(newValue),
                                      initialValue: notifier.timerMinute,
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
                                          notifier.changeSecond(newValue),
                                      initialValue: notifier.timerSecond,
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
                            ValueListenableBuilder<bool>(
                              valueListenable: notifier.autoPlay,
                              builder: (_, bool autoPlay, __) => Checkbox(
                                value: autoPlay,
                                onChanged: (bool? value) =>
                                    notifier.autoPlay.value = value ?? false,
                              ),
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
            .displaySmall
            ?.copyWith(color: Theme.of(context).colorScheme.primary),
        textStyle:
            Theme.of(context).textTheme.displaySmall?.copyWith(fontSize: 23),
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
