import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnc_user/controller/display-type.controller.dart';
import 'package:fitnc_user/page/login/login.desktop.page.dart';
import 'package:fitnc_user/page/login/login.mobile.page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../constants.dart';
import 'login.controller.dart';

typedef CallbackUserCredential = void Function(UserCredential userCredential);

class LoginPage extends StatelessWidget {
  LoginPage({Key? key, this.callback}) : super(key: key);

  final CallbackUserCredential? callback;
  final LoginPageController controller = Get.put(LoginPageController());
  final DisplayTypeController displayTypeController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FitnessNcColors.blue50,
      body: GetX<DisplayTypeController>(
        builder: (DisplayTypeController controller) {
          print('${displayTypeController.displayType.value}');
          return (<DisplayType>[DisplayType.tablet, DisplayType.mobile].contains(displayTypeController.displayType.value))
              ? LoginMobilePage()
              : LoginDesktopPage();
        },
      ),
    );
  }
}

class LoginForm extends StatelessWidget {
  LoginForm({Key? key, required this.formKey}) : super(key: key);

  final GlobalKey<FormState> formKey;
  final LoginPageController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 30),
            child: Obx(
              () => TextFormField(
                initialValue: controller.email,
                style: GoogleFonts.roboto(fontSize: 15),
                decoration: InputDecoration(
                  labelText: 'Email',
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
                onFieldSubmitted: (String value) => controller.authenticate(formKey),
                validator: (String? value) {
                  String? emailTrimmed = value?.trim();
                  if (emailTrimmed == null || emailTrimmed.isEmpty) {
                    return 'Merci de renseigner votre adresse email.';
                  }
                  if (!RegExp(
                    r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$',
                  ).hasMatch(emailTrimmed)) {
                    return "L'adresse mail n'est pas formatée correctement'.";
                  }
                  return null;
                },
                textInputAction: TextInputAction.done,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 30),
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
                      labelText: 'Mot de passe',
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(width: 0.5, color: Theme.of(context).primaryColor),
                      ),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(width: 0.5, color: Theme.of(context).primaryColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(width: 0.5, color: Theme.of(context).primaryColor),
                      ),
                      hintStyle: GoogleFonts.roboto(fontSize: 15),
                      suffixIcon: IconButton(
                        tooltip: controller.hidePassword ? 'Afficher le mot de passe' : 'Masquer le mot de passe',
                        onPressed: () => controller.hidePassword = !controller.hidePassword,
                        icon: controller.hidePassword
                            ? const Icon(Icons.visibility_off_outlined)
                            : const Icon(
                                Icons.visibility_outlined,
                              ),
                      ),
                    ),
                    onChanged: (String value) => controller.password = value,
                    onFieldSubmitted: (_) => controller.authenticate(formKey),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    /// TODO
                  },
                  child: const Text(
                    'Mot de passe oublié ?',
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
