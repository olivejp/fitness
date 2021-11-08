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
            child: Hero(
              tag: 'IMAGE_ASSET',
              child: Image.asset(
                FitnessMobileConstants.imageLogin,
                fit: BoxFit.cover,
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
                                FitnessMobileConstants.appTitle,
                                style: Theme.of(context).textTheme.headline6,
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
                                  paddingTop: 25,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 30),
                                  child: ElevatedLoadingButton(
                                    onPressed: () =>
                                        controller.authenticate(formKey),
                                    isLoading: controller.isLoading,
                                    title: 'continue'.tr,
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
            left: 0,
            right: 0,
            child: BottomCu(),
          )
        ],
      ),
    );
  }
}

class ElevatedLoadingButton extends StatelessWidget {
  const ElevatedLoadingButton({
    Key? key,
    this.onPressed,
    required this.title,
    required this.isLoading,
    this.loadingWidget,
  }) : super(key: key);
  final VoidCallback? onPressed;
  final String title;
  final RxBool isLoading;
  final Widget? loadingWidget;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Obx(() {
            if (isLoading.value) {
              if (loadingWidget != null) {
                return loadingWidget!;
              } else {
                return LoadingBouncingGrid.circle(
                  size: 20,
                  backgroundColor: Colors.white,
                );
              }
            }
            return Container();
          }),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
          Container()
        ],
      ),
    );
  }
}
