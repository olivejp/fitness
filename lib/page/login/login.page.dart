import 'package:fitnc_user/page/login/login-desktop.page.dart';
import 'package:fitnc_user/page/login/login-mobile.page.dart';
import 'package:fitnc_user/constants.dart';
import 'package:fitnc_user/di.dart';
import 'package:fitnc_user/service/display.service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:fitnc_user/page/login/login.notifier.dart';
///
/// La page possède le notifier : elle le crée, le libère, et le passe
/// explicitement à ses sous-widgets. C'est aussi elle qui navigue — le notifier
/// se contente de dire si l'authentification a réussi.
///
class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final LoginNotifier notifier = LoginNotifier();
  final DisplayTypeService displayTypeService = di<DisplayTypeService>();

  @override
  void dispose() {
    notifier.dispose();
    super.dispose();
  }

  Future<void> _submit(GlobalKey<FormState> formKey) async {
    final bool success = await notifier.authenticate(formKey);
    if (success && mounted) {
      context.go(FitnessConstants.routeHome);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FitnessNcColors.blue50,
      body: ValueListenableBuilder<DisplayType>(
        valueListenable: displayTypeService.displayType,
        builder: (_, DisplayType displayType, __) {
          final bool isCompact = displayType == DisplayType.mobile ||
              displayType == DisplayType.tablet;
          return isCompact
              ? LoginMobilePage(notifier: notifier, onSubmit: _submit)
              : LoginDesktopPage(notifier: notifier, onSubmit: _submit);
        },
      ),
    );
  }
}
