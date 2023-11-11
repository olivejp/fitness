import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitnc_user/page/workout/workout-instance.page.dart';
import 'package:fitnc_user/service/calendar_service.dart';
import 'package:fitnc_user/widget/fitness-date-picker.widget.dart';
import 'package:fitnc_user/widget/time_line.widget.dart';
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

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: CalendarNotifier()),
          ChangeNotifierProvider.value(value: TodayNotifier()),
        ],
        builder: (context, child) {
          final CalendarNotifier notifierReadOnly = Provider.of<CalendarNotifier>(context, listen: false);
          notifierReadOnly.initialDate = DateTime.now();
          notifierReadOnly.selectedDate = DateTime.now();
          return Scaffold(
            appBar: AppBar(
              toolbarHeight: 120,
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: StreamBuilder<List<WorkoutInstance>>(
                        stream: notifierReadOnly.workoutInstanceService.listenAll(),
                        builder: (_, snapshot) {
                          final List<WorkoutInstance> list = snapshot.hasData ? snapshot.data! : [];
                          return Timeline(list: list);
                        }),
                  ),
                ],
              ),
            ),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () {
                notifierReadOnly.initialDate = notifierReadOnly.selectedDate;
                WorkoutUtility.goToWorkoutTypeChoice(
                    context: context,
                    onTypeWorkoutChoice: (typeWorkout) {
                      Navigator.of(context, rootNavigator: true).pop();
                      WorkoutUtility.goToExerciseChoiceDialog(
                        typeWorkout: typeWorkout,
                        context: context,
                        dateTime: notifierReadOnly.selectedDate,
                        popOnChoice: true,
                        isCreation: true,
                      );
                    });
              },
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
                        color: Colors.transparent,
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

class WorkoutInstanceCard extends StatelessWidget {
  const WorkoutInstanceCard({super.key, required this.instance});

  final WorkoutInstance instance;

  @override
  Widget build(BuildContext context) {
    String dateStr = '';
    if (instance.date != null) {
      dateStr = DateFormat('dd/MM/yyyy - kk:mm')
          .format(DateTime.fromMicrosecondsSinceEpoch((instance.date! as Timestamp).microsecondsSinceEpoch));
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
                          RichText(
                            text: TextSpan(
                                text: dateStr,
                                style: GoogleFonts.anton(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                                children: [
                                  TextSpan(
                                    text: ' ${instance.typeWorkout!.name}',
                                    style: GoogleFonts.antonio(
                                      fontSize: 16,
                                    ),
                                  )
                                ]),
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
                          onPressed: () => WorkoutUtility.goToExerciseChoiceDialog(
                            context: context,
                            workoutInstance: instance,
                            isCreation: false,
                            dateTime: DateTime.fromMicrosecondsSinceEpoch(
                                (instance.date as Timestamp).microsecondsSinceEpoch),
                            popOnChoice: false,
                          ),
                          icon: const Icon(
                            Icons.add_circle_outline_outlined,
                          ),
                          label: Text(
                            'addExercise'.i18n(),
                            style: GoogleFonts.antonio(),
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
