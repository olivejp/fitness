import 'package:fitnc_user/controller/day-selection.controller.dart';
import 'package:fitnc_user/page/exercice/exercice-choice.dialog.dart';
import 'package:fitnc_user/page/home/home.controller.dart';
import 'package:fitnc_user/page/workout/workout-instance.page.dart';
import 'package:fitness_domain/domain/user.set.domain.dart';
import 'package:fitness_domain/domain/workout-instance.domain.dart';
import 'package:fitness_domain/widget/generic_container.widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:loading_animations/loading_animations.dart';

import 'calendar.page.controller.dart';

class FitnessDatePicker extends StatelessWidget {
  const FitnessDatePicker({
    Key? key,
    this.onMonthChange,
    required this.initialDate,
    this.onDateChange,
    this.unselectedDayColor,
    this.selectedDayColor,
    this.selectedDayTextStyle,
    this.unselectedDayTextStyle,
    this.builder,
    this.heigthMonth,
    this.widthMonth,
    this.trailing,
    this.leading,
  }) : super(key: key);

  final Color? unselectedDayColor;
  final Color? selectedDayColor;
  final TextStyle? selectedDayTextStyle;
  final TextStyle? unselectedDayTextStyle;
  final double? heigthMonth;
  final double? widthMonth;
  final ValueChanged<DateTime>? onDateChange;
  final ValueChanged<int?>? onMonthChange;
  final DateTime initialDate;
  final Widget? leading;
  final Widget? trailing;
  final Widget Function(DateTime dateTime, bool selected)? builder;

  void emitNewDate(int year, int month, int day) {
    if (onDateChange != null) {
      onDateChange!(DateTime(year, month, day));
    }
  }

  @override
  Widget build(BuildContext context) {
    final int initialYear = initialDate.year;
    final int initialMonth = initialDate.month;
    final int initialDay = initialDate.day;

    final ValueNotifier<int> vnMonthSelected = ValueNotifier(initialMonth);
    final ScrollController scrollController = ScrollController();

    int year = initialYear;
    int month = initialMonth;
    int day = initialDay;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          children: [
            Flexible(child: leading != null ? leading! : Container()),
            Expanded(
              child: MonthDropDown(
                year: initialYear,
                month: initialMonth,
                height: heigthMonth,
                width: widthMonth,
                onChanged: (value) {
                  if (value == null) return;
                  month = value + 1;
                  vnMonthSelected.value = month;
                  scrollController.animateTo(0, duration: const Duration(seconds: 1), curve: Curves.easeInSine);
                  if (onMonthChange != null) {
                    onMonthChange!(month);
                  }
                  emitNewDate(year, month, day);
                },
              ),
            ),
            Flexible(child: trailing != null ? trailing! : Container()),
          ],
        ),
        ValueListenableBuilder(
          valueListenable: vnMonthSelected,
          builder: (_, int monthSelected, __) {
            return DayTimeline(
              scrollController: scrollController,
              year: initialYear,
              month: monthSelected,
              initialDay: day,
              selectedDayTextStyle: selectedDayTextStyle,
              selectedColor: selectedDayColor,
              unselectedColor: unselectedDayColor,
              builder: builder,
              onDaySelect: (int daySelected) {
                day = daySelected;
                emitNewDate(year, month, day);
              },
            );
          },
        )
      ],
    );
  }
}

class MonthDropDown extends StatelessWidget {
  MonthDropDown({Key? key, required this.year, required this.month, required this.onChanged, this.height, this.width}) : super(key: key);

  final int year;
  final int month;
  final double? height;
  final double? width;
  final ValueChanged<int?> onChanged;

  final List<String> monthList = ['Jan.', 'Fév.', 'Mar.', 'Avr.', 'Mai', 'Juin', 'Juil.', 'Aout', 'Sep.', 'Oct.', 'Nov.', 'Déc.'];
  final GlobalKey gkKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    List<DropdownMenuItem<int>> listDropdown = [];
    for (int i = 0; i < monthList.length; i++) {
      listDropdown.add(
        DropdownMenuItem(
          child: Center(
            child: RichText(
              text: TextSpan(
                text: monthList.elementAt(i),
                style: TextStyle(
                  color: Theme
                      .of(context)
                      .primaryColor,
                  fontSize: 18,
                ),
                children: [
                  TextSpan(
                    text: year.toString(),
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                ],
              ),
            ),
          ),
          value: i,
        ),
      );
    }
    return SizedBox(
      width: width,
      height: height,
      child: DropdownButtonFormField<int>(
        key: gkKey,
        decoration: InputDecoration(
            constraints: BoxConstraints(
              minHeight: height ?? 50,
              minWidth: width ?? double.infinity,
            )),
        items: listDropdown,
        value: month - 1,
        elevation: month,
        onChanged: onChanged,
      ),
    );
  }
}

class DayTimeline extends StatelessWidget {
  const DayTimeline({
    Key? key,
    required this.year,
    required this.month,
    this.builder,
    required this.initialDay,
    required this.scrollController,
    required this.onDaySelect,
    this.unselectedColor,
    this.selectedColor,
    this.selectedDayTextStyle,
    this.unselectedDayTextStyle,
  }) : super(key: key);

  final int year;
  final int month;
  final int initialDay;
  final Color? unselectedColor;
  final Color? selectedColor;
  final TextStyle? selectedDayTextStyle;
  final TextStyle? unselectedDayTextStyle;
  final ScrollController scrollController;
  final Widget Function(DateTime dateTime, bool selected)? builder;
  final void Function(int daySelected) onDaySelect;

  @override
  Widget build(BuildContext context) {
    final ValueNotifier<int> vnDaySelected = ValueNotifier(initialDay);

    List<DateTime> listDateTime = [];
    DateTime lastDay = DateTime(year, month + 1, 0);
    for (int i = 1; i < lastDay.day + 1; i++) {
      listDateTime.add(DateTime(year, month, i));
    }

    WidgetsBinding.instance?.addPostFrameCallback((_) {
      double maxScroll = scrollController.position.maxScrollExtent;
      double offsetOfInitialDay = (maxScroll / lastDay.day) * initialDay;
      scrollController.jumpTo(offsetOfInitialDay);
    });

    return SingleChildScrollView(
      controller: scrollController,
      scrollDirection: Axis.horizontal,
      child: ValueListenableBuilder<int>(
        valueListenable: vnDaySelected,
        builder: (_, selectedDay, __) =>
            Row(
              children: listDateTime.map((dateTime) {
                bool isSelected = selectedDay == dateTime.day;
                if (builder != null) {
                  return GestureDetector(
                    child: builder!(dateTime, isSelected),
                    onTap: () {
                      vnDaySelected.value = dateTime.day;
                      onDaySelect(dateTime.day);
                    },
                  );
                } else {
                  return Card(
                    color: isSelected ? (selectedColor ?? Colors.amber) : (unselectedColor ?? Colors.white),
                    child: InkWell(
                      onTap: () {
                        vnDaySelected.value = dateTime.day;
                        onDaySelect(dateTime.day);
                      },
                      child: SizedBox(
                        height: 50,
                        width: 50,
                        child: Center(
                          child: Text(
                            dateTime.day.toString(),
                            style: isSelected ? selectedDayTextStyle : unselectedDayTextStyle,
                          ),
                        ),
                      ),
                    ),
                  );
                }
              }).toList(),
            ),
      ),
    );
  }
}

class CalendarPage extends StatelessWidget {
  CalendarPage({Key? key}) : super(key: key);

  final CalendarController controller = Get.put(CalendarController());
  final DaySelectionController daySelectionController = Get.find();
  final HomeController homeController = Get.find();

  @override
  Widget build(BuildContext context) {
    daySelectionController.changeInitialDate(DateTime.now());
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
        onPressed: () {
          controller.createNewWorkoutInstance(daySelectionController.selectedDate).then((_) => print('Création instance'));
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: Center(
        child: Column(
          children: <Widget>[
            StreamBuilder<List<WorkoutInstance>>(
                stream: controller.workoutInstanceService.listenAll(),
                builder: (_, snapshot) {
                  List<WorkoutInstance> list = snapshot.hasData ? snapshot.data! : [];
                  return Obx(
                        () =>
                        FitnessDatePicker(
                          trailing: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () {
                                  daySelectionController.changeInitialDate(DateTime.now());
                                  daySelectionController.selectedDate = DateTime.now();
                                },
                                child: Text('Today'),
                              ),
                            ],
                          ),
                          widthMonth: 150,
                          initialDate: daySelectionController.initialDate.value,
                          onDateChange: (date) => daySelectionController.selectedDate = date,
                          builder: (dateTime, selected) {
                            List<DateTime> listWorkoutForTheDay = list
                                .where((workout) => workout.date != null)
                                .map((workout) => workout.date)
                                .map((date) => DateTime(date!.year, date.month, date.day))
                                .where((date) => date.compareTo(dateTime) == 0)
                                .take(4)
                                .toList();
                            return CalendarDayCard(
                              dateTime: dateTime,
                              listWorkoutForTheDay: listWorkoutForTheDay,
                              selected: selected,
                            );
                          },
                          selectedDayTextStyle: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                  );
                }),
            Expanded(
              child: Obx(
                    () =>
                    StreamBuilder<List<WorkoutInstance>>(
                      initialData: const <WorkoutInstance>[],
                      stream: controller.listenWorkoutInstanceByDate(daySelectionController.selectedDate),
                      builder: (_, snapshot) {
                        if (snapshot.hasData) {
                          final List<WorkoutInstance> list = snapshot.data!;
                          if (list.isNotEmpty) {
                            return Center(
                              child: Column(
                                children: [
                                  ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: list.length,
                                    padding: EdgeInsets.all(8),
                                    itemBuilder: (_, index) {
                                      final WorkoutInstance workoutInstance = list.elementAt(index);
                                      return WorkoutInstanceCard(
                                        instance: workoutInstance,
                                      );
                                    },
                                  ),
                                ],
                              ),
                            );
                          } else {
                            return Center(
                              child: Text('Aucun élément'),
                            );
                          }
                        }
                        if (snapshot.hasError) {
                          return Text(snapshot.error.toString());
                        }
                        return LoadingBouncingGrid.circle(
                          backgroundColor: Theme
                              .of(context)
                              .primaryColor,
                        );
                      },
                    ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class CalendarDayCard extends StatelessWidget {
  const CalendarDayCard({
    Key? key,
    required this.listWorkoutForTheDay,
    required this.selected,
    required this.dateTime,
  }) : super(key: key);

  final List<DateTime> listWorkoutForTheDay;
  final bool selected;
  final DateTime dateTime;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: selected ? Colors.amber : Colors.white,
      child: SizedBox(
        height: 40,
        width: 50,
        child: Column(
          children: [
            Expanded(
              flex: 2,
              child: Center(
                child: Text(
                  dateTime.day.toString(),
                  style: selected ? TextStyle(color: Colors.white) : TextStyle(color: Colors.black),
                ),
              ),
            ),
            Flexible(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: listWorkoutForTheDay
                    .map((e) =>
                const Icon(
                  Icons.circle,
                  size: 5,
                  color: Colors.green,
                ))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WorkoutInstanceCard extends StatelessWidget {
  WorkoutInstanceCard({Key? key, required this.instance}) : super(key: key);

  final CalendarController controller = Get.find();
  final WorkoutInstance instance;

  @override
  Widget build(BuildContext context) {
    String dateStr = '';
    if (instance.date != null) {
      dateStr = DateFormat('dd/MM/yyyy - kk:mm').format(instance.date!);
    }

    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      elevation: 5,
      child: InkWell(
        onTap: () =>
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) =>
                    WorkoutPage(
                      instance: instance,
                    ),
              ),
            ),
        child: Stack(
          children: <Widget>[
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    left: 20,
                    right: 12,
                    top: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        dateStr,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      PopupMenuButton<dynamic>(
                        iconSize: 24,
                        tooltip: 'Voir plus',
                        icon: const Icon(Icons.more_horiz, color: Colors.grey),
                        itemBuilder: (_) =>
                        <PopupMenuItem<dynamic>>[
                          PopupMenuItem<dynamic>(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: const <Widget>[
                                Text('Supprimer'),
                                Icon(
                                  Icons.delete,
                                  color: Colors.grey,
                                ),
                              ],
                            ),
                            onTap: () => controller.deleteWorkout(instance),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                StreamList<UserSet>(
                  stream: controller.listenUserSet(instance),
                  physics: const NeverScrollableScrollPhysics(),
                  builder: (context, set) {
                    return Padding(
                      padding: const EdgeInsets.only(
                        left: 20,
                        right: 12,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Flexible(
                            child: Column(
                              children: [
                                if (set.nameExercice != null) Text(set.nameExercice!),
                              ],
                            ),
                          ),
                          Flexible(
                            child: IconButton(
                              onPressed: () => controller.deleteUserSet(set),
                              icon: Icon(Icons.delete, color: Colors.grey, size: 20),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ButtonBar(
                      children: [
                        TextButton.icon(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => ExerciceChoiceDialog(workoutInstance: instance),
                            );
                          },
                          icon: const Icon(
                            Icons.add_circle_outline_outlined,
                          ),
                          label: const Text(
                            'Ajouter un exercice',
                          ),
                        ),
                      ],
                    )
                  ],
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
