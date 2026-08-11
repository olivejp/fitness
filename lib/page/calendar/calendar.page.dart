import 'package:fitnc_user/l10n/l10n.dart';
import 'package:fitnc_user/page/exercice-choice/exercice-choice.widget.dart';
import 'package:fitnc_user/page/workout-instance/workout-instance.page.dart';
import 'package:fitnc_user/widget/fitness-date-picker.widget.dart';
import 'package:fitnc_user/domain/user-set.domain.dart';
import 'package:fitnc_user/domain/workout-instance.domain.dart';
import 'package:fitnc_user/widget/generic-container.widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:fitnc_user/page/calendar/calendar.notifier.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({Key? key}) : super(key: key);

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  final CalendarNotifier notifier = CalendarNotifier();

  @override
  void dispose() {
    notifier.dispose();
    super.dispose();
  }

  void goToExerciseChoice(BuildContext context) {
    notifier.initialDate.value = notifier.selectedDate.value;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ExerciseChoiceDialog(
          isCreation: true,
          date: notifier.selectedDate.value,
          workoutInstance: null,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => goToExerciseChoice(context),
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
      body: Column(
        children: <Widget>[
          Material(
            elevation: 5,
            child: StreamBuilder<List<WorkoutInstance>>(
                stream: notifier.workoutInstanceService.listenAll(),
                builder: (_, snapshot) {
                  List<WorkoutInstance> list =
                      snapshot.hasData ? snapshot.data! : [];
                  return Timeline(list: list, notifier: notifier);
                }),
          ),
          Expanded(
            child: ValueListenableBuilder<DateTime>(
              valueListenable: notifier.selectedDate,
              builder: (_, DateTime selectedDate, __) => StreamList<WorkoutInstance>(
                stream: notifier.listenWorkoutInstanceByDate(selectedDate),
                builder: (BuildContext context, WorkoutInstance domain) =>
                    WorkoutInstanceCard(instance: domain, notifier: notifier),
                padding: const EdgeInsets.only(top: 10),
                separatorBuilder: (_, index) => const Divider(
                  height: 20,
                  // thickness: 20,
                ),
                emptyWidget: Column(
                  children: [
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Text('Aucun entrainement !', style: TextStyle(fontWeight: FontWeight.w900),),
                            Text("Vous n'avez fait aucune séance d'entrainement pour ce jour.", style: TextStyle(fontWeight: FontWeight.w900)),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class Timeline extends StatelessWidget {
  const Timeline({
    Key? key,
    required this.list,
    required this.notifier,
  }) : super(key: key);

  final List<WorkoutInstance> list;
  final CalendarNotifier notifier;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<DateTime>(
      valueListenable: notifier.initialDate,
      builder: (_, DateTime initialDate, __) => FitnessDatePicker(
        heigthMonth: 48,
        initialDate: initialDate,
        onDateChange: (date) {
          notifier.selectedDate.value = date;
        },
        selectedDayTextStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        trailing: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: OutlinedButton(
                onPressed: () {
                  notifier.initialDate.value = DateTime.now();
                  notifier.selectedDate.value = DateTime.now();
                },
                child: Text(
                  context.l10n.today,
                  style: GoogleFonts.comfortaa(),
                ),
              ),
            ),
          ],
        ),
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
    return Container(
      decoration: BoxDecoration(
        border: (selected)
            ? Border(
                bottom: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                  width: 4,
                ),
              )
            : null,
      ),
      child: SizedBox(
        height: 30,
        width: 50,
        child: Column(
          children: [
            Expanded(
              flex: 2,
              child: Center(
                child: Text(
                  dateTime.day.toString(),
                  style: GoogleFonts.comfortaa(
                    color: selected ? Theme.of(context).colorScheme.primary : null,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            Flexible(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: listWorkoutForTheDay
                    .map((e) => Icon(
                          Icons.circle,
                          size: 5,
                          color:
                              selected ? Theme.of(context).colorScheme.primary : null,
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
  const WorkoutInstanceCard(
      {Key? key, required this.instance, required this.notifier})
      : super(key: key);

  final CalendarNotifier notifier;
  final WorkoutInstance instance;

  @override
  Widget build(BuildContext context) {
    String dateStr = '';
    if (instance.date != null) {
      dateStr = DateFormat('dd/MM/yyyy - kk:mm').format(instance.date!);
    }

    return Material(
      elevation: 3,
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => WorkoutPage(
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
                      Row(
                        children: [
                          Text(
                            dateStr,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          StreamBuilder<bool>(
                              stream: notifier.areAllChecked(instance.uid!),
                              initialData: false,
                              builder: (_, snapshot) {
                                if (snapshot.hasData && snapshot.data!) {
                                  return const Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 8),
                                    child: Icon(
                                      Icons.verified_rounded,
                                      color: Colors.green,
                                    ),
                                  );
                                } else {
                                  return Container();
                                }
                              }),
                        ],
                      ),
                      PopupMenuButton<int>(
                        iconSize: 24,
                        tooltip: context.l10n.showMore,
                        icon: const Icon(Icons.more_horiz, color: Colors.grey),
                        onSelected: (value) {
                          notifier.initialDate.value = notifier.selectedDate.value;
                          switch (value) {
                            case 1:
                              showDialog(
                                context: context,
                                builder: (context) {
                                  DateTime dateSelected = instance.date!;
                                  return AlertDialog(
                                    content: SizedBox(
                                      height: 500,
                                      width: 1200,
                                      child: DateChangePicker(
                                        initialDate: instance.date,
                                        onDateChanged: (dateTime) =>
                                            dateSelected = dateTime,
                                      ),
                                    ),
                                    actions: [
                                      TextButton.icon(
                                        onPressed: () {
                                          notifier.updateDate(
                                              instance, dateSelected);
                                          Navigator.of(context).pop();
                                        },
                                        icon: const Icon(Icons.check),
                                        label: Text(context.l10n.validate),
                                      ),
                                      TextButton.icon(
                                        onPressed: () =>
                                            Navigator.of(context).pop(),
                                        icon: const Icon(Icons.clear),
                                        label: Text(context.l10n.cancel),
                                      )
                                    ],
                                  );
                                },
                              );
                              break;
                            case 2:
                              notifier.deleteWorkout(instance);
                              break;
                          }
                        },
                        itemBuilder: (BuildContext buildContext) =>
                            <PopupMenuItem<int>>[
                          PopupMenuItem<int>(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(context.l10n.updateDate),
                                const Icon(
                                  Icons.calendar_today_outlined,
                                  color: Colors.grey,
                                ),
                              ],
                            ),
                            value: 1,
                          ),
                          PopupMenuItem<int>(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(context.l10n.delete),
                                const Icon(
                                  Icons.delete,
                                  color: Colors.grey,
                                ),
                              ],
                            ),
                            value: 2,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                StreamList<UserSet>(
                  showLoading: true,
                  stream: notifier.listenUserSet(instance),
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
                                if (set.nameExercice != null)
                                  Text(set.nameExercice!),
                              ],
                            ),
                          ),
                          Flexible(
                            child: IconButton(
                              onPressed: () => notifier.deleteUserSet(set),
                              icon: const Icon(Icons.delete,
                                  color: Colors.grey, size: 20),
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
                              builder: (context) => ExerciseChoiceDialog(
                                  workoutInstance: instance),
                            );
                          },
                          icon: const Icon(
                            Icons.add_circle_outline_outlined,
                          ),
                          label: Text(
                            context.l10n.addExercise,
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
