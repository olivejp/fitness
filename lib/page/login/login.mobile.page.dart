import 'package:fitnc_user/constants.dart';
import 'package:fitnc_user/page/login/login.page.dart';
import 'package:fitness_domain/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animations/loading_animations.dart';

import 'login.controller.dart';

class LoginMobilePage extends StatelessWidget {
  LoginMobilePage({Key? key, this.callback}) : super(key: key);

  final LoginPageController controller = Get.find();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final CallbackUserCredential? callback;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
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
                                    onPressed: () => controller
                                        .authenticate(formKey)
                                        .then((value) {
                                      if (callback != null) {
                                        callback!(value);
                                      }
                                    }),
                                    child: Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                      children: [
                                        Obx(
                                                () {
                                              if (controller.isLoading.value) {
                                                return LoadingBouncingGrid.circle(
                                                  size: 20,
                                                  backgroundColor: Colors.white,
                                                );
                                              }
                                              return Container();
                                            }
                                        ),
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
          )
        ],
      ),
    );
  }
}
