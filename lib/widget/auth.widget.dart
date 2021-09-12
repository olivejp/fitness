import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnc_user/page/home/home.page.dart';
import 'package:fitnc_user/page/login/login.page.dart';
import 'package:fitness_domain/service/auth.service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AuthWidget extends StatelessWidget {
  AuthWidget({Key? key}) : super(key: key);
  final AuthService authService = Get.find();

  @override
  Widget build(BuildContext context) {
    final AuthService authService = Get.find();
    return StreamBuilder<User?>(
      stream: authService.listenUserConnected(),
      builder: (_, AsyncSnapshot<User?> snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final User? user = snapshot.data;
          return user != null ? HomePage() : LoginPage();
        }
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}
