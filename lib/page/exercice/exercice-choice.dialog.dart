import 'dart:async';

import 'package:fitnc_user/page/workout/workout-instance.page.dart';
import 'package:fitnc_user/service/exercice.service.dart';
import 'package:fitnc_user/service/user-set.service.dart';
import 'package:fitnc_user/service/workout-instance.service.dart';
import 'package:fitnc_user/widget/network_image.widget.dart';
import 'package:fitness_domain/domain/exercice.domain.dart';
import 'package:fitness_domain/domain/user.set.domain.dart';
import 'package:fitness_domain/domain/workout-instance.domain.dart';
import 'package:fitness_domain/mixin/search.mixin.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animations/loading_animations.dart';
import 'package:localization/localization.dart';
import 'package:provider/provider.dart';

class ExerciseChoiceDialogController extends ChangeNotifier with SearchMixin<Exercice> {
  final ExerciceService service = GetIt.I.get();
  final UserSetService userSetService = GetIt.I.get();
  final WorkoutInstanceService workoutInstanceService = GetIt.I.get();

  final List<Exercice> listChosen = <Exercice>[];

  Future<WorkoutInstance> createNewWorkoutInstance(DateTime dateTime) async {
    DateTime now = DateTime.now();
    WorkoutInstance instance = WorkoutInstance();
    instance.date = DateTime(
      dateTime.year,
      dateTime.month,
      dateTime.day,
      now.hour,
      now.minute,
      now.second,
    );
    workoutInstanceService.create(instance);
    return instance;
  }

  Stream<List<Exercice>> listenAllExercise() {
    return service.listenAll();
  }

  void toggle(Exercice exercise) {
    if (listChosen.map((element) => element.uid).toList().contains(exercise.uid)) {
      listChosen.removeWhere((element) => element.uid == exercise.uid);
    } else {
      listChosen.add(exercise);
    }
    notifyListeners();
  }

  void initListSelected() {
    listChosen.clear();
  }

  void validate(
    BuildContext context,
    bool popOnChoice,
    WorkoutInstance workoutInstance,
  ) {
    _addUserSet(workoutInstance).then(
      (userSet) {
        if (popOnChoice) {
          // TODO Sur le clik on doit rafraichir le UserSet.
          Provider.of<WorkoutPageController>(context, listen: false).refreshWorkoutPage();
          Navigator.of(context).pop();
        } else {
          Navigator.of(context).pop();
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => WorkoutPage(
                instance: workoutInstance,
                goToLastPage: true,
              ),
            ),
          );
        }
      },
    );
  }

  Future<void> _addUserSet(WorkoutInstance workoutInstance) async {
    for (Exercice exercise in listChosen) {
      final UserSet userSet = UserSet(
          uidExercice: exercise.uid!,
          uidWorkout: workoutInstance.uid!,
          nameExercice: exercise.name,
          imageUrlExercice: exercise.imageUrl,
          typeExercice: exercise.typeExercice,
          date: workoutInstance.date);
      userSetService.save(userSet);
    }
  }
}

class ExerciseChoiceDialog extends StatelessWidget {
  ExerciseChoiceDialog({
    super.key,
    this.workoutInstance,
    this.popOnChoice = false,
    this.isCreation = false,
    this.date,
  })  : assert(((isCreation && workoutInstance == null) || (!isCreation && workoutInstance != null)),
            "If isCreation then workoutInstance should be null."),
        assert(
            (isCreation && date != null) || ((!isCreation && date == null)), "If isCreation, date should not be null.");
  final WorkoutInstance? workoutInstance;
  final bool popOnChoice;
  final bool isCreation;
  final DateTime? date;
  final TextEditingController searchTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
        value: ExerciseChoiceDialogController(),
        builder: (context, child) {
          final ExerciseChoiceDialogController controller =
              Provider.of<ExerciseChoiceDialogController>(context, listen: false);
          controller.initListSelected();
          controller.initSearchList(getStreamList: controller.service.listenAll);
          return Scaffold(
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                if (isCreation) {
                  controller
                      .createNewWorkoutInstance(date!)
                      .then((instance) => controller.validate(context, popOnChoice, instance));
                } else {
                  controller.validate(context, popOnChoice, workoutInstance!);
                }
              },
              child: const Icon(
                Icons.check,
                color: Colors.white,
              ),
            ),
            appBar: AppBar(
              elevation: 0,
              title: Text(
                'exerciseChoice'.i18n(),
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: Theme.of(context).primaryColor,
                    ),
              ),
              foregroundColor: Colors.transparent,
              backgroundColor: Colors.transparent,
              bottom: PreferredSize(
                preferredSize: const Size(double.infinity, 50),
                child: Padding(
                  padding: const EdgeInsets.only(left: 12, right: 12),
                  child: TextFormField(
                    controller: searchTextController,
                    onChanged: controller.search,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.all(5),
                      border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(25))),
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: IconButton(
                        onPressed: () {
                          controller.clearSearch();
                          searchTextController.clear();
                        },
                        icon: const Icon(Icons.clear),
                      ),
                      hintText: 'searching'.i18n(),
                    ),
                  ),
                ),
              ),
            ),
            // bottomNavigationBar: BottomAppBar(
            //   elevation: 5,
            //   color: Colors.white,
            //   child: SizedBox(
            //     height: 60,
            //     child: Padding(
            //       padding: const EdgeInsets.only(left: 5, right: 5),
            //       child: Row(
            //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //         children: [
            //           TextButton.icon(
            //             label: Text('createExercise'.i18n()),
            //             icon: const Icon(Icons.add_circle_outline_rounded),
            //             onPressed: () {
            //               if (popOnChoice) {
            //                 Navigator.of(context).pop();
            //               } else {
            //                 Navigator.of(context).push(
            //                   MaterialPageRoute(
            //                     builder: (_) => AddExercisePage(
            //                       exercise: null,
            //                     ),
            //                   ),
            //                 );
            //               }
            //             },
            //           ),
            //           TextButton(
            //             onPressed: () => Navigator.of(context).pop(),
            //             child: Text('cancel'.i18n()),
            //           ),
            //         ],
            //       ),
            //     ),
            //   ),
            // ),
            body: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: SizedBox(
                    width: 1000,
                    child: StreamBuilder<List<Exercice>>(
                      stream: controller.streamList,
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Text(snapshot.error.toString());
                        }
                        if (snapshot.hasData) {
                          final List<Exercice> listExercise = snapshot.data!;
                          return ListView.separated(
                            shrinkWrap: true,
                            itemCount: listExercise.length,
                            itemBuilder: (context, index) {
                              final Exercice exercice = listExercise.elementAt(index);
                              return Consumer<ExerciseChoiceDialogController>(builder: (context, notifier, child) {
                                return ExerciseChoiceCard(
                                  exercise: exercice,
                                  showSelect: true,
                                  onTap: () => notifier.toggle(exercice),
                                  selected:
                                      notifier.listChosen.map((element) => element.uid).toList().contains(exercice.uid),
                                );
                              });
                            },
                            separatorBuilder: (BuildContext context, int index) => const Divider(
                              height: 2.0,
                              color: Colors.grey,
                            ),
                          );
                        }
                        return LoadingBouncingGrid.circle(
                          backgroundColor: Theme.of(context).primaryColor,
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }
}

class ExerciseChoiceCard extends StatelessWidget {
  const ExerciseChoiceCard({
    super.key,
    required this.exercise,
    required this.selected,
    this.showSelect = false,
    required this.onTap,
  });

  final Exercice exercise;
  final bool selected;
  final bool showSelect;
  final GestureTapCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: 80,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              NetworkImageExerciseChoice(
                imageUrl: exercise.imageUrl,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 12, right: 12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              exercise.name,
                              textAlign: TextAlign.start,
                              style: GoogleFonts.nunito(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          Text(
                            exercise.typeExercice ?? '',
                            style: GoogleFonts.nunito(fontSize: 10),
                          ),
                        ],
                      ),
                      if (exercise.description.isNotEmpty)
                        Text(
                          exercise.description,
                          textAlign: TextAlign.start,
                          style: GoogleFonts.nunito(fontSize: 12),
                        ),
                    ],
                  ),
                ),
              ),
              if (showSelect)
                Icon(
                  selected ? Icons.check_circle : Icons.circle_outlined,
                  color: selected ? Colors.green : Colors.grey,
                )
            ],
          ),
        ),
      ),
    );
  }
}
