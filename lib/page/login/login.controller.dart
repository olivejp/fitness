import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnc_user/service/config.service.dart';
import 'package:fitness_domain/constants.dart';
import 'package:fitness_domain/service/auth.service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../constants.dart';

class LoginPageController extends GetxController {
  final RxString _loginMsgError = ''.obs;
  final RxString _email = ''.obs;
  final RxString _password = ''.obs;
  final RxBool _hidePassword = true.obs;
  final RxBool isLoading = false.obs;
  final AuthService authService = Get.find();

  @override
  void onInit() {
    super.onInit();
    final ConfigService configService = Get.find();
    if (configService.get(FitnessMobileConstants.profileCommandLineArgument) ==
        'DEV') {
      _email.value = configService.get('EMAIL');
      _password.value = configService.get('PASSWORD');
    }
  }

  String? resetPasswordCode;
  String? newPassword;

  bool get hidePassword => _hidePassword.value;

  void authenticate(GlobalKey<FormState> formKey) {
    _loginMsgError.value = '';

    if (formKey.currentState?.validate() == true) {
      isLoading.value = true;
      String emailTrimmed = email.trim();
      authService.signInWithEmailPassword(emailTrimmed, password).then((value) {
        _password.value = '';
        isLoading.value = false;
        Get.offNamed(FitnessConstants.routeHome);
      }).catchError((onError) {
        isLoading.value = false;
        if (onError is FirebaseAuthException) {
          _loginMsgError.value = onError.message!;
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
