import 'package:fitnc_user/constants.dart';
import 'package:fitnc_user/page/login/login.page.dart';
import 'package:fitnc_user/widget/bottom.widget.dart';
import 'package:fitness_domain/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animations/loading_animations.dart';

import 'login.controller.dart';

class LoginMobilePage extends StatelessWidget {
  LoginMobilePage({Key? key}) : super(key: key);

  final LoginPageController controller = Get.find();
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
            child: Image.asset(
              FitnessMobileConstants.imageLogin,
              fit: BoxFit.cover,
              color: Colors.white,
              colorBlendMode: BlendMode.color,
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
                            child: Text(
                              FitnessMobileConstants.appTitle,
                              style: Theme.of(context).textTheme.headline6,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 30, right: 30, bottom: 30),
                            child: Column(
                              children: <Widget>[
                                LoginForm(
                                  formKey: formKey,
                                  paddingTop: 25,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 30),
                                  child: ElevatedButton(
                                    onPressed: () => controller.authenticate(formKey),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        Obx(() {
                                          if (controller.isLoading.value) {
                                            return LoadingBouncingGrid.circle(
                                              size: 20,
                                              backgroundColor: Colors.white,
                                            );
                                          }
                                          return Container();
                                        }),
                                        Text(
                                          'continue'.tr,
                                          style: const TextStyle(
                                              color: Colors.white),
                                        ),
                                        Container()
                                      ],
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 15),
                                  child: TextButton(
                                    onPressed: () => Get.offNamed(
                                        FitnessConstants.routeSignUp),
                                    child: Text('signUp'.tr),
                                  ),
                                ),
                                Obx(() => Text(controller.loginMsgError))
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
            child: BottomCu(),
          )
        ],
      ),
    );
  }
}
