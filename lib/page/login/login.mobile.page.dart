import 'package:fitnc_user/constants.dart';
import 'package:fitnc_user/fitness_router.dart';
import 'package:fitnc_user/page/login/login.page.dart';
import 'package:fitnc_user/widget/bottom_cu.widget.dart';
import 'package:fitness_domain/service/display.service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:loading_animations/loading_animations.dart';
import 'package:localization/localization.dart';
import 'package:provider/provider.dart';

import 'login.notifier.dart';

class LoginMobilePage extends StatelessWidget {
  LoginMobilePage({super.key});

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: 0,
          bottom: 0,
          right: 0,
          left: 0,
          child: Hero(
            tag: 'IMAGE_ASSET',
            child: Consumer<DisplayTypeNotifier>(builder: (context, notifier, child) {
              DisplayType type = notifier.displayType;
              String size = (type == DisplayType.mobile)
                  ? 'S'
                  : (type == DisplayType.tablet)
                      ? 'M'
                      : 'L';
              return ColorFiltered(
                colorFilter: const ColorFilter.mode(
                  Colors.black54,
                  BlendMode.hardLight,
                ),
                child: Image.asset(
                  '${FitnessMobileConstants.imageLogin}-$size${FitnessMobileConstants.imageLoginExtension}',
                  fit: BoxFit.cover,
                ),
              );
            }),
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
                              FitnessMobileConstants.appTitle,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 30, right: 30, bottom: 30),
                          child: Column(
                            children: [
                              LoginForm(
                                formKey: formKey,
                                paddingTop: 25,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 30),
                                child: Consumer<LoginPageNotifier>(builder: (context, notifier, child) {
                                  return ElevatedLoadingButton(
                                    onPressed: () => notifier.authenticate(context, formKey),
                                    isLoading: notifier.isLoading,
                                    title: 'continue'.i18n(),
                                  );
                                }),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 15),
                                child: TextButton(
                                  onPressed: () => context.go(FitnessRouter.signUp),
                                  child: Text('signUp'.i18n()),
                                ),
                              ),
                              Consumer<LoginPageNotifier>(builder: (context, notifier, child) {
                                return Text(
                                  notifier.loginMsgError,
                                  style: const TextStyle(
                                    color: Colors.red,
                                  ),
                                );
                              })
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
    );
  }
}

class ElevatedLoadingButton extends StatelessWidget {
  const ElevatedLoadingButton({
    super.key,
    this.onPressed,
    required this.title,
    required this.isLoading,
    this.loadingWidget,
  });

  final VoidCallback? onPressed;
  final String title;
  final bool isLoading;
  final Widget? loadingWidget;

  @override
  Widget build(BuildContext context) {
    VoidCallback? localOnPressed = isLoading ? null : onPressed;

    Widget? widget;
    if (isLoading && loadingWidget != null) {
      widget = loadingWidget!;
    } else {
      widget = LoadingBouncingGrid.circle(
        size: 20,
        backgroundColor: Colors.white,
      );
    }

    return FilledButton(
      style: ButtonStyle(
        minimumSize: MaterialStateProperty.all(
          const Size.fromHeight(60),
        ),
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.0),
          ),
        ),
      ),
      onPressed: localOnPressed,
      child: Center(
        child: isLoading
            ? widget
            : Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}
