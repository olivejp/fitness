import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnc_user/page/login/login.desktop.page.dart';
import 'package:fitnc_user/page/login/login.mobile.page.dart';
import 'package:fitness_domain/service/display.service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:oktoast/oktoast.dart';

import '../../constants.dart';
import 'login.controller.dart';

typedef CallbackUserCredential = void Function(UserCredential userCredential);

class LoginPage extends StatelessWidget {
  LoginPage({Key? key, this.callback}) : super(key: key);

  final CallbackUserCredential? callback;
  final LoginPageController controller = Get.put(LoginPageController());
  final DisplayTypeService displayTypeController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FitnessNcColors.blue50,
      body: GetX<DisplayTypeService>(
        builder: (DisplayTypeService controller) {
          print('${displayTypeController.displayType.value}');
          return (<DisplayType>[DisplayType.mobile]
                  .contains(displayTypeController.displayType.value))
              ? LoginMobilePage(callback: callback,)
              : LoginDesktopPage(callback: callback, );
        },
      ),
    );
  }
}

class LoginForm extends StatelessWidget {
  LoginForm(
      {Key? key,
      required this.formKey,
      this.paddingTop = 30,
      this.paddingInBetween = 30})
      : super(key: key);

  final GlobalKey<FormState> formKey;
  final LoginPageController controller = Get.find();
  final double paddingTop;
  final double paddingInBetween;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: paddingTop),
            child: Obx(
              () => TextFormField(
                initialValue: controller.email,
                style: GoogleFonts.roboto(fontSize: 15),
                decoration: InputDecoration(
                  labelText: 'mail'.tr,
                  hintStyle: GoogleFonts.roboto(fontSize: 15),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      width: 0.5,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      width: 0.5,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      width: 0.5,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
                onChanged: (String value) => controller.email = value,
                onFieldSubmitted: (String value) =>
                    controller.authenticate(formKey),
                validator: (String? value) {
                  String? emailTrimmed = value?.trim();
                  if (emailTrimmed == null || emailTrimmed.isEmpty) {
                    return 'pleaseFillEmail'.tr;
                  }
                  if (!RegExp(
                    r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$',
                  ).hasMatch(emailTrimmed)) {
                    return 'emailNotCorrect'.tr;
                  }
                  return null;
                },
                textInputAction: TextInputAction.done,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: paddingInBetween),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Obx(
                  () => TextFormField(
                    initialValue: controller.password,
                    style: GoogleFonts.roboto(fontSize: 15),
                    obscureText: controller.hidePassword,
                    enableSuggestions: false,
                    autocorrect: false,
                    decoration: InputDecoration(
                      labelText: 'password'.tr,
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          width: 0.5,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          width: 0.5,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          width: 0.5,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      hintStyle: GoogleFonts.roboto(fontSize: 15),
                      suffixIcon: IconButton(
                        tooltip: controller.hidePassword
                            ? 'showPassword'.tr
                            : 'hidePassword'.tr,
                        onPressed: () =>
                            controller.hidePassword = !controller.hidePassword,
                        icon: controller.hidePassword
                            ? const Icon(Icons.visibility_outlined)
                            : const Icon(Icons.visibility_off_outlined),
                      ),
                    ),
                    onChanged: (String value) => controller.password = value,
                    onFieldSubmitted: (_) => controller.authenticate(formKey),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    if (controller.email.isNotEmpty) {
                      controller.sendPasswordResetEmail().then(
                            (value) => showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text('lostPassword'.tr),
                                content: Text('descriptionLostPassword'.tr),
                                actions: [
                                  TextButton(
                                    child: Text('iUnderstood'.tr),
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                  ),
                                ],
                              ),
                            ),
                          );
                    } else {
                      showToast('pleaseFillEmail'.tr);
                    }
                  },
                  child: Text(
                    'lostPasswordQuestion'.tr,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
