import 'package:fitnc_user/constants.dart';
import 'package:fitnc_user/l10n/l10n.dart';
import 'package:fitnc_user/widget/bottom.widget.dart';
import 'package:fitnc_user/di.dart';
import 'package:fitnc_user/service/display.service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:fitnc_user/page/login/login.notifier.dart';
import 'package:fitnc_user/page/login/login.form.dart';
import 'package:fitnc_user/widget/elevated-loading-button.widget.dart';

class LoginMobilePage extends StatelessWidget {
  LoginMobilePage({Key? key, required this.notifier, required this.onSubmit})
      : super(key: key);

  final LoginNotifier notifier;
  final SubmitLogin onSubmit;
  final DisplayTypeService displayTypeService = di<DisplayTypeService>();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          Positioned(
            top: 0,
            bottom: 0,
            right: 0,
            left: 0,
            child: Hero(
              tag: 'IMAGE_ASSET',
              child: ValueListenableBuilder<DisplayType>(
                valueListenable: displayTypeService.displayType,
                builder: (_, DisplayType type, __) {
                  String size = (type == DisplayType.mobile)
                      ? 'S'
                      : (type == DisplayType.tablet)
                          ? 'M'
                          : 'L';
                  return Image.asset(
                    '${FitnessConstants.imageLogin}-$size${FitnessConstants.imageLoginExtension}',
                    fit: BoxFit.cover,
                  );
                },
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Flexible(
                    child: SizedBox(
                      width: 500,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(left: 30),
                            child: Hero(
                              tag: 'HERO_APP_TITLE',
                              child: Text(
                                FitnessConstants.appTitle,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 30, right: 30, bottom: 30),
                            child: Column(
                              children: <Widget>[
                                LoginForm(
                                  formKey: formKey,
                                  notifier: notifier,
                                  onSubmit: onSubmit,
                                  paddingTop: 25,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 30),
                                  child: ElevatedLoadingButton(
                                    onPressed: () => onSubmit(formKey),
                                    isLoading: notifier.isLoading,
                                    title: context.l10n.continueLabel,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 15),
                                  child: TextButton(
                                    onPressed: () => context
                                        .go(FitnessConstants.routeSignUp),
                                    child: Text(context.l10n.signUp),
                                  ),
                                ),
                                ValueListenableBuilder<String>(
                                  valueListenable: notifier.loginMsgError,
                                  builder: (_, String error, __) => Text(error),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: BottomCu(),
          )
        ],
      ),
    );
  }
}
