import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginPageController extends GetxController {
  final Rx<User?> _userConnected = null.obs;
  final RxString _loginMsgError = ''.obs;
  final RxString _email = ''.obs;
  final RxString _password = ''.obs;
  final RxBool _hidePassword = true.obs;

  bool get hidePassword => _hidePassword.value;

  void authenticate(GlobalKey<FormState> formKey) {
    _loginMsgError.value = '';
    if (formKey.currentState?.validate() == true) {
      FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password).then((UserCredential value) {
        userConnected = FirebaseAuth.instance.currentUser;
        _password.value = '';
      }).catchError((Object? error) {
        if (error is FirebaseAuthException) {
          _loginMsgError.value = error.message!;
        }
      });
    }
  }

  set hidePassword(bool hide) {
    _hidePassword.value = hide;
  }

  String get email => _email.value;

  set email(String mail) {
    _email.value = mail;
  }

  String get password => _password.value;

  set password(String password) {
    _password.value = password;
  }

  User? get userConnected => _userConnected.value;

  set userConnected(User? user) {
    _userConnected.value = user;
  }

  String get loginMsgError => _loginMsgError.value;

  set loginMsgError(String error) {
    _loginMsgError.value = error;
  }
}
