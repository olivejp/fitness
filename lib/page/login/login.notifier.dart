import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnc_user/service/config.service.dart';
import 'package:fitnc_user/di.dart';
import 'package:fitnc_user/service/auth.service.dart';
import 'package:flutter/material.dart';

import 'package:fitnc_user/constants.dart';

class LoginNotifier extends ChangeNotifier {
  LoginNotifier() {
    final ConfigService configService = di<ConfigService>();
    if (configService.get(FitnessConstants.profileCommandLineArgument) ==
        'DEV') {
      email.value = configService.get('EMAIL');
      password.value = configService.get('PASSWORD');
    }
  }

  final ValueNotifier<String> loginMsgError = ValueNotifier<String>('');
  final ValueNotifier<String> email = ValueNotifier<String>('');
  final ValueNotifier<String> password = ValueNotifier<String>('');
  final ValueNotifier<bool> hidePassword = ValueNotifier<bool>(true);
  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);
  final AuthService authService = di<AuthService>();

  String? resetPasswordCode;
  String? newPassword;

  @override
  void dispose() {
    loginMsgError.dispose();
    email.dispose();
    password.dispose();
    hidePassword.dispose();
    isLoading.dispose();
    super.dispose();
  }

  ///
  /// Renvoie true si l'authentification a réussi. La navigation appartient à la
  /// page, pas au notifier.
  ///
  Future<bool> authenticate(GlobalKey<FormState> formKey) async {
    loginMsgError.value = '';

    if (formKey.currentState?.validate() != true) {
      return false;
    }

    isLoading.value = true;
    try {
      await authService.signInWithEmailPassword(
          email.value.trim(), password.value);
      password.value = '';
      return true;
    } on FirebaseAuthException catch (error) {
      loginMsgError.value = error.message ?? '';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> sendPasswordResetEmail() {
    return FirebaseAuth.instance.sendPasswordResetEmail(email: email.value);
  }

  Future<void> confirmPasswordReset() async {
    if (resetPasswordCode != null && newPassword != null) {
      return await FirebaseAuth.instance.confirmPasswordReset(
          code: resetPasswordCode!, newPassword: newPassword!);
    }
    return;
  }
}
