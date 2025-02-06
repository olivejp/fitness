import 'package:fitnc_user/fitness_router.dart';
import 'package:fitnc_user/service/config.service.dart';
import 'package:fitnc_user/service/debug_printer.dart';
import 'package:fitnc_user/service/supabase/supabase.auth.service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../constants.dart';

class LoginPageNotifier extends ChangeNotifier {
  String? _email = '';
  String? _loginMsgError = '';
  String? _password = '';
  bool _hidePassword = true;
  bool _isLoading = false;
  String? resetPasswordCode;
  String? newPassword;

  final SupabaseAuthService supabaseAuthService = GetIt.I.get();
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
      final String emailTrimmed = _email!.trim();

      DebugPrinter.printLn("loginWithEmailAndPassword $emailTrimmed $password");

      supabaseAuthService.loginWithEmailAndPassword(emailTrimmed, password!).then((value) {
        setIsLoading(false);
        if (context.mounted) {
          context.go(FitnessRouter.home);
        }
      }).catchError((onError) {
        DebugPrinter.printError("loginWithEmailAndPassword $onError", null);
        setIsLoading(false);
        if (onError is AuthApiException) {
          _loginMsgError = onError.message;
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
      return supabaseAuthService.resetPasswordForEmail(_email!);
    } else {
      return Future.error("Email can't be null.");
    }
  }
}
