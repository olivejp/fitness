import 'package:date_picker_timeline/date_picker_widget.dart';
import 'package:fitnc_user/controller/day-selection.controller.dart';
import 'package:fitnc_user/page/exercice/exercice-choice.dialog.dart';
import 'package:fitnc_user/page/home/home.controller.dart';
import 'package:fitnc_user/page/workout/workout-instance.page.dart';
import 'package:fitnc_user/service/user-set.service.dart';
import 'package:fitnc_user/service/workout-instance.service.dart';
import 'package:fitness_domain/domain/user.set.domain.dart';
import 'package:fitness_domain/domain/workout-instance.domain.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:loading_animations/loading_animations.dart';

class CalendarController extends GetxController {
  final WorkoutInstanceService workoutInstanceService = Get.find();
  final UserSetService userSetService = Get.find();

  Stream<List<UserSet>> listenUserSet(WorkoutInstance workoutInstance) {
    return userSetService.listenAll(workoutInstance.uid!);
  }

  Future<void> createNewWorkoutInstance(DateTime dateTime) {
    WorkoutInstance instance = WorkoutInstance();
    instance.date = dateTime;
    return workoutInstanceService.create(instance);
  }

  Stream<List<WorkoutInstance>> listenWorkoutInstanceByDate(DateTime dateTime) {
    return workoutInstanceService.listenByDate(dateTime);
  }

  Stream<List<WorkoutInstance>> listenWorkoutInstanceWhereDateTime(DateTime dateTime) {
    return workoutInstanceService.listenAll();
  }

  Future<void> deleteWorkout(WorkoutInstance instance) {
    return workoutInstanceService.delete(instance);
  }

  Future<void> deleteUserSet(UserSet set) {
    return userSetService.delete(set);
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
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: OutlinedButton(
                        onPressed: () {
                          datePickerController.animateToDate(DateTime.now());
                        },
                        child: Text('Today'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 90,
              child: DatePicker(
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
            ),
            Expanded(
              child: Obx(
                () => StreamBuilder<List<WorkoutInstance>>(
                  initialData: const <WorkoutInstance>[],
                  stream: controller.listenWorkoutInstanceByDate(daySelectionController.selectedDate),
                  builder: (_, snapshot) {
                    datePickerController.animateToDate(DateTime.now());
                    if (snapshot.hasData) {
                      final List<WorkoutInstance> list = snapshot.data!;
                      if (list.isNotEmpty) {
                        return ListView.builder(
                          shrinkWrap: true,
                          itemCount: list.length,
                          padding: EdgeInsets.all(8),
                          itemBuilder: (_, index) {
                            final WorkoutInstance workoutInstance = list.elementAt(index);
                            return WorkoutInstanceCard(
                              instance: workoutInstance,
                            );
                          },
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
                    return LoadingBouncingGrid.circle();
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
                StreamBuilder<List<UserSet>>(
                  stream: controller.listenUserSet(instance),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Text("Erreur lors de la récupération des UserSet pour le workout ${instance.uid} : ${snapshot.error.toString()}");
                    }
                    if (snapshot.hasData) {
                      final List<UserSet> userSets = snapshot.data!;
                      if (userSets.isEmpty) {
                        return Container();
                      } else {
                        return ListView.builder(
                          shrinkWrap: true,
                          itemCount: userSets.length,
                          itemBuilder: (context, index) {
                            final UserSet set = userSets.elementAt(index);
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
                                      icon: Icon(
                                        Icons.delete,
                                        color: Colors.grey,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      }
                    }
                    return LoadingBouncingGrid.circle();
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
