import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnc_user/fitness_router.dart';
import 'package:fitnc_user/service/config.service.dart';
import 'package:fitness_domain/service/auth.service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../../constants.dart';

class LoginPageNotifier extends ChangeNotifier {
  String? _email = '';
  String? _loginMsgError = '';
  String? _password = '';
  bool _hidePassword = true;
  bool _isLoading = false;
  String? resetPasswordCode;
  String? newPassword;

  final AuthService authService = GetIt.I.get();
  final ConfigService configService = GetIt.I.get();

  LoginPageNotifier() {
    if (configService.get(FitnessMobileConstants.profileCommandLineArgument) == 'DEV') {
      _email = configService.get('EMAIL');
      _password = configService.get('PASSWORD');
    }
  }

  switchHidePassword() {
    _hidePassword = !_hidePassword;
    notifyListeners();
  }

  bool get hidePassword {
    return _hidePassword;
  }

  void authenticate(BuildContext context, GlobalKey<FormState> formKey) {
    _loginMsgError = '';

    if (formKey.currentState?.validate() == true) {
      setIsLoading(true);
      String emailTrimmed = _email!.trim();
      authService.signInWithEmailPassword(emailTrimmed, _password!).then((value) {
        cleanPassword();
        setIsLoading(false);
        context.go(FitncRouter.accueil);
      }).catchError((onError) {
        cleanPassword();
        setIsLoading(false);
        if (onError is FirebaseAuthException) {
          _loginMsgError = onError.message!;
        }
      });
    }
  }

  setEmail(String? mail) {
    _email = mail;
  }

  String? get email {
    return _email;
  }

  String? get password {
    return _password;
  }

  setIsLoading(bool isLoading) {
    _isLoading = isLoading;
    notifyListeners();
  }

  bool get isLoading {
    return _isLoading;
  }

  setPassword(String? password) {
    _password = password;
  }

  cleanPassword() {
    _password = '';
    notifyListeners();
  }

  setLoginMsgError(String? error) {
    _loginMsgError = error;
    notifyListeners();
  }

  String get loginMsgError {
    return _loginMsgError ?? '';
  }

  Future<void> sendPasswordResetEmail() {
    if (_email != null) {
      return FirebaseAuth.instance.sendPasswordResetEmail(email: _email!);
    } else {
      return Future.error("Email can't be null.");
    }
  }

  Future<void> confirmPasswordReset() async {
    if (resetPasswordCode != null && newPassword != null) {
      return await FirebaseAuth.instance.confirmPasswordReset(code: resetPasswordCode!, newPassword: newPassword!);
    }
    return;
  }
}
