import 'package:fitnc_user/widget/firebase.widget.dart';
import 'package:fitnc_user/widget/layout-display.widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oktoast/oktoast.dart';

import 'constants.dart';
import 'controller/display-type.controller.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.put(DisplayTypeController());
    return OKToast(
      child: GetMaterialApp(
        title: FitnessConstants.appTitle,
        theme: ThemeData(
          bottomAppBarTheme: const BottomAppBarTheme(
            shape: CircularNotchedRectangle(),
            color: FitnessNcColors.darkChipBackground,
          ),
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            color: FitnessNcColors.darkChipBackground,
            titleTextStyle: TextStyle(color: FitnessNcColors.amber),
          ),
          primarySwatch: Colors.amber,
        ),
        home: LayoutDisplayNotifier(
          child: const FirebaseWidget(),
        ),
      ),
    );
  }
}
