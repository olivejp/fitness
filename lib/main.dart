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

class DarkModeController extends GetxController {
  DarkModeNotifier notifier = DarkModeNotifier(true);
}

class DarkModeNotifier extends ValueNotifier<bool> {
  // TODO aller récupérer la valeur initiale dans le storage local.
  DarkModeNotifier(bool value) : super(value);

  void switchMode(bool toDarkMode) {
    value = toDarkMode;
    notifyListeners();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.put(DisplayTypeController());
    DarkModeController darkModeController = Get.put(DarkModeController());
    return OKToast(
      child: ValueListenableBuilder<bool>(
        valueListenable: darkModeController.notifier,
        builder: (_, isDarkMode, __) {
          print(isDarkMode);
          ThemeMode mode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
          return GetMaterialApp(
            title: FitnessConstants.appTitle,
            debugShowCheckedModeBanner: false,
            themeMode: mode,
            darkTheme:
            // ThemeData.dark(),
            ThemeData(
                primarySwatch: Colors.amber,
                cardColor: Colors.grey[800],
                dividerColor: const Color(0x1FFFFFFF),
                canvasColor: Colors.grey[850],
                shadowColor: Colors.black,
                iconTheme: const IconThemeData(color: Colors.white),
              textTheme:  Typography.material2014(platform: TargetPlatform.android).white,
            ),
            theme: ThemeData(
              primarySwatch: Colors.amber,
              bottomAppBarTheme: const BottomAppBarTheme(
                color: FitnessNcColors.white50,
              ),
              appBarTheme: const AppBarTheme(
                centerTitle: true,
                color: FitnessNcColors.darkChipBackground,
                titleTextStyle: TextStyle(color: FitnessNcColors.amber),
              ),
            ),
            home: LayoutDisplayNotifier(
              child: const FirebaseWidget(),
            ),
          );
        },
      ),
    );
  }
}
