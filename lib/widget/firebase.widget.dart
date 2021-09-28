import 'package:firebase_core/firebase_core.dart';
import 'package:fitnc_user/page/firebase_error_page.dart';
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

import 'auth.widget.dart';

class FirebaseWidget extends StatelessWidget {
  const FirebaseWidget({Key? key}) : super(key: key);

  instanciateAuthService() {
    Get.put(AuthService());
    Get.put(TrainersService());
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<FirebaseApp>(
      future: Firebase.initializeApp(),
      builder: (_, AsyncSnapshot<FirebaseApp> snapshot) {
        if (snapshot.hasData) {
          instanciateAuthService();
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
