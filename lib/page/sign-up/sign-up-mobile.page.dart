import 'package:fitnc_user/constants.dart';
import 'package:fitnc_user/page/sign-up/sign-up.form.dart';
import 'package:fitnc_user/page/sign-up/sign-up.notifier.dart';
import 'package:flutter/material.dart';

class SignUpMobilePage extends StatelessWidget {
  const SignUpMobilePage({Key? key, required this.notifier, required this.onSubmit})
      : super(key: key);

  final SignUpNotifier notifier;
  final SubmitSignUp onSubmit;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(
            top: signUpPadding, left: signUpPadding, right: signUpPadding, bottom: 60),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: signUpMaxWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Hero(
                    tag: 'HERO_APP_TITLE',
                    child: Text(
                      FitnessConstants.appTitle,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  SignUpForm(
                    notifier: notifier,
                    onSubmit: onSubmit,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
