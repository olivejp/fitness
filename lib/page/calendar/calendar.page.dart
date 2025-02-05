import 'package:fitnc_user/page/calendar/calendar-workout-instance-card.widget.dart';
import 'package:fitnc_user/service/calendar_service.dart';
import 'package:fitnc_user/widget/time_line.widget.dart';
import 'package:fitness_domain/domain/workout-instance.domain.dart';
import 'package:fitness_domain/widget/generic_container.widget.dart';
import 'package:flutter/material.dart';
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
