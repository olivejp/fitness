import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnc_user/page/login/sign-up.controller.dart';
import 'package:fitnc_user/page/login/sign-up.form.dart';
import 'package:fitnc_user/widget/bottom.widget.dart';
import 'package:fitness_domain/constants.dart';
import 'package:fitness_domain/service/display.service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../constants.dart';
import 'login.desktop.page.dart';

typedef CallbackUserCredential = void Function(UserCredential userCredential);

const double maxWidth = 600;
const double padding = 30;

class SignUpPage extends StatelessWidget {
  SignUpPage({Key? key, this.callback}) : super(key: key);

  final CallbackUserCredential? callback;
  final SignUpController controller = Get.put(SignUpController());
  final DisplayTypeService displayTypeService = Get.find();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          fit: StackFit.expand,
          children: [
            Positioned(
              top: 0,
              bottom: 0,
              right: 0,
              left: 0,
              child: Hero(
                tag: 'IMAGE_ASSET',
                child: Image.asset(
                  FitnessMobileConstants.imageLogin,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Obx(() {
              if (displayTypeService.displayType.value == DisplayType.desktop) {
                return SignUpDesktopPage(
                  callback: callback,
                );
              } else {
                return SignUpMobilePage(
                  callback: callback,
                );
              }
            }),
            const Positioned(
              bottom: 0,
              right: 0,
              left: 0,
              child: BottomCu(),
            ),
          ],
        ),
      ),
    );
  }
}

class SignUpDesktopPage extends StatelessWidget {
  SignUpDesktopPage({Key? key, this.callback}) : super(key: key);

  final CallbackUserCredential? callback;
  final SignUpController controller = Get.put(SignUpController());
  final DisplayTypeService displayTypeService = Get.find();

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
                  constraints: const BoxConstraints(maxWidth: maxWidth),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Hero(
                        tag: 'HERO_APP_TITLE',
                        child: Text(
                          FitnessConstants.appTitle,
                          style: Theme.of(context).textTheme.headline6,
                        ),
                      ),
                      Card(
                        elevation: 20,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(padding),
                          child: SignUpForm(
                            callback: callback,
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

class SignUpMobilePage extends StatelessWidget {
  SignUpMobilePage({Key? key, this.callback}) : super(key: key);

  final CallbackUserCredential? callback;
  final SignUpController controller = Get.put(SignUpController());
  final DisplayTypeService displayTypeService = Get.find();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(
            top: padding, left: padding, right: padding, bottom: 60),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: maxWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Hero(
                    tag: 'HERO_APP_TITLE',
                    child: Text(
                      FitnessConstants.appTitle,
                      style: Theme.of(context).textTheme.headline6,
                    ),
                  ),
                  SignUpForm(
                    callback: callback,
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
