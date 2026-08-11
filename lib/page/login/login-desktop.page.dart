import 'package:fitnc_user/l10n/l10n.dart';
import 'package:fitnc_user/widget/bottom.widget.dart';
import 'package:fitnc_user/constants.dart';
import 'package:fitnc_user/di.dart';
import 'package:fitnc_user/service/display.service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:fitnc_user/page/login/login.notifier.dart';
import 'package:fitnc_user/page/login/login.form.dart';
import 'package:fitnc_user/widget/deco-slide.widget.dart';
import 'package:fitnc_user/widget/elevated-loading-button.widget.dart';

class LoginDesktopPage extends StatelessWidget {
  LoginDesktopPage({Key? key, required this.notifier, required this.onSubmit})
      : super(key: key);

  final LoginNotifier notifier;
  final SubmitLogin onSubmit;
  final DisplayTypeService displayTypeService = di<DisplayTypeService>();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Positioned(
          top: 0,
          bottom: 0,
          right: 0,
          left: 0,
          child: Hero(
            tag: 'IMAGE_ASSET',
            child: Image.asset(
              '${FitnessConstants.imageLogin}-L${FitnessConstants.imageLoginExtension}',
              fit: BoxFit.cover,
            ),
          ),
        ),
        Row(
          children: [
            Flexible(child: Container()),
            Flexible(
                child: Stack(
              children: [
                const DecoFirstSlide(),
                const DecoSecondSlide(),
                Center(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SingleChildScrollView(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                              maxWidth: 500, maxHeight: double.infinity),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(
                                  bottom: 30,
                                  left: 20,
                                ),
                                child: Hero(
                                  tag: 'HERO_APP_TITLE',
                                  child: Text(
                                    FitnessConstants.appTitle,
                                    style:
                                        Theme.of(context).textTheme.titleLarge,
                                  ),
                                ),
                              ),
                              Card(
                                elevation: 20,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(60.0),
                                  child: Column(
                                    children: <Widget>[
                                      Text(
                                        context.l10n.connectToYourAccount,
                                        style: Theme.of(context)
                                            .textTheme
                                            .displaySmall,
                                      ),
                                      LoginForm(
                                        formKey: formKey,
                                        notifier: notifier,
                                        onSubmit: onSubmit,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 30),
                                        child: ElevatedLoadingButton(
                                          onPressed: () => onSubmit(formKey),
                                          title: context.l10n.continueLabel,
                                          isLoading: notifier.isLoading,
                                        ),
                                      ),
                                      ValueListenableBuilder<String>(
                                        valueListenable: notifier.loginMsgError,
                                        builder: (_, String error, __) =>
                                            Text(error),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          Text(
                                            context.l10n.noAccount,
                                            style: const TextStyle(
                                                color: Colors.grey),
                                          ),
                                          TextButton(
                                            onPressed: () => context.go(
                                                FitnessConstants.routeSignUp),
                                            child: Text(
                                              context.l10n.signUp,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ))
          ],
        ),
        const Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: BottomCu(),
        ),
      ],
    );
  }
}
