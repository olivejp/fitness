import 'package:fitnc_user/page/login/login.page.dart';
import 'package:fitnc_user/widget/bottom.widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'login.controller.dart';

class LoginDesktopPage extends StatelessWidget {
  final LoginPageController controller = Get.find();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(),
        const DecoFirstSlide(),
        const DecoSecondSlide(),
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
                        'Fitness Nc',
                        style: GoogleFonts.alfaSlabOne(
                          color: Theme.of(context).primaryColor,
                          fontSize: 25,
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
                            LoginForm(formKey: formKey),
                            Padding(
                              padding: const EdgeInsets.only(top: 30),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size(double.infinity, 55),
                                ),
                                onPressed: () => controller.authenticate(formKey),
                                child: Text(
                                  'Continuer',
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
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 30, left: 20),
                      child: Row(
                        children: <Widget>[
                          const Text("Vous n'avez pas de compte ?"),
                          TextButton(
                            onPressed: () => Navigator.pushNamed(context, '/sign_up'),
                            child: const Text(
                              "S'incrire",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
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
        ..translate(MediaQuery.of(context).size.width - 80)
        ..add(Matrix4.skewX(-0.3)),
      child: Container(
        width: 20,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
            colors: <Color>[Colors.amber.withAlpha(100), Colors.amber.shade700],
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
        ..translate(MediaQuery.of(context).size.width)
        ..add(Matrix4.skewX(-0.3)),
      child: Container(
        width: 200,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
            colors: <Color>[Colors.amber.withAlpha(100), Colors.amber.shade700],
          ),
        ),
      ),
    );
  }
}
