import 'package:fitnc_user/constants.dart';
import 'package:fitnc_user/page/login/login.page.dart';
import 'package:fitnc_user/page/login/sign-up.page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'login.controller.dart';

class LoginMobilePage extends StatelessWidget {
  LoginMobilePage({Key? key}) : super(key: key);

  final LoginPageController controller = Get.find();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 30, left: 20),
                      child: Text(
                        FitnessConstants.appTitle,
                        style: GoogleFonts.alfaSlabOne(
                          color: Theme
                              .of(context)
                              .primaryColor,
                          fontSize: 25,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(30.0),
                      child: Column(
                        children: <Widget>[
                          LoginForm(
                            formKey: formKey,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 30),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 55),
                              ),
                              onPressed: () => controller.authenticate(formKey),
                              child: Text(
                                'Se connecter',
                                style: GoogleFonts.roboto(
                                  color: Color(Colors.white.value),
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 15),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 55),
                              ),
                              onPressed: () =>
                                  Navigator.push(context,
                                    MaterialPageRoute(builder: (_) => const SignUpPage(),),),
                              child: Text(
                                "Créer un compte",
                                style: GoogleFonts.roboto(
                                  color: Color(Colors.white.value),
                                  fontSize: 15,
                                ),
                              ),
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
      ],
    );
  }
}
