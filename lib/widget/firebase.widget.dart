import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fitnc_user/page/firebase_error_page.dart';
import 'package:fitnc_user/service/config.service.dart';
import 'package:fitnc_user/service/exercice.service.dart';
import 'package:fitnc_user/service/fitness-user.service.dart';
import 'package:fitnc_user/service/published_programme.service.dart';
import 'package:fitnc_user/service/trainers.service.dart';
import 'package:fitnc_user/service/user-set.service.dart';
import 'package:fitnc_user/service/workout-instance.service.dart';
import 'package:fitness_domain/service/auth.service.dart';
import 'package:fitness_domain/service/firebase-storage.service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constants.dart';
import 'auth.widget.dart';

class FirebaseWidget extends StatelessWidget {
  FirebaseWidget({Key? key}) : super(key: key);
  final ConfigService configService = Get.find();

  initFirebaseService() {
    // TODO pour les tests sur Cloud Functions
    if (configService.get(FitnessMobileConstants.profileCommandLineArgument) ==
        'DEV') {
      print(
          '[WARNING] Application launched with profile DEV : Firebase Function emulators will be used.');
      FirebaseFunctions.instanceFor(region: FitnessMobileConstants.firebaseRegion)
          .useFunctionsEmulator('localhost', 5001);
    }
    Get.lazyPut(() => AuthService());
    Get.lazyPut(() => TrainersService());
    Get.lazyPut(() => PublishedProgrammeService());
    Get.lazyPut(() => FitnessUserService());
    Get.lazyPut(() => FirebaseStorageService());
    Get.lazyPut(() => ExerciceService());
    Get.lazyPut(() => WorkoutInstanceService());
    Get.lazyPut(() => UserSetService());
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<FirebaseApp>(
      future: Firebase.initializeApp(),
      builder: (_, AsyncSnapshot<FirebaseApp> snapshot) {
        if (snapshot.hasData) {
          initFirebaseService();
          return AuthWidget();
        }
        if (snapshot.hasError) {
          return const FirebaseErrorPage();
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
