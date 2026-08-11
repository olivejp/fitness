import 'package:fitnc_user/l10n/l10n.dart';
import 'package:fitnc_user/page/login/login.notifier.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:oktoast/oktoast.dart';

typedef SubmitLogin = Future<void> Function(GlobalKey<FormState> formKey);

class LoginForm extends StatelessWidget {
  const LoginForm({
    Key? key,
    required this.formKey,
    required this.notifier,
    required this.onSubmit,
    this.paddingTop = 30,
    this.paddingInBetween = 30,
  }) : super(key: key);

  final GlobalKey<FormState> formKey;
  final LoginNotifier notifier;
  final SubmitLogin onSubmit;
  final double paddingTop;
  final double paddingInBetween;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: paddingTop),
            child: TextFormField(
              initialValue: notifier.email.value,
              style: GoogleFonts.roboto(fontSize: 15),
              decoration: InputDecoration(
                suffixIcon: const Icon(Icons.email),
                fillColor: Colors.white,
                filled: true,
                labelText: context.l10n.mail,
                labelStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
                hintStyle: GoogleFonts.roboto(fontSize: 15),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    width: 0.5,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    width: 0.5,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    width: 0.5,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              onChanged: (String value) => notifier.email.value = value,
              onFieldSubmitted: (_) => onSubmit(formKey),
              validator: (String? value) {
                String? emailTrimmed = value?.trim();
                if (emailTrimmed == null || emailTrimmed.isEmpty) {
                  return context.l10n.pleaseFillEmail;
                }
                if (!RegExp(
                  r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$',
                ).hasMatch(emailTrimmed)) {
                  return context.l10n.emailNotCorrect;
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
                ValueListenableBuilder<bool>(
                  valueListenable: notifier.hidePassword,
                  builder: (_, bool hidePassword, __) => TextFormField(
                    initialValue: notifier.password.value,
                    style: GoogleFonts.roboto(fontSize: 15),
                    obscureText: hidePassword,
                    enableSuggestions: false,
                    autocorrect: false,
                    decoration: InputDecoration(
                      fillColor: Colors.white,
                      filled: true,
                      labelText: context.l10n.password,
                      labelStyle:
                          TextStyle(color: Theme.of(context).colorScheme.primary),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          width: 0.5,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          width: 0.5,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          width: 0.5,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      hintStyle: GoogleFonts.roboto(fontSize: 15),
                      suffixIcon: IconButton(
                        tooltip: hidePassword
                            ? context.l10n.showPassword
                            : context.l10n.hidePassword,
                        onPressed: () =>
                            notifier.hidePassword.value = !hidePassword,
                        icon: hidePassword
                            ? const Icon(Icons.visibility_outlined)
                            : const Icon(Icons.visibility_off_outlined),
                      ),
                    ),
                    onChanged: (String value) =>
                        notifier.password.value = value,
                    onFieldSubmitted: (_) => onSubmit(formKey),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    if (notifier.email.value.isNotEmpty) {
                      notifier.sendPasswordResetEmail().then(
                            (value) => showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text(context.l10n.lostPassword),
                                content: Text(context.l10n.descriptionLostPassword),
                                actions: [
                                  TextButton(
                                    child: Text(context.l10n.iUnderstood),
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                  ),
                                ],
                              ),
                            ),
                          );
                    } else {
                      showToast(context.l10n.pleaseFillEmail);
                    }
                  },
                  child: Text(
                    context.l10n.lostPasswordQuestion,
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
