import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnc_user/service/debug_printer.dart';
import 'package:fitnc_user/service/fitness-user.service.dart';
import 'package:fitness_domain/domain/fitness-user.domain.dart';
import 'package:fitness_domain/service/auth.service.dart';
import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';

import '../login/login.page.dart';

class SignUpNotifier extends ChangeNotifier {
  final FitnessUserService fitnessUserService = GetIt.I.get();
  final AuthService authService = GetIt.I.get();

  bool _isLoading = false;
  String _name = '';
  String _prenom = '';
  String _telephone = '';
  String _email = '';
  String _password = '';
  String _passwordCheck = '';
  String _errors = '';

  Future<bool> isConnected() {
    final Completer<bool> completer = Completer<bool>();
    completer.complete(authService.isConnected());
    return completer.future;
  }

  setName(String name) {
    _name = name;
  }

  String get name => _name;

  setPrenom(String prenom) {
    _prenom = prenom;
  }

  String get prenom => _prenom;

  setTelephone(String telephone) {
    _telephone = telephone;
  }

  String get telephone => _telephone;

  setIsLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  bool get isLoading => _isLoading;

  setEmail(String email) {
    _email = email;
  }

  String get email => _email;

  setPassword(String password) {
    _password = password;
  }

  String get password => _password;

  setPasswordCheck(String passwordCheck) {
    _passwordCheck = passwordCheck;
  }

  String get passwordCheck => _passwordCheck;

  void setError(String error) {
    _errors = error;
    notifyListeners();
  }

  void cleanError() {
    _errors = '';
    notifyListeners();
  }

  String get errors => _errors;

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

  void validateSignUp(GlobalKey<FormState> formKey, CallbackUserCredential? callback) {
    DebugPrinter.printLn('validateSignUp');

    cleanError();
    if (formKey.currentState?.validate() == true) {
      setIsLoading(true);
      signUp().then((UserCredential value) {
        setIsLoading(false);
        if (callback != null) {
          callback(value);
        }
      }).catchError((Object? error) {
        setIsLoading(false);
        if (error is FirebaseAuthException) {
          setError(error.message!);
        } else {
          setError(error.toString());
        }
      });
    }
  }
}
