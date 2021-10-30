import 'package:fitnc_user/fitness_translations.dart';
import 'package:fitnc_user/service/connectivity.service.dart';
import 'package:fitnc_user/theming.dart';
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

  initServices(){
    Get.put(ConnectivityService());
    Get.put(DisplayTypeController());
    Get.put(DarkModeController());
  }

  @override
  Widget build(BuildContext context) {
    return OKToast(
      child: DarkModeWidget(
        builder: () {
          initServices();
          final DarkModeController darkModeController = Get.find();
          return ValueListenableBuilder<bool>(
            valueListenable: darkModeController.notifier,
            builder: (_, isDarkMode, __) {
              return GetMaterialApp(
                title: FitnessConstants.appTitle,
                debugShowCheckedModeBanner: false,
                themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
                darkTheme: Theming.getDarkTheme(),
                theme: Theming.getLightTheme(),
                locale: Get.deviceLocale,
                fallbackLocale: const Locale('en', 'US'),
                translations: FitnessTranslations(),
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
