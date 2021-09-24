import 'package:fitnc_user/widget/firebase.widget.dart';
import 'package:fitnc_user/widget/layout-display.widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oktoast/oktoast.dart';

import 'constants.dart';
import 'controller/day-selection.controller.dart';
import 'controller/display-type.controller.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.put(DisplayTypeController());
    Get.put(DaySelectionController());
    return OKToast(
      child: GetMaterialApp(
        title: FitnessConstants.appTitle,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          bottomAppBarTheme: const BottomAppBarTheme(
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
