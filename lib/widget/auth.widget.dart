import 'dart:isolate';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:fitnc_user/page/login/login.page.dart';
import 'package:fitnc_user/page/main/main.page.dart';
import 'package:fitnc_user/service/exercice.service.dart';
import 'package:fitnc_user/service/fitness-user.service.dart';
import 'package:fitnc_user/service/user-set.service.dart';
import 'package:fitnc_user/service/workout-instance.service.dart';
import 'package:fitness_domain/domain/exercice.domain.dart';
import 'package:fitness_domain/domain/fitness-user.domain.dart';
import 'package:fitness_domain/service/auth.service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AuthWidget extends StatelessWidget {
  AuthWidget({Key? key}) : super(key: key);
  final AuthService authService = Get.find();

  void cacheImages(FitnessUserService fitnessUserService,
      ExerciceService exerciseService) async {
    List<String> listUrlToCache = [];
    FitnessUser? userConnected = await fitnessUserService.getConnectedUser();
    if (userConnected?.imageUrl != null) {
      listUrlToCache.add(userConnected!.imageUrl!);
    }

    List<Exercice> listExercise = await exerciseService.getAll();

    for (var exercise in listExercise) {
      if (exercise.imageUrl != null) {
        listUrlToCache.add(exercise.imageUrl!);
      }
    }

    // Lancement d'un Isolate pour aller récupérer toutes les images des exercices et de l'utilisateur.
    if (!kIsWeb) {
      Isolate.spawn((List<String> listUrlToCache) {
        for (String url in listUrlToCache) {
          if (url.isNotEmpty) {
            try {
              CachedNetworkImageProvider cached =
                  CachedNetworkImageProvider(url);
              cached.resolve(ImageConfiguration.empty);
            } catch (e) {
              print("CACHING IMAGE FAILS !!!");
            }
          }
        }
      }, listUrlToCache);
    }
  }

  void instanciateServices() {
    WorkoutInstanceService workoutInstanceService = Get.find();
    UserSetService userSetService = Get.find();

    // Retrieve all information from the user to store them into the local Firebase.
    // cacheImages(fitnessUserService, exerciseService);

    workoutInstanceService
        .getAll()
        .then((value) => print('Workouts retrieved'));
    userSetService
        .getAllInAnyRoot()
        .then((value) => print('UserSets retrieved'));
  }

  @override
  Widget build(BuildContext context) {
    final AuthService authService = Get.find();
    return StreamBuilder<User?>(
      stream: authService.listenUserConnected(),
      builder: (_, AsyncSnapshot<User?> snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final User? user = snapshot.data;
          if (user == null) {

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
  const CrashlyticsWidget({Key? key, required this.user, required this.child})
      : super(key: key);
  final User user;
  final Widget child;

  void logUser(User user) {
    FirebaseCrashlytics.instance.setUserIdentifier(user.uid);
    FirebaseCrashlytics.instance.log("New customer is connected !");
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future:
          FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true),
      builder: (_, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          logUser(user);
          return MainPage();
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
