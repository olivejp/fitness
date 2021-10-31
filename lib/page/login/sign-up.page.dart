import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnc_user/page/login/sign-up.controller.dart';
import 'package:fitness_domain/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

typedef CallbackUserCredential = void Function(UserCredential userCredential);

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key, this.callback}) : super(key: key);

  final CallbackUserCredential? callback;

  @override
  _SignUpPageState createState() {
    return _SignUpPageState();
  }
}

class _SignUpPageState extends State<SignUpPage> {
  _SignUpPageState();

  final SignUpController controller = Get.put(SignUpController());
  final HidePasswordController hidePasswordController =
      Get.put(HidePasswordController());
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final OutlineInputBorder defaultBorder = OutlineInputBorder(
      borderSide: BorderSide(width: 0.5, color: Theme.of(context).primaryColor),
    );

    void onPressedEnter() {
      controller.cleanError();
      if (_formKey.currentState?.validate() == true) {
        controller.signUp().then((UserCredential value) {
          if (widget.callback != null) {
            widget.callback!(value);
          }
        }).catchError((Object? error) {
          if (error is FirebaseAuthException) {
            controller.setError(error.message!);
          } else {
            controller.setError(error.toString());
          }
        });
      }
    }

    return SafeArea(
      child: Scaffold(
        backgroundColor: FitnessNcColors.blue50,
        body: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 500),
                    child: Padding(
                      padding: const EdgeInsets.all(30.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(bottom: 60),
                              child: Text(
                                FitnessConstants.appTitle,
                                style: Theme.of(context).textTheme.headline6,
                              ),
                            ),

                            Text(
                              'signUp'.tr,
                              style: Theme.of(context).textTheme.headline3,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 20),
                              child: TextFormField(
                                style: GoogleFonts.roboto(fontSize: 15),
                                decoration: InputDecoration(
                                  fillColor: Colors.white,
                                  filled: true,
                                  suffixIcon: const Icon(Icons.email),
                                  labelText: 'mail'.tr,
                                  focusedBorder: defaultBorder,
                                  border: defaultBorder,
                                  enabledBorder: defaultBorder,
                                ),
                                onChanged: (String value) =>
                                    controller.email = value,
                                validator: (String? value) {
                                  if (value == null || value.isEmpty) {
                                    return 'pleaseFillEmail'.tr;
                                  }
                                  if (!RegExp(
                                          r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
                                      .hasMatch(value)) {
                                    return 'emailNotCorrect'.tr;
                                  }
                                  return null;
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 20),
                              child: TextFormField(
                                  style:
                                  GoogleFonts.roboto(fontSize: 15),
                                  decoration: InputDecoration(
                                    fillColor: Colors.white,
                                    filled: true,
                                    labelStyle: GoogleFonts.roboto(
                                        fontSize: 15),
                                    focusedBorder: defaultBorder,
                                    border: defaultBorder,
                                    enabledBorder: defaultBorder,
                                    labelText: 'name'.tr,
                                  ),
                                  onChanged: (String value) =>
                                  controller.name = value,
                                  validator: (String? value) {
                                    if (value == null ||
                                        value.isEmpty) {
                                      return 'pleaseFillYourName'.tr;
                                    }
                                  }),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 20),
                              child: TextFormField(
                                  style:
                                  GoogleFonts.roboto(fontSize: 15),
                                  decoration: InputDecoration(
                                    fillColor: Colors.white,
                                    filled: true,
                                    labelText: 'surname'.tr,
                                    focusedBorder: defaultBorder,
                                    border: defaultBorder,
                                    enabledBorder: defaultBorder,
                                  ),
                                  onChanged: (String value) =>
                                  controller.prenom = value,
                                  validator: (String? value) {
                                    if (value == null ||
                                        value.isEmpty) {
                                      return 'pleaseFillYourFirstName'
                                          .tr;
                                    }
                                  }),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 20),
                              child: TextFormField(
                                style: GoogleFonts.roboto(fontSize: 15),
                                onChanged: (String value) =>
                                    controller.telephone = value,
                                decoration: InputDecoration(
                                  fillColor: Colors.white,
                                  filled: true,
                                  suffixIcon: const Icon(Icons.phone_android),
                                  labelText: 'phone'.tr,
                                  focusedBorder: defaultBorder,
                                  border: defaultBorder,
                                  enabledBorder: defaultBorder,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 60),
                              child: Obx(
                                () => TextFormField(
                                    style: GoogleFonts.roboto(fontSize: 15),
                                    onChanged: (String value) =>
                                        controller.password = value,
                                    obscureText: hidePasswordController
                                        .hidePassword1.value,
                                    decoration: InputDecoration(
                                        fillColor: Colors.white,
                                        filled: true,
                                        labelText: 'password'.tr,
                                        focusedBorder: defaultBorder,
                                        border: defaultBorder,
                                        enabledBorder: defaultBorder,
                                        suffixIcon: IconButton(
                                          tooltip: hidePasswordController
                                                  .hidePassword1.value
                                              ? 'showPassword'.tr
                                              : 'hidePassword'.tr,
                                          onPressed: hidePasswordController
                                              .switchPassword1,
                                          icon: hidePasswordController
                                                  .hidePassword1.value
                                              ? const Icon(
                                                  Icons.visibility_outlined)
                                              : const Icon(Icons
                                                  .visibility_off_outlined),
                                        )),
                                    validator: (String? value) {
                                      if (value == null || value.isEmpty) {
                                        return 'noEmptyPassword'.tr;
                                      }
                                    }),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 20),
                              child: Obx(
                                () => TextFormField(
                                    style: GoogleFonts.roboto(fontSize: 15),
                                    onChanged: (String value) =>
                                        controller.passwordCheck = value,
                                    obscureText: hidePasswordController
                                        .hidePassword2.value,
                                    decoration: InputDecoration(
                                        fillColor: Colors.white,
                                        filled: true,
                                        focusedBorder: defaultBorder,
                                        border: defaultBorder,
                                        enabledBorder: defaultBorder,
                                        labelText: 'retypePassword'.tr,
                                        suffixIcon: IconButton(
                                            tooltip: hidePasswordController
                                                    .hidePassword2.value
                                                ? 'showPassword'.tr
                                                : 'hidePassword'.tr,
                                            onPressed: hidePasswordController
                                                .switchPassword2,
                                            icon: hidePasswordController
                                                    .hidePassword2.value
                                                ? const Icon(
                                                    Icons.visibility_outlined)
                                                : const Icon(Icons
                                                    .visibility_off_outlined))),
                                    validator: (String? value) {
                                      if (value == null || value.isEmpty) {
                                        return 'noEmptyPassword'.tr;
                                      }
                                      if (controller.password !=
                                          controller.passwordCheck) {
                                        return 'noIdenticalPassword'.tr;
                                      }
                                    }),
                              ),
                            ),
                            Padding(
                                padding: const EdgeInsets.only(top: 20),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      minimumSize:
                                          const Size(double.infinity, 55)),
                                  onPressed: onPressedEnter,
                                  child: Text('signUp'.tr,
                                      style: GoogleFonts.roboto(
                                          color: Color(Colors.white.value),
                                          fontSize: 15)),
                                )),
                            Padding(
                              padding: const EdgeInsets.only(top: 30),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text('haveAnAccount'.tr),
                                  TextButton(
                                      onPressed: () => Get.offNamed(FitnessConstants.routeLogin),
                                      child: Text(
                                        'signIn'.tr,
                                      )),
                                ],
                              ),
                            ),
                            Obx(
                              () {
                                if (controller.errors.value.isNotEmpty ==
                                    true) {
                                  return Text(
                                    controller.errors.value,
                                    style: const TextStyle(color: Colors.red),
                                  );
                                } else {
                                  return Container();
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Controller pour changer l'état des boutons 'Hide password'.
class HidePasswordController extends GetxController {
  RxBool hidePassword1 = true.obs;
  RxBool hidePassword2 = true.obs;

  void switchPassword1() {
    hidePassword1.value = !hidePassword1.value;
  }

  void switchPassword2() {
    hidePassword2.value = !hidePassword2.value;
  }
}
