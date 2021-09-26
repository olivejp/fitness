import 'package:fitnc_user/widget/firebase.widget.dart';
import 'package:fitnc_user/widget/layout-display.widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:oktoast/oktoast.dart';

import 'constants.dart';
import 'controller/display-type.controller.dart';

void main() {
  runApp(const MyApp());
}

class LocalStorageWidget extends StatelessWidget {
  const LocalStorageWidget({Key? key, required this.builder}) : super(key: key);
  static const String isDarkModeKey = 'isDarkMode';
  final Widget Function() builder;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: GetStorage.init(),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data!) {
          final GetStorage box = GetStorage();
          dynamic isDarkMode = box.read(isDarkModeKey);
          if (isDarkMode == null || isDarkMode is! bool) {
            box.write(isDarkModeKey, false);
          }
          return builder();
        } else {
          return Container();
        }
      },
    );
  }
}

class DarkModeController extends GetxController {
  final GetStorage box = GetStorage();
  DarkModeController() {
    notifier.value = box.read(LocalStorageWidget.isDarkModeKey);
    box.listenKey(LocalStorageWidget.isDarkModeKey, (value) {
      if (value != null && value is bool) {
        notifier.value = value;
      }
    });
  }

  void switchDarkMode() {
    box.write(LocalStorageWidget.isDarkModeKey, !notifier.value).then((value) => print('Saved on file !'));
  }

  final ValueNotifier<bool> notifier = ValueNotifier(false);
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OKToast(
      child: LocalStorageWidget(
        builder: () {
          Get.put(DisplayTypeController());
          final DarkModeController darkModeController = Get.put(DarkModeController());
          return ValueListenableBuilder<bool>(
            valueListenable: darkModeController.notifier,
            builder: (_, isDarkMode, __) {
              return GetMaterialApp(
                title: FitnessConstants.appTitle,
                debugShowCheckedModeBanner: false,
                themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
                darkTheme: ThemeData(
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
          );
        },
      ),
    );
  }
}
