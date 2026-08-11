import 'package:fitnc_user/constants.dart';
import 'package:fitnc_user/page/sign-up/sign-up.form.dart';
import 'package:fitnc_user/page/sign-up/sign-up.notifier.dart';
import 'package:fitnc_user/widget/deco-slide.widget.dart';
import 'package:flutter/material.dart';

class SignUpDesktopPage extends StatelessWidget {
  const SignUpDesktopPage({Key? key, required this.notifier, required this.onSubmit})
      : super(key: key);

  final SignUpNotifier notifier;
  final SubmitSignUp onSubmit;

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      Flexible(child: Container()),
      Flexible(
          child: Stack(
        children: [
          const DecoFirstSlide(),
          const DecoSecondSlide(),
          SingleChildScrollView(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 60),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: signUpMaxWidth),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Hero(
                        tag: 'HERO_APP_TITLE',
                        child: Text(
                          FitnessConstants.appTitle,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      Card(
                        elevation: 20,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(signUpPadding),
                          child: SignUpForm(
                            notifier: notifier,
                            onSubmit: onSubmit,
                            accountTextColor: Colors.grey,
                            headlineColor: Colors.grey,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ))
    ]);
  }
}
