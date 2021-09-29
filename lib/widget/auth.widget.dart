import 'dart:isolate';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:fitnc_user/page/home/home.page.dart';
import 'package:fitnc_user/page/login/login.page.dart';
import 'package:fitnc_user/service/exercice.service.dart';
import 'package:fitnc_user/service/fitness-user.service.dart';
import 'package:fitnc_user/service/published_programme.service.dart';
import 'package:fitnc_user/service/user-set.service.dart';
import 'package:fitnc_user/service/workout-instance.service.dart';
import 'package:fitness_domain/domain/exercice.domain.dart';
import 'package:fitness_domain/domain/fitness-user.domain.dart';
import 'package:fitness_domain/service/auth.service.dart';
import 'package:fitness_domain/service/firebase-storage.service.dart';
import 'package:fitness_domain/service/firebase.service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AuthWidget extends StatelessWidget {
  AuthWidget({Key? key}) : super(key: key);
  final AuthService authService = Get.find();

  void cacheImages(FitnessUserService fitnessUserService, ExerciceService exerciseService) async {
    List<String> listUrlToCache = [];
    FitnessUser? userConnected = await fitnessUserService.getConnectedUser();
    if (userConnected?.imageUrl != null) {
      listUrlToCache.add(userConnected!.imageUrl!);
    }

    List<Exercice> listExercice = await exerciseService.getAll();

    for (var exercise in listExercice) {
      if (exercise.imageUrl != null) {
        listUrlToCache.add(exercise.imageUrl!);
      }
    }

    // Lancement d'un Isolate pour aller récupérer toutes les images des exercices et de l'utilisateur.
    if (!kIsWeb) {
      Isolate.spawn((List<String> listUrlToCache) {
        for (String url in listUrlToCache) {
          CachedNetworkImageProvider cached = CachedNetworkImageProvider(url);
          cached.resolve(ImageConfiguration.empty);
        }
      }, listUrlToCache);
    }
  }

  void instanciateServices() {
    Get.put(FirebaseService());
    Get.put(FirebaseStorageService());
    Get.put(PublishedProgrammeService());

    FitnessUserService fitnessUserService = Get.put(FitnessUserService());
    ExerciceService exerciseService = Get.put(ExerciceService());
    WorkoutInstanceService workoutInstanceService = Get.put(WorkoutInstanceService());
    UserSetService userSetService = Get.put(UserSetService());

    // Retrieve all information from the user to store them into the local Firebase.
    cacheImages(fitnessUserService, exerciseService);

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
            if (kIsWeb) {
              return HomePage();
            } else {
              return CrashlyticsWidget(user: user);
            }
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

class CrashlyticsWidget extends StatelessWidget {
  const CrashlyticsWidget({Key? key, required this.user}) : super(key: key);
  final User user;

  void logUser(User user) {
    FirebaseCrashlytics.instance.setUserIdentifier(user.uid);
    FirebaseCrashlytics.instance.log("New customer is connected !");
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true),
      builder: (_, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          logUser(user);
          return HomePage();
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
