import 'package:fitnc_user/service/connectivity.service.dart';
import 'package:fitnc_user/widget/dark-mode.widget.dart';
import 'package:fitnc_user/widget/firebase.widget.dart';
import 'package:fitnc_user/widget/layout-display.widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oktoast/oktoast.dart';

import 'constants.dart';
import 'controller/dark-mode.controller.dart';
import 'controller/display-type.controller.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  ThemeData getLightTheme() {
    return ThemeData(
      primarySwatch: Colors.amber,
      bottomAppBarTheme: const BottomAppBarTheme(
        color: FitnessNcColors.white50,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        color: FitnessNcColors.darkChipBackground,
        titleTextStyle: TextStyle(color: FitnessNcColors.amber),
      ),
      textTheme: TextTheme(bodyText1: TextStyle())
    );
  }

  ThemeData getDarkTheme() {
    return ThemeData(
      primarySwatch: Colors.amber,
      cardColor: Colors.grey[800],
      dividerColor: const Color(0x1FFFFFFF),
      canvasColor: Colors.grey[850],
      bottomAppBarTheme: BottomAppBarTheme(
        color: Colors.grey[850],
      ),
      shadowColor: Colors.black54,
      iconTheme: const IconThemeData(color: Colors.white),
      textTheme: Typography.material2014(platform: TargetPlatform.android).white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return OKToast(
      child: LocalStorageWidget(
        builder: () {
          Get.put(ConnectivityService());
          Get.put(DisplayTypeController());
          final DarkModeController darkModeController = Get.put(DarkModeController());
          return ValueListenableBuilder<bool>(
            valueListenable: darkModeController.notifier,
            builder: (_, isDarkMode, __) {
              return GetMaterialApp(
                title: FitnessConstants.appTitle,
                debugShowCheckedModeBanner: false,
                themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
                darkTheme: getDarkTheme(),
                theme: getLightTheme(),
                home: LayoutDisplayNotifier(
                  child: const FirebaseWidget(),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
