import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnc_user/page/home/home.page.dart';
import 'package:fitnc_user/page/login/login.page.dart';
import 'package:fitnc_user/service/exercice.service.dart';
import 'package:fitnc_user/service/fitness-user.service.dart';
import 'package:fitnc_user/service/published_programme.service.dart';
import 'package:fitnc_user/service/trainers.service.dart';
import 'package:fitnc_user/service/user-set.service.dart';
import 'package:fitnc_user/service/workout-instance.service.dart';
import 'package:fitness_domain/service/auth.service.dart';
import 'package:fitness_domain/service/firebase-storage.service.dart';
import 'package:fitness_domain/service/firebase.service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AuthWidget extends StatelessWidget {
  AuthWidget({Key? key}) : super(key: key);
  final AuthService authService = Get.find();

  void instanciateServices() {
    Get.put(FirebaseService());
    Get.put(FirebaseStorageService());
    Get.put(PublishedProgrammeService());

    FitnessUserService fitnessUserService = Get.put(FitnessUserService());
    ExerciceService exerciseService = Get.put(ExerciceService());
    WorkoutInstanceService workoutInstanceService = Get.put(WorkoutInstanceService());
    UserSetService userSetService = Get.put(UserSetService());

    // Retrieve all information from the user to store them into the local Firebase.
    fitnessUserService.getConnectedUser().then((value) {
      if (value?.imageUrl != null) {
        CachedNetworkImageProvider cached = CachedNetworkImageProvider(value!.imageUrl!);
        cached.resolve(ImageConfiguration.empty);
      }
    });
    exerciseService.getAll().then((value) => value.forEach((e) {
          if (e.imageUrl != null) {
            CachedNetworkImageProvider cached = CachedNetworkImageProvider(e.imageUrl!);
            cached.resolve(ImageConfiguration.empty);
          }
        }));
    workoutInstanceService.getAll().then((value) => print('Workouts retrieved'));
    userSetService.getAllInAnyRoot().then((value) => print('UserSets retrieved'));
  }

  @override
  Widget build(BuildContext context) {
    final AuthService authService = Get.find();
    return StreamBuilder<User?>(
      stream: authService.listenUserConnected(),
      builder: (_, AsyncSnapshot<User?> snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final User? user = snapshot.data;
          if (user != null) {
            instanciateServices();
            return HomePage();
          } else {
            return LoginPage();
          }
        }
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}
