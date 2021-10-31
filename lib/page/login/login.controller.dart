import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness_domain/service/auth.service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginPageController extends GetxController {
  final RxString _loginMsgError = ''.obs;
  final RxString _email = ''.obs;
  final RxString _password = ''.obs;
  final RxBool _hidePassword = true.obs;
  final RxBool isLoading = false.obs;
  final AuthService authService = Get.find();

  String? resetPasswordCode;
  String? newPassword;

  bool get hidePassword => _hidePassword.value;

  Future<UserCredential> authenticate(GlobalKey<FormState> formKey) async {
    _loginMsgError.value = '';

    if (formKey.currentState?.validate() == true) {
      isLoading.value = true;
      String emailTrimmed = email.trim();

      try {
        UserCredential userCredential =
            await authService.signInWithEmailPassword(emailTrimmed, password);
        _password.value = '';
        isLoading.value = false;
        return userCredential;
      } catch (error) {
        isLoading.value = false;
        if (error is FirebaseAuthException) {
          _loginMsgError.value = error.message!;
        }
        return Future.error(error);
      }
    }

    return Future.error('Form is invalid.');
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

  String get loginMsgError => _loginMsgError.value;

  set loginMsgError(String error) {
    _loginMsgError.value = error;
  }

  Future<void> sendPasswordResetEmail() {
    return FirebaseAuth.instance.sendPasswordResetEmail(email: email);
  }

  Future<void> confirmPasswordReset() async {
    if (resetPasswordCode != null && newPassword != null) {
      return await FirebaseAuth.instance.confirmPasswordReset(
          code: resetPasswordCode!, newPassword: newPassword!);
    }
    return;
  }
}
