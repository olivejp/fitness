import 'package:fitnc_user/page/workout/workout-instance.page.dart';
import 'package:fitnc_user/service/exercice.service.dart';
import 'package:fitnc_user/service/user-set.service.dart';
import 'package:fitness_domain/controller/abstract.controller.dart';
import 'package:fitness_domain/domain/exercice.domain.dart';
import 'package:fitness_domain/domain/user.set.domain.dart';
import 'package:fitness_domain/domain/workout-instance.domain.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animations/loading_animations.dart';

import 'add_exercice.page.dart';

class ExerciceChoiceDialogController extends LocalSearchControllerMixin<Exercice, ExerciceService> {
  final UserSetService userSetService = Get.find();

  Stream<List<Exercice>> listenAllExercice() {
    return service.listenAll();
  }

  Future<UserSet> addUserSet(WorkoutInstance workoutInstance, Exercice exercice) {
    final UserSet userSet = UserSet(
      uidExercice: exercice.uid!,
      uidWorkout: workoutInstance.uid!,
      nameExercice: exercice.name,
      imageUrlExercice: exercice.imageUrl,
      typeExercice: exercice.typeExercice,
    );
    return userSetService.save(userSet).then((_) => userSet);
  }
}

class ExerciceChoiceDialog extends StatelessWidget {
  ExerciceChoiceDialog({Key? key, required this.workoutInstance, this.popOnChoice = false}) : super(key: key);
  final ExerciceChoiceDialogController controller = Get.put(ExerciceChoiceDialogController());
  final WorkoutPageController workoutPageController = Get.put(WorkoutPageController());
  final WorkoutInstance workoutInstance;
  final bool popOnChoice;

  @override
  Widget build(BuildContext context) {
    controller.refreshSearchController();
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          "Choix de l'exercice",
          style: GoogleFonts.alfaSlabOne(fontSize: 18),
        ),
        foregroundColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        bottom: PreferredSize(
          preferredSize: Size(double.infinity, 50),
          child: Padding(
            padding: const EdgeInsets.only(left: 12, right: 12),
            child: Obx(
              () => TextFormField(
                controller: TextEditingController(text: controller.query.value),
                onChanged: (String value) => controller.query.value = value,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.all(5),
                  border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(25))),
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    onPressed: () => controller.query(''),
                    icon: const Icon(Icons.clear),
                  ),
                  hintText: 'Recherche...',
                ),
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
                  label: Text('Créer un exercice'),
                  icon: Icon(Icons.add_circle_outline_rounded),
                  onPressed: () {
                    if (popOnChoice) {
                      Navigator.of(context).pop();
                    } else {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (_) => AddExercicePage(
                            exercice: null,
                          ),
                        ),
                        (Route route) => false,
                      );
                    }
                  },
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Annuler'),
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
                    final List<Exercice> listExercice = snapshot.data!;
                    return ListView.separated(
                      shrinkWrap: true,
                      itemCount: listExercice.length,
                      itemBuilder: (context, index) {
                        final Exercice exercice = listExercice.elementAt(index);
                        return InkWell(
                          onTap: () {
                            controller.addUserSet(workoutInstance, exercice).then(
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
                          },
                          child: ExerciceChoiceCard(exercice: exercice),
                        );
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
  }
}

class ExerciceChoiceCard extends StatelessWidget {
  const ExerciceChoiceCard({Key? key, required this.exercice}) : super(key: key);
  final Exercice exercice;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (exercice.imageUrl != null)
              CircleAvatar(
                foregroundImage: NetworkImage(exercice.imageUrl!),
              ),
            if (exercice.imageUrl == null)
              CircleAvatar(
                backgroundColor: Theme.of(context).primaryColor,
              ),
            Expanded(
                child: Padding(
              padding: const EdgeInsets.only(left: 12, right: 12),
              child: Text(
                exercice.name,
                textAlign: TextAlign.start,
              ),
            )),
            IconButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => AddExercicePage(
                    exercice: exercice,
                  ),
                ),
              ),
              icon: const Icon(
                Icons.edit,
                color: Colors.grey,
              ),
            )
          ],
        ),
      ),
    );
  }
}
