import 'package:fitnc_user/page/exercice/add_exercice.page.dart';
import 'package:fitnc_user/service/workout-instance.service.dart';
import 'package:fitness_domain/domain/exercice.domain.dart';
import 'package:fitness_domain/domain/workout.domain.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddWorkoutInstanceController extends GetxController {
  final WorkoutInstanceService workoutService = Get.find();
  final Rx<Workout> workout = Workout().obs;
}

class AddWorkoutInstance extends StatelessWidget {
  AddWorkoutInstance({Key? key, required this.exercice}) : super(key: key);
  final AddWorkoutInstanceController controller = Get.put(AddWorkoutInstanceController());
  final Exercice exercice;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => AddExercicePage(),
          ),
        ),
        child: const Icon(
          Icons.keyboard_return,
          color: Colors.white,
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            int count = 0;
            Navigator.popUntil(context, (route) {
              return count++ == 2;
            });
          },
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.amber,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Form(
              key: formKey,
              child: Column(
                children: <Widget>[
                  Text(exercice.name),
                  Row(
                    children: [
                      if (exercice.imageUrl != null)
                        CircleAvatar(
                          foregroundImage: NetworkImage(exercice.imageUrl!),
                        ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(),
                  )
                ],
              )),
        ),
      ),
    );
  }
}
