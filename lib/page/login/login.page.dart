import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnc_user/page/login/login.desktop.page.dart';
import 'package:fitnc_user/page/login/login.mobile.page.dart';
import 'package:fitness_domain/service/display.service.dart';
import 'package:fitness_domain/widget/layout-display.widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:localization/localization.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';

import '../../constants.dart';
import 'login.notifier.dart';

typedef CallbackUserCredential = void Function(UserCredential userCredential);

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutNotifier(
      child: SafeArea(
        child: Scaffold(
          backgroundColor: FitnessNcColors.blue50,
          body: ChangeNotifierProvider.value(
            value: LoginPageNotifier(),
            builder: (context, child) {
              return Consumer<DisplayTypeNotifier>(builder: (context, notifier, child) {
                return (<DisplayType>[DisplayType.mobile, DisplayType.tablet].contains(notifier.displayType))
                    ? LoginMobilePage()
                    : LoginDesktopPage();
              });
            },
          ),
        ),
      ),
    );
  }
}

class LoginForm extends StatelessWidget {
  const LoginForm({
    super.key,
    required this.formKey,
    this.paddingTop = 30,
    this.paddingInBetween = 30,
    this.callback,
  });

  final CallbackUserCredential? callback;
  final GlobalKey<FormState> formKey;
  final double paddingTop;
  final double paddingInBetween;

  @override
  Widget build(BuildContext context) {
    final LoginPageNotifier notifierReadOnly = Provider.of<LoginPageNotifier>(context, listen: false);
    return Form(
      key: formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'signIn'.i18n(),
            style: Theme.of(context).textTheme.displaySmall?.copyWith(color: Colors.white),
          ),
          Padding(
            padding: EdgeInsets.only(top: paddingTop),
            child: TextFormField(
              initialValue: notifierReadOnly.email,
              style: GoogleFonts.roboto(fontSize: 15),
              decoration: InputDecoration(
                suffixIcon: const Icon(Icons.email),
                fillColor: Colors.white,
                filled: true,
                labelText: 'mail'.i18n(),
                labelStyle: TextStyle(color: Theme.of(context).primaryColor),
                hintStyle: GoogleFonts.roboto(fontSize: 15),
              ),
              onChanged: notifierReadOnly.setEmail,
              onFieldSubmitted: (String value) => notifierReadOnly.authenticate(context, formKey),
              validator: (String? value) {
                String? emailTrimmed = value?.trim();
                if (emailTrimmed == null || emailTrimmed.isEmpty) {
                  return 'pleaseFillEmail'.i18n();
                }
                if (!RegExp(
                  r'^(([^<>()[\]\\.,;:\s@"]+(\.[^<>()[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$',
                ).hasMatch(emailTrimmed)) {
                  return 'emailNotCorrect'.i18n();
                }
                return null;
              },
              textInputAction: TextInputAction.done,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: paddingInBetween),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Consumer<LoginPageNotifier>(
                  builder: (context, notifier, child) => TextFormField(
                    initialValue: notifier.password,
                    style: GoogleFonts.roboto(fontSize: 15),
                    obscureText: notifier.hidePassword,
                    enableSuggestions: false,
                    autocorrect: false,
                    decoration: InputDecoration(
                      fillColor: Colors.white,
                      filled: true,
                      labelText: 'password'.i18n(),
                      labelStyle: TextStyle(color: Theme.of(context).primaryColor),
                      hintStyle: GoogleFonts.roboto(fontSize: 15),
                      suffixIcon: IconButton(
                        tooltip: notifier.hidePassword ? 'showPassword'.i18n() : 'hidePassword'.i18n(),
                        onPressed: notifier.switchHidePassword,
                        icon: notifier.hidePassword
                            ? const Icon(Icons.visibility_outlined)
                            : const Icon(Icons.visibility_off_outlined),
                      ),
                    ),
                    onChanged: notifier.setPassword,
                    onFieldSubmitted: (_) => notifier.authenticate(context, formKey),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    if (notifierReadOnly.email != null && notifierReadOnly.email!.isNotEmpty) {
                      notifierReadOnly
                          .sendPasswordResetEmail()
                          .then(
                            (value) => showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text('lostPasswordQuestion'.i18n()),
                                content: Text('descriptionLostPassword'.i18n()),
                                actions: [
                                  TextButton(
                                    child: Text('iUnderstood'.i18n()),
                                    onPressed: () => Navigator.of(context).pop(),
                                  ),
                                ],
                              ),
                            ),
                          )
                          .onError((error, stackTrace) => notifierReadOnly.setLoginMsgError(error.toString()));
                    } else {
                      showToast('pleaseFillEmail'.i18n());
                    }
                  },
                  child: Text(
                    'lostPasswordQuestion'.i18n(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
