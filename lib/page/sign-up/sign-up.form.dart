import 'package:fitnc_user/l10n/l10n.dart';
import 'package:fitnc_user/page/sign-up/sign-up.notifier.dart';
import 'package:fitnc_user/constants.dart';
import 'package:fitnc_user/widget/elevated-loading-button.widget.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

typedef SubmitSignUp = Future<void> Function(GlobalKey<FormState> formKey);

/// Gabarit partagé par les deux présentations de l'inscription.
const double signUpMaxWidth = 600;
const double signUpPadding = 30;

class SignUpForm extends StatelessWidget {
  SignUpForm({
    Key? key,
    required this.notifier,
    required this.onSubmit,
    this.accountTextColor = Colors.white,
    this.headlineColor = Colors.white,
  }) : super(key: key);
  final SignUpNotifier notifier;
  final SubmitSignUp onSubmit;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final Color accountTextColor;
  final Color headlineColor;

  @override
  Widget build(BuildContext context) {
    final OutlineInputBorder defaultBorder = OutlineInputBorder(
      borderSide: BorderSide(width: 0.5, color: Theme.of(context).colorScheme.primary),
    );

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.signUp,
            style: Theme.of(context)
                .textTheme
                .displaySmall
                ?.copyWith(color: headlineColor),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: TextFormField(
              style: GoogleFonts.roboto(fontSize: 15),
              decoration: InputDecoration(
                fillColor: Colors.white,
                filled: true,
                suffixIcon: const Icon(Icons.email),
                labelText: context.l10n.mail,
                focusedBorder: defaultBorder,
                border: defaultBorder,
                enabledBorder: defaultBorder,
              ),
              onChanged: (String value) => notifier.email = value,
              validator: (String? value) {
                if (value == null || value.isEmpty) {
                  return context.l10n.pleaseFillEmail;
                }
                if (!RegExp(
                        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
                    .hasMatch(value)) {
                  return context.l10n.emailNotCorrect;
                }
                return null;
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: TextFormField(
                style: GoogleFonts.roboto(fontSize: 15),
                decoration: InputDecoration(
                  fillColor: Colors.white,
                  filled: true,
                  labelStyle: GoogleFonts.roboto(fontSize: 15),
                  focusedBorder: defaultBorder,
                  border: defaultBorder,
                  enabledBorder: defaultBorder,
                  labelText: context.l10n.name,
                ),
                onChanged: (String value) => notifier.name = value,
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return context.l10n.pleaseFillYourName;
                  }
                }),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: TextFormField(
                style: GoogleFonts.roboto(fontSize: 15),
                decoration: InputDecoration(
                  fillColor: Colors.white,
                  filled: true,
                  labelText: context.l10n.surname,
                  focusedBorder: defaultBorder,
                  border: defaultBorder,
                  enabledBorder: defaultBorder,
                ),
                onChanged: (String value) => notifier.prenom = value,
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return context.l10n.pleaseFillYourFirstName;
                  }
                }),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: TextFormField(
              style: GoogleFonts.roboto(fontSize: 15),
              onChanged: (String value) => notifier.telephone = value,
              decoration: InputDecoration(
                fillColor: Colors.white,
                filled: true,
                suffixIcon: const Icon(Icons.phone_android),
                labelText: context.l10n.phone,
                focusedBorder: defaultBorder,
                border: defaultBorder,
                enabledBorder: defaultBorder,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 60),
            child: ValueListenableBuilder<bool>(
              valueListenable: notifier.hidePassword1,
              builder: (_, bool hidePassword1, __) => TextFormField(
                  style: GoogleFonts.roboto(fontSize: 15),
                  onChanged: (String value) => notifier.password = value,
                  obscureText: hidePassword1,
                  decoration: InputDecoration(
                      fillColor: Colors.white,
                      filled: true,
                      labelText: context.l10n.password,
                      focusedBorder: defaultBorder,
                      border: defaultBorder,
                      enabledBorder: defaultBorder,
                      suffixIcon: IconButton(
                        tooltip: hidePassword1
                            ? context.l10n.showPassword
                            : context.l10n.hidePassword,
                        onPressed: notifier.switchPassword1,
                        icon: hidePassword1
                            ? const Icon(Icons.visibility_outlined)
                            : const Icon(Icons.visibility_off_outlined),
                      )),
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return context.l10n.noEmptyPassword;
                    }
                  }),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: ValueListenableBuilder<bool>(
              valueListenable: notifier.hidePassword2,
              builder: (_, bool hidePassword2, __) => TextFormField(
                  style: GoogleFonts.roboto(fontSize: 15),
                  onChanged: (String value) => notifier.passwordCheck = value,
                  obscureText: hidePassword2,
                  decoration: InputDecoration(
                      fillColor: Colors.white,
                      filled: true,
                      focusedBorder: defaultBorder,
                      border: defaultBorder,
                      enabledBorder: defaultBorder,
                      labelText: context.l10n.retypePassword,
                      suffixIcon: IconButton(
                          tooltip: hidePassword2
                              ? context.l10n.showPassword
                              : context.l10n.hidePassword,
                          onPressed: notifier.switchPassword2,
                          icon: hidePassword2
                              ? const Icon(Icons.visibility_outlined)
                              : const Icon(Icons.visibility_off_outlined))),
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return context.l10n.noEmptyPassword;
                    }
                    if (notifier.password != notifier.passwordCheck) {
                      return context.l10n.noIdenticalPassword;
                    }
                  }),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: ElevatedLoadingButton(
              onPressed: () => onSubmit(_formKey),
              title: context.l10n.signUp,
              isLoading: notifier.isLoading,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  context.l10n.haveAnAccount,
                  style: TextStyle(color: accountTextColor),
                ),
                TextButton(
                  onPressed: () => context.go(FitnessConstants.routeLogin),
                  child: Text(
                    context.l10n.signIn,
                  ),
                ),
              ],
            ),
          ),
          ValueListenableBuilder<String>(
            valueListenable: notifier.errors,
            builder: (_, String error, __) {
              if (error.isEmpty) {
                return const SizedBox.shrink();
              }
              return Text(
                error,
                style: const TextStyle(color: Colors.red),
              );
            },
          ),
        ],
      ),
    );
  }
}
