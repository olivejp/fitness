import 'package:fitnc_user/page/login/login.mobile.page.dart';
import 'package:fitnc_user/page/login/sign-up.controller.dart';
import 'package:fitnc_user/page/login/sign-up.page.dart';
import 'package:fitness_domain/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

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

class SignUpForm extends StatelessWidget {
  SignUpForm({
    Key? key,
    required this.callback,
    this.accountTextColor = Colors.white,
    this.headlineColor = Colors.white,
  }) : super(key: key);
  final SignUpController controller = Get.find();
  final HidePasswordController hidePasswordController =
      Get.put(HidePasswordController());
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final CallbackUserCredential? callback;
  final Color accountTextColor;
  final Color headlineColor;

  @override
  Widget build(BuildContext context) {
    final OutlineInputBorder defaultBorder = OutlineInputBorder(
      borderSide: BorderSide(width: 0.5, color: Theme.of(context).primaryColor),
    );

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'signUp'.tr,
            style: Theme.of(context)
                .textTheme
                .headline3
                ?.copyWith(color: headlineColor),
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
              onChanged: (String value) => controller.email = value,
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
                style: GoogleFonts.roboto(fontSize: 15),
                decoration: InputDecoration(
                  fillColor: Colors.white,
                  filled: true,
                  labelStyle: GoogleFonts.roboto(fontSize: 15),
                  focusedBorder: defaultBorder,
                  border: defaultBorder,
                  enabledBorder: defaultBorder,
                  labelText: 'name'.tr,
                ),
                onChanged: (String value) => controller.name = value,
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'pleaseFillYourName'.tr;
                  }
                }),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: TextFormField(
                style: GoogleFonts.roboto(fontSize: 15),
                decoration: InputDecoration(
                  fillColor: Colors.white,
                  filled: true,
                  labelText: 'surname'.tr,
                  focusedBorder: defaultBorder,
                  border: defaultBorder,
                  enabledBorder: defaultBorder,
                ),
                onChanged: (String value) => controller.prenom = value,
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'pleaseFillYourFirstName'.tr;
                  }
                }),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: TextFormField(
              style: GoogleFonts.roboto(fontSize: 15),
              onChanged: (String value) => controller.telephone = value,
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
                  onChanged: (String value) => controller.password = value,
                  obscureText: hidePasswordController.hidePassword1.value,
                  decoration: InputDecoration(
                      fillColor: Colors.white,
                      filled: true,
                      labelText: 'password'.tr,
                      focusedBorder: defaultBorder,
                      border: defaultBorder,
                      enabledBorder: defaultBorder,
                      suffixIcon: IconButton(
                        tooltip: hidePasswordController.hidePassword1.value
                            ? 'showPassword'.tr
                            : 'hidePassword'.tr,
                        onPressed: hidePasswordController.switchPassword1,
                        icon: hidePasswordController.hidePassword1.value
                            ? const Icon(Icons.visibility_outlined)
                            : const Icon(Icons.visibility_off_outlined),
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
                  onChanged: (String value) => controller.passwordCheck = value,
                  obscureText: hidePasswordController.hidePassword2.value,
                  decoration: InputDecoration(
                      fillColor: Colors.white,
                      filled: true,
                      focusedBorder: defaultBorder,
                      border: defaultBorder,
                      enabledBorder: defaultBorder,
                      labelText: 'retypePassword'.tr,
                      suffixIcon: IconButton(
                          tooltip: hidePasswordController.hidePassword2.value
                              ? 'showPassword'.tr
                              : 'hidePassword'.tr,
                          onPressed: hidePasswordController.switchPassword2,
                          icon: hidePasswordController.hidePassword2.value
                              ? const Icon(Icons.visibility_outlined)
                              : const Icon(Icons.visibility_off_outlined))),
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'noEmptyPassword'.tr;
                    }
                    if (controller.password != controller.passwordCheck) {
                      return 'noIdenticalPassword'.tr;
                    }
                  }),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: ElevatedLoadingButton(
              onPressed: () => controller.validateSignUp(_formKey, callback),
              title: 'signUp'.tr,
              isLoading: controller.isLoading,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'haveAnAccount'.tr,
                  style: TextStyle(color: accountTextColor),
                ),
                TextButton(
                  onPressed: () => Get.offNamed(FitnessConstants.routeLogin),
                  child: Text(
                    'signIn'.tr,
                  ),
                ),
              ],
            ),
          ),
          Obx(
            () {
              if (controller.errors.value.isNotEmpty == true) {
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
    );
  }
}
