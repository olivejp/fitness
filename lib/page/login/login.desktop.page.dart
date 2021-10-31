import 'package:fitnc_user/page/login/login.page.dart';
import 'package:fitnc_user/widget/bottom.widget.dart';
import 'package:fitness_domain/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animations/loading_animations.dart';

import 'login.controller.dart';

class LoginDesktopPage extends StatelessWidget {
  LoginDesktopPage({Key? key, this.callback}) : super(key: key);

  final LoginPageController controller = Get.find();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final CallbackUserCredential? callback;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
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
                        padding: const EdgeInsets.only(bottom: 30, left: 20),
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
                          padding: const EdgeInsets.all(60.0),
                          child: Column(
                            children: <Widget>[
                              Text(
                                'connectToYourAccount'.tr,
                                style: Theme.of(context).textTheme.headline3,
                              ),
                              LoginForm(formKey: formKey),
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
                              Obx(() => Text(controller.loginMsgError))
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 20, left: 20, bottom: 100),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text('noAccount'.tr),
                            TextButton(
                              onPressed: () =>
                                  Get.offNamed(FitnessConstants.routeSignUp),
                              child: Text(
                                'signUp'.tr,
                                style: const TextStyle(color: Colors.white),
                              ),
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
        const BottomCu(),
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
        ..translate(MediaQuery.of(context).size.width + 80)
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
        ..translate(MediaQuery.of(context).size.width + 140)
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
