import 'package:fitnc_user/page/exercice/exercice-choice.dialog.dart';
import 'package:fitnc_user/page/workout/workout-instance.page.dart';
import 'package:fitnc_user/widget/date-picker.widget.dart';
import 'package:fitness_domain/domain/user.set.domain.dart';
import 'package:fitness_domain/domain/workout-instance.domain.dart';
import 'package:fitness_domain/widget/generic_container.widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'calendar.page.controller.dart';

class CalendarPage extends StatelessWidget {
  CalendarPage({Key? key}) : super(key: key);

  final CalendarController controller = Get.put(CalendarController());

  @override
  Widget build(BuildContext context) {
    controller.initialDate = DateTime.now();
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
        onPressed: () {
          controller.initialDate = controller.selectedDate;
          controller.createNewWorkoutInstance(controller.selectedDate).then((_) {
            print('Création réussie');
          });
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: Column(
        children: <Widget>[
          StreamBuilder<List<WorkoutInstance>>(
              stream: controller.workoutInstanceService.listenAll(),
              builder: (_, snapshot) {
                List<WorkoutInstance> list = snapshot.hasData ? snapshot.data! : [];
                return Obx(
                  () => FitnessDatePicker(
                    trailing: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: OutlinedButton(
                            onPressed: () {
                              controller.initialDate = DateTime.now();
                              controller.selectedDate = DateTime.now();
                            },
                            child: Text('Today'),
                          ),
                        ),
                      ],
                    ),
                    widthMonth: 150,
                    initialDate: controller.initialDate,
                    onDateChange: (date) {
                      controller.selectedDate = date;
                    },
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
              () => StreamList<WorkoutInstance>(
                stream: controller.listenWorkoutInstanceByDate(controller.selectedDate),
                builder: (BuildContext context, WorkoutInstance domain) => WorkoutInstanceCard(instance: domain),
              ),
            ),
          )
        ],
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
      color: selected ? Theme.of(context).primaryColor : Theme.of(context).cardColor,
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
                  style: GoogleFonts.roboto(
                    color: selected ? Colors.white : Colors.black,
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
                          color: selected ? Colors.white : Colors.black,
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
                        itemBuilder: (_) => <PopupMenuItem<dynamic>>[
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
