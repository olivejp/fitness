import 'package:fitnc_user/page/login/login.page.dart';
import 'package:fitnc_user/widget/bottom.widget.dart';
import 'package:fitness_domain/constants.dart';
import 'package:fitness_domain/service/display.service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../constants.dart';
import 'login.controller.dart';
import 'login.mobile.page.dart';

class LoginDesktopPage extends StatelessWidget {
  LoginDesktopPage({Key? key}) : super(key: key);

  final LoginPageController controller = Get.find();
  final DisplayTypeService displayTypeService = Get.find();
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
              '${FitnessMobileConstants.imageLogin}-L${FitnessMobileConstants.imageLoginExtension}',
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
                                        Theme.of(context).textTheme.headline6,
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
                                        'connectToYourAccount'.tr,
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline3,
                                      ),
                                      LoginForm(formKey: formKey),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 30),
                                        child: ElevatedLoadingButton(
                                          onPressed: () =>
                                              controller.authenticate(formKey),
                                          title: 'continue'.tr,
                                          isLoading: controller.isLoading,
                                        ),
                                      ),
                                      Obx(() => Text(controller.loginMsgError)),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          Text(
                                            'noAccount'.tr,
                                            style: const TextStyle(
                                                color: Colors.grey),
                                          ),
                                          TextButton(
                                            onPressed: () => Get.offNamed(
                                                FitnessConstants.routeSignUp),
                                            child: Text(
                                              'signUp'.tr,
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

class DecoSecondSlide extends StatelessWidget {
  const DecoSecondSlide({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Transform(
      transform: Matrix4.identity()
        ..translate(MediaQuery.of(context).size.width - 850)
        ..add(Matrix4.skewX(-0.3)),
      child: Container(
        width: 20,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
            colors: <Color>[
              Colors.amber.shade700,
              Colors.amber.withAlpha(100),
            ],
          ),
        ),
      ),
    );
  }
}

class DecoFirstSlide extends StatelessWidget {
  const DecoFirstSlide({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Transform(
      transform: Matrix4.identity()
        ..translate(MediaQuery.of(context).size.width - 800)
        ..add(Matrix4.skewX(-0.3)),
      child: Container(
        width: 200,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
            colors: <Color>[
              Colors.amber.shade700,
              Colors.amber.withAlpha(100),
            ],
          ),
        ),
      ),
    );
  }
}
