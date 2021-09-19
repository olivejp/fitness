import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_picker_timeline/date_picker_widget.dart';
import 'package:fitnc_user/controller/day-selection.controller.dart';
import 'package:fitnc_user/page/home/home.controller.dart';
import 'package:fitnc_user/service/workout-instance.service.dart';
import 'package:fitness_domain/domain/workout-instance.domain.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:loading_animations/loading_animations.dart';

class CalendarController extends GetxController {
  final WorkoutInstanceService workoutInstanceService = Get.find();

  Stream<List<WorkoutInstance>> listenWorkoutInstanceByDate(DateTime dateTime) {
    return workoutInstanceService.listenByDate(dateTime);
  }

  Stream<List<WorkoutInstance>> listenWorkoutInstanceWhereDateTime(DateTime dateTime) {
    return workoutInstanceService.listenAll();
  }

  Future<void> deleteWorkout(WorkoutInstance instance) {
    return workoutInstanceService.delete(instance);
  }
}

class CalendarPage extends StatelessWidget {
  CalendarPage({Key? key}) : super(key: key);
  final DatePickerController datePickerController = DatePickerController();
  final CalendarController controller = Get.put(CalendarController());
  final DaySelectionController daySelectionController = Get.find();
  final HomeController homeController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 8),
            child: SizedBox(
              height: 30,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.sort),
                  ),
                  OutlinedButton(
                    onPressed: () {
                      datePickerController.animateToDate(DateTime.now());
                    },
                    child: Text('Today'),
                  ),
                ],
              ),
            ),
          ),
          DatePicker(
            DateTime.now().subtract(const Duration(days: 183)),
            daysCount: 365,
            controller: datePickerController,
            dateTextStyle: TextStyle(
              color: Color(Colors.amber.value),
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            initialSelectedDate: DateTime.now(),
            selectionColor: Theme.of(context).primaryColor,
            onDateChange: (DateTime date) => daySelectionController.selectedDate = date,
            locale: "fr_FR",
          ),
          Obx(
            () => StreamBuilder<List<WorkoutInstance>>(
              initialData: const <WorkoutInstance>[],
              stream: controller.listenWorkoutInstanceByDate(daySelectionController.selectedDate),
              builder: (_, snapshot) {
                if (snapshot.hasData) {
                  final List<WorkoutInstance> list = snapshot.data!;
                  if (list.isNotEmpty) {
                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: list.length,
                      itemBuilder: (_, index) {
                        final WorkoutInstance workoutInstance = list.elementAt(index);
                        return WorkoutInstanceCard(
                          instance: workoutInstance,
                        );
                      },
                    );
                  } else {
                    return Expanded(
                      child: Center(
                        child: Text('Aucun élément'),
                      ),
                    );
                  }
                }
                if (snapshot.hasError) {
                  return Text(snapshot.error.toString());
                }
                return Expanded(
                  child: LoadingBouncingGrid.circle(),
                );
              },
            ),
          )
        ],
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
      elevation: 2,
      child: InkWell(
        child: Stack(
          children: <Widget>[
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(dateStr),
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
                          onTap: () => controller.deleteWorkout(instance).then((_) => Navigator.pop(context)),
                        ),
                      ],
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ButtonBar(
                      children: [
                        TextButton.icon(
                          onPressed: () {},
                          icon: Icon(
                            Icons.add,
                          ),
                          label: Text(
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
