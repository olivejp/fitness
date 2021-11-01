import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnc_user/service/fitness-user.service.dart';
import 'package:fitness_domain/domain/fitness-user.domain.dart';
import 'package:fitness_domain/service/auth.service.dart';
import 'package:get/get.dart';

class SignUpController extends GetxController {
  final FitnessUserService fitnessUserService = Get.find();
  final AuthService authService = Get.find();

  String name = '';
  String prenom = '';
  String email = '';
  String telephone = '';
  String password = '';
  String passwordCheck = '';

  RxString errors = ''.obs;

  Future<bool> isConnected() {
    final Completer<bool> completer = Completer<bool>();
    completer.complete(authService.isConnected());
    return completer.future;
  }

  void setError(String error) {
    errors.value = error;
  }

  void cleanError() {
    errors.value = '';
  }

  Future<UserCredential> signUp() async {
    // Méthode pour s'enregistrer sur Firebase.
    final UserCredential credential = await authService.signUp(email, password);

    // Création et sauvegarde d'un Utilisateur
    final FitnessUser user = FitnessUser();
    user.uid = credential.user!.uid;
    user.email = email;
    user.prenom = prenom;
    user.telephone1 = telephone;
    user.name = name;
    await fitnessUserService.getCollectionReference().doc(user.uid).set(user.toJson());

    // On se log pour la première fois avec le compte et on renvoie le credential.
    await authService.signInWithEmailPassword(email, password);

    return credential;
  }
}
