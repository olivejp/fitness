import 'package:fitnc_user/fitness_translations.dart';
import 'package:fitnc_user/page/login/login.page.dart';
import 'package:fitnc_user/page/login/sign-up.page.dart';
import 'package:fitnc_user/service/config.service.dart';
import 'package:fitnc_user/service/connectivity.service.dart';
import 'package:fitnc_user/service/fitness-user.service.dart';
import 'package:fitnc_user/service/published_programme.service.dart';
import 'package:fitnc_user/service/trainers.service.dart';
import 'package:fitnc_user/theming.dart';
import 'package:fitnc_user/widget/dark-mode.widget.dart';
import 'package:fitnc_user/widget/firebase.widget.dart';
import 'package:fitness_domain/constants.dart';
import 'package:fitness_domain/middleware/is_connected_middleware.dart';
import 'package:fitness_domain/middleware/layout_notifier_middleware.dart';
import 'package:fitness_domain/service/auth.service.dart';
import 'package:fitness_domain/service/display.service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oktoast/oktoast.dart';

import 'constants.dart';
import 'controller/dark-mode.controller.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  initServices() {
    Get.lazyPut(() => ConfigService());
    Get.lazyPut(() => ConnectivityService());
    Get.lazyPut(() => DisplayTypeService());
    Get.lazyPut(() => DarkModeController());
    Get.lazyPut(() => DarkModeController());
    Get.lazyPut(() => AuthService());
    Get.lazyPut(() => FitnessUserService());
    Get.lazyPut(() => PublishedProgrammeService());
    Get.lazyPut(() => TrainersService());
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
                initialRoute: FitnessConstants.routeHome,
                title: FitnessMobileConstants.appTitle,
                debugShowCheckedModeBanner: false,
                themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
                darkTheme: Theming.getDarkTheme(),
                theme: Theming.getLightTheme(),
                locale: Get.deviceLocale,
                fallbackLocale: const Locale('en', 'US'),
                getPages: getPages(),
                translations: FitnessTranslations(),
              );
            },
          );
        },
      ),
    );
  }

  ///
  /// Routing de l'application
  ///
  List<GetPage<dynamic>> getPages() {
    return <GetPage<dynamic>>[
      GetPage<FirebaseWidget>(
        name: FitnessConstants.routeHome,
        middlewares: <GetMiddleware>[
          IsConnectedMiddleware(),
          LayoutNotifierMiddleware(),
        ],
        page: () => FirebaseWidget(),
      ),
      GetPage<SignUpPage>(
        name: FitnessConstants.routeSignUp,
        middlewares: <GetMiddleware>[LayoutNotifierMiddleware()],
        page: () => SignUpPage(
          callback: (userCredential) =>
              Get.offNamed(FitnessConstants.routeHome),
        ),
      ),
      GetPage<LoginPage>(
        name: FitnessConstants.routeLogin,
        middlewares: <GetMiddleware>[LayoutNotifierMiddleware()],
        page: () => LoginPage(
          callback: (userCredential) =>
              Get.offNamed(FitnessConstants.routeHome),
        ),
      ),
    ];
  }
}
