import 'package:fitnc_user/fitness_router.dart';
import 'package:fitnc_user/page/login/login.mobile.page.dart';
import 'package:fitnc_user/page/sign_up/sign-up.notifier.dart';
import 'package:fitnc_user/page/sign_up/sign-up.page.dart';
import 'package:fitnc_user/page/sign_up/sign-up.password-notifier.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:localization/localization.dart';
import 'package:provider/provider.dart';

class SignUpForm extends StatelessWidget {
  SignUpForm({
    super.key,
    required this.callback,
    this.accountTextColor = Colors.white,
    this.headlineColor = Colors.white,
  });

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final CallbackUserCredential? callback;
  final Color accountTextColor;
  final Color headlineColor;

  @override
  Widget build(BuildContext context) {
    final OutlineInputBorder defaultBorder = OutlineInputBorder(
      borderSide: BorderSide(width: 0.5, color: Theme.of(context).primaryColor),
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HidePasswordNotifier()),
        ChangeNotifierProvider(create: (_) => SignUpNotifier()),
      ],
      builder: (context, child) {
        final SignUpNotifier signUpReadOnlyNotifier = Provider.of<SignUpNotifier>(context, listen: false);
        return Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'signUp'.i18n(),
                style: Theme.of(context).textTheme.displaySmall?.copyWith(color: headlineColor),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: TextFormField(
                  style: GoogleFonts.roboto(fontSize: 15),
                  decoration: InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                    suffixIcon: const Icon(Icons.email),
                    labelText: 'mail'.i18n(),
                    focusedBorder: defaultBorder,
                    border: defaultBorder,
                    enabledBorder: defaultBorder,
                  ),
                  onChanged: signUpReadOnlyNotifier.setEmail,
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'pleaseFillEmail'.i18n();
                    }
                    if (!RegExp(
                            r'^(([^<>()[\]\\.,;:\s@"]+(\.[^<>()[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
                        .hasMatch(value)) {
                      return 'emailNotCorrect'.i18n();
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
                      labelText: 'name'.i18n(),
                    ),
                    onChanged: signUpReadOnlyNotifier.setName,
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'pleaseFillYourName'.i18n();
                      }
                      return null;
                    }),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: TextFormField(
                    style: GoogleFonts.roboto(fontSize: 15),
                    decoration: InputDecoration(
                      fillColor: Colors.white,
                      filled: true,
                      labelText: 'surname'.i18n(),
                      focusedBorder: defaultBorder,
                      border: defaultBorder,
                      enabledBorder: defaultBorder,
                    ),
                    onChanged: signUpReadOnlyNotifier.setPrenom,
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'pleaseFillYourFirstName'.i18n();
                      }
                      return null;
                    }),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: TextFormField(
                  style: GoogleFonts.roboto(fontSize: 15),
                  onChanged: signUpReadOnlyNotifier.setTelephone,
                  decoration: InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                    suffixIcon: const Icon(Icons.phone_android),
                    labelText: 'phone'.i18n(),
                    focusedBorder: defaultBorder,
                    border: defaultBorder,
                    enabledBorder: defaultBorder,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 60),
                child: Consumer<HidePasswordNotifier>(
                  builder: (context, hidePasswordController, child) => TextFormField(
                      style: GoogleFonts.roboto(fontSize: 15),
                      onChanged: signUpReadOnlyNotifier.setPassword,
                      obscureText: hidePasswordController.hidePassword1,
                      decoration: InputDecoration(
                          fillColor: Colors.white,
                          filled: true,
                          labelText: 'password'.i18n(),
                          focusedBorder: defaultBorder,
                          border: defaultBorder,
                          enabledBorder: defaultBorder,
                          suffixIcon: IconButton(
                            tooltip:
                                hidePasswordController.hidePassword1 ? 'showPassword'.i18n() : 'hidePassword'.i18n(),
                            onPressed: hidePasswordController.switchPassword1,
                            icon: hidePasswordController.hidePassword1
                                ? const Icon(Icons.visibility_outlined)
                                : const Icon(Icons.visibility_off_outlined),
                          )),
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return 'noEmptyPassword'.i18n();
                        }
                        return null;
                      }),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Consumer<HidePasswordNotifier>(
                  builder: (context, hidePasswordNotifier, child) => TextFormField(
                      style: GoogleFonts.roboto(fontSize: 15),
                      onChanged: signUpReadOnlyNotifier.setPasswordCheck,
                      obscureText: hidePasswordNotifier.hidePassword2,
                      decoration: InputDecoration(
                          fillColor: Colors.white,
                          filled: true,
                          focusedBorder: defaultBorder,
                          border: defaultBorder,
                          enabledBorder: defaultBorder,
                          labelText: 'retypePassword'.i18n(),
                          suffixIcon: IconButton(
                              tooltip:
                                  hidePasswordNotifier.hidePassword2 ? 'showPassword'.i18n() : 'hidePassword'.i18n(),
                              onPressed: hidePasswordNotifier.switchPassword2,
                              icon: hidePasswordNotifier.hidePassword2
                                  ? const Icon(Icons.visibility_outlined)
                                  : const Icon(Icons.visibility_off_outlined))),
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return 'noEmptyPassword'.i18n();
                        }
                        if (signUpReadOnlyNotifier.password != signUpReadOnlyNotifier.passwordCheck) {
                          return 'noIdenticalPassword'.i18n();
                        }
                        return null;
                      }),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: ElevatedLoadingButton(
                  onPressed: () {
                    signUpReadOnlyNotifier.validateSignUp(_formKey, callback);
                  },
                  title: 'signUp'.i18n(),
                  isLoading: signUpReadOnlyNotifier.isLoading,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 30),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'haveAnAccount'.i18n(),
                      style: TextStyle(color: accountTextColor),
                    ),
                    TextButton(
                      onPressed: () => context.go(FitnessRouter.signIn),
                      child: Text(
                        'signIn'.i18n(),
                      ),
                    ),
                  ],
                ),
              ),
              Consumer<SignUpNotifier>(
                builder: (context, notifier, child) {
                  return Text(
                    notifier.errors,
                    style: const TextStyle(color: Colors.red),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
