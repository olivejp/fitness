import 'package:fitnc_user/page/workout/workout-instance.page.dart';
import 'package:fitnc_user/service/exercice.service.dart';
import 'package:fitnc_user/service/user-set.service.dart';
import 'package:fitnc_user/service/workout-instance.service.dart';
import 'package:fitnc_user/widget/network_image.widget.dart';
import 'package:fitness_domain/mixin/search.mixin.dart';
import 'package:fitness_domain/domain/exercice.domain.dart';
import 'package:fitness_domain/domain/user.set.domain.dart';
import 'package:fitness_domain/domain/workout-instance.domain.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animations/loading_animations.dart';

import 'add_exercice.page.dart';

class ExerciseChoiceDialogController extends GetxController
    with SearchMixin<Exercice> {
  final ExerciceService service = Get.find();
  final UserSetService userSetService = Get.find();
  final WorkoutInstanceService workoutInstanceService = Get.find();
  final RxList<Exercice> listChosen = <Exercice>[].obs;
  final WorkoutPageController workoutPageController =
      Get.put(WorkoutPageController());

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
    if (listChosen
        .map((element) => element.uid)
        .toList()
        .contains(exercise.uid)) {
      listChosen.removeWhere((element) => element.uid == exercise.uid);
    } else {
      listChosen.add(exercise);
    }
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
          workoutPageController.refreshWorkoutPage();
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
    Key? key,
    this.workoutInstance,
    this.popOnChoice = false,
    this.isCreation = false,
    this.date,
  })  : assert(
            ((isCreation && workoutInstance == null) ||
                (!isCreation && workoutInstance != null)),
            "If isCreation then workoutInstance should be null."),
        assert((isCreation && date != null) || ((!isCreation && date == null)),
            "If isCreation, date should not be null."),
        super(key: key);
  final ExerciseChoiceDialogController controller =
      Get.put(ExerciseChoiceDialogController());
  final WorkoutPageController workoutPageController =
      Get.put(WorkoutPageController());
  final WorkoutInstance? workoutInstance;
  final bool popOnChoice;
  final bool isCreation;
  final DateTime? date;
  final TextEditingController searchTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    controller.initListSelected();
    controller.initSearchList(getStreamList: controller.service.listenAll);
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (isCreation) {
            controller.createNewWorkoutInstance(date!).then((instance) =>
                controller.validate(context, popOnChoice, instance));
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
          'exerciseChoice'.tr,
          style: Theme.of(context).textTheme.headline3?.copyWith(
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
                border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(25))),
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  onPressed: () {
                    controller.clearSearch();
                    searchTextController.clear();
                  },
                  icon: const Icon(Icons.clear),
                ),
                hintText: 'searching'.tr,
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        elevation: 5,
        color: Colors.white,
        child: SizedBox(
          height: 60,
          child: Padding(
            padding: const EdgeInsets.only(left: 5, right: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  label: Text('createExercise'.tr),
                  icon: const Icon(Icons.add_circle_outline_rounded),
                  onPressed: () {
                    if (popOnChoice) {
                      Navigator.of(context).pop();
                    } else {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => AddExercisePage(
                            exercise: null,
                          ),
                        ),
                      );
                    }
                  },
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('cancel'.tr),
                ),
              ],
            ),
          ),
        ),
      ),
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
                        return InkWell(
                          onTap: () => controller.toggle(exercice),
                          child: Obx(
                            () => ExerciseChoiceCard(
                              exercise: exercice,
                              selected: controller.listChosen
                                  .map((element) => element.uid)
                                  .toList()
                                  .contains(exercice.uid),
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (BuildContext context, int index) =>
                          const Divider(
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
  }
}

class ExerciseChoiceCard extends StatelessWidget {
  const ExerciseChoiceCard({
    Key? key,
    required this.exercise,
    required this.selected,
  }) : super(key: key);
  final Exercice exercise;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
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
                child: Text(
                  exercise.name,
                  textAlign: TextAlign.start,
                ),
              ),
            ),
            Icon(
              selected ? Icons.check_circle : Icons.circle_outlined,
              color: selected ? Colors.green : Colors.grey,
            )
          ],
        ),
      ),
    );
  }
}
