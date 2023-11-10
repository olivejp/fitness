import 'package:fitnc_user/constants.dart';
import 'package:fitnc_user/page/exercice/exercice-choice.dialog.dart';
import 'package:fitnc_user/page/workout/workout-instance.page.dart';
import 'package:fitnc_user/service/debug_printer.dart';
import 'package:fitnc_user/widget/fitness-date-picker.widget.dart';
import 'package:fitness_domain/domain/user.set.domain.dart';
import 'package:fitness_domain/domain/workout-instance.domain.dart';
import 'package:fitness_domain/widget/generic_container.widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:localization/localization.dart';
import 'package:provider/provider.dart';

import 'calendar.page.controller.dart';

class TodayNotifier extends ChangeNotifier {
  void onTodayClick() {
    notifyListeners();
  }
}

class CalendarPage extends StatelessWidget {
  const CalendarPage({super.key});

  void goToExerciseChoice(BuildContext context) {
    final CalendarNotifier controller = Provider.of<CalendarNotifier>(context, listen: false);
    controller.initialDate = controller.selectedDate;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ExerciseChoiceDialog(
          isCreation: true,
          date: controller.selectedDate,
          workoutInstance: null,
        ),
      ),
    );
  }

  void goToTypeWorkoutChoice(BuildContext context) {
    final CalendarNotifier controller = Provider.of<CalendarNotifier>(context, listen: false);
    controller.initialDate = controller.selectedDate;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ExerciseChoiceDialog(
          isCreation: true,
          date: controller.selectedDate,
          workoutInstance: null,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: CalendarNotifier()),
          ChangeNotifierProvider.value(value: TodayNotifier()),
        ],
        builder: (context, child) {
          final CalendarNotifier notifierReadOnly = Provider.of<CalendarNotifier>(context, listen: false);
          DebugPrinter.printLn('Building CalendarPage');
          notifierReadOnly.initialDate = DateTime.now();
          notifierReadOnly.selectedDate = DateTime.now();
          return Scaffold(
            appBar: AppBar(
              toolbarHeight: 120,
              title: StreamBuilder<List<WorkoutInstance>>(
                  stream: notifierReadOnly.workoutInstanceService.listenAll(),
                  builder: (_, snapshot) {
                    List<WorkoutInstance> list = snapshot.hasData ? snapshot.data! : [];
                    return Timeline(list: list);
                  }),
            ),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () => goToExerciseChoice(context),
              label: Row(
                children: [
                  Text('createWorkout'.i18n()),
                  const Icon(
                    Icons.add,
                  ),
                ],
              ),
            ),
            body: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Consumer<CalendarNotifier>(builder: (context, notifier, child) {
                    return StreamList<WorkoutInstance>(
                      stream: notifier.listenWorkoutInstanceByDate(notifier.selectedDate),
                      builder: (BuildContext context, WorkoutInstance domain) => WorkoutInstanceCard(instance: domain),
                      padding: const EdgeInsets.only(top: 10),
                      separatorBuilder: (_, index) => const Divider(
                        height: 20,
                        // thickness: 20,
                      ),
                      emptyWidget: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Aucun entrainement !',
                            style: TextStyle(fontWeight: FontWeight.w900),
                          ),
                          Text("Vous n'avez fait aucune séance d'entrainement pour ce jour.",
                              style: TextStyle(fontWeight: FontWeight.w900)),
                        ],
                      ),
                    );
                  }),
                ),
              ],
            ),
          );
        });
  }
}

class Timeline extends StatelessWidget {
  const Timeline({
    super.key,
    required this.list,
  });

  final List<WorkoutInstance> list;

  @override
  Widget build(BuildContext context) {
    DebugPrinter.printLn('Building TimeLine');
    final CalendarNotifier notifierReadOnly = Provider.of<CalendarNotifier>(context, listen: false);
    return Consumer<TodayNotifier>(
      builder: (context, notifier, child) => FitnessDatePicker(
        heigthMonth: 50,
        initialDate: notifierReadOnly.selectedDate,
        onDateChange: notifierReadOnly.selectDateAndNotify,
        selectedDayTextStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        trailing: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: TextButton(
                onPressed: () {
                  notifierReadOnly.initialDate = DateTime.now();
                  notifierReadOnly.selectedDate = DateTime.now();
                  notifierReadOnly.selectDateAndNotify(notifierReadOnly.initialDate);
                  notifier.onTodayClick();
                },
                child: Text(
                  'today'.i18n(),
                  style: GoogleFonts.nunito(),
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
    super.key,
    required this.listWorkoutForTheDay,
    required this.selected,
    required this.dateTime,
  });

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
                  color: Theme.of(context).primaryColor,
                  width: 4,
                ),
              )
            : null,
      ),
      child: SizedBox(
        height: 65,
        width: 50,
        child: Column(
          children: [
            Expanded(
              flex: 2,
              child: Center(
                child: Column(
                  children: [
                    Text(
                      DateFormat('EE').format(dateTime),
                      style: GoogleFonts.nunito(
                        color: selected ? FitnessNcColors.amber : FitnessNcColors.black800,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      dateTime.day.toString(),
                      style: GoogleFonts.nunito(
                        color: selected ? FitnessNcColors.amber : FitnessNcColors.black800,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
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
                          color: selected ? Theme.of(context).primaryColor : null,
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
  const WorkoutInstanceCard({super.key, required this.instance});

  final WorkoutInstance instance;

  @override
  Widget build(BuildContext context) {
    String dateStr = '';
    if (instance.date != null) {
      dateStr = DateFormat('dd/MM/yyyy - kk:mm').format(instance.date!);
    }

    final CalendarNotifier notifier = Provider.of<CalendarNotifier>(context, listen: false);

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
                            style: GoogleFonts.anton(
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
                                    padding: EdgeInsets.symmetric(horizontal: 8),
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
                        tooltip: 'showMore'.i18n(),
                        icon: const Icon(Icons.more_horiz, color: Colors.grey),
                        onSelected: (value) {
                          notifier.initialDate = notifier.selectedDate;
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
                                        onDateChanged: (dateTime) => dateSelected = dateTime,
                                      ),
                                    ),
                                    actions: [
                                      TextButton.icon(
                                        onPressed: () {
                                          notifier.updateDate(instance, dateSelected);
                                          Navigator.of(context).pop();
                                        },
                                        icon: const Icon(Icons.check),
                                        label: Text('validate'.i18n()),
                                      ),
                                      TextButton.icon(
                                        onPressed: () => Navigator.of(context).pop(),
                                        icon: const Icon(Icons.clear),
                                        label: Text('cancel'.i18n()),
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
                        itemBuilder: (BuildContext buildContext) => <PopupMenuItem<int>>[
                          PopupMenuItem<int>(
                            value: 1,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text('updateDate'.i18n()),
                                const Icon(
                                  Icons.calendar_today_outlined,
                                  color: Colors.grey,
                                ),
                              ],
                            ),
                          ),
                          PopupMenuItem<int>(
                            value: 2,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text('delete'.i18n()),
                                const Icon(
                                  Icons.delete,
                                  color: Colors.grey,
                                ),
                              ],
                            ),
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
                                  Text(
                                    set.nameExercice!,
                                    style: GoogleFonts.anton(
                                      fontWeight: FontWeight.w100,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Flexible(
                            child: IconButton(
                              onPressed: () => notifier.deleteUserSet(set),
                              icon: const Icon(Icons.delete, color: Colors.grey, size: 20),
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
                              builder: (context) => ExerciseChoiceDialog(workoutInstance: instance),
                            );
                          },
                          icon: const Icon(
                            Icons.add_circle_outline_outlined,
                          ),
                          label: Text(
                            'addExercise'.i18n(),
                            style: GoogleFonts.anton(),
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
