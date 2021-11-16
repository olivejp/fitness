import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fitnc_user/fitness_translations.dart';
import 'package:fitnc_user/page/main/main.page.dart';
import 'package:fitnc_user/page/login/login.page.dart';
import 'package:fitnc_user/page/login/sign-up.page.dart';
import 'package:fitnc_user/service/config.service.dart';
import 'package:fitnc_user/service/connectivity.service.dart';
import 'package:fitnc_user/service/exercice.service.dart';
import 'package:fitnc_user/service/fitness-user.service.dart';
import 'package:fitnc_user/service/published_programme.service.dart';
import 'package:fitnc_user/service/trainers.service.dart';
import 'package:fitnc_user/service/user-set.service.dart';
import 'package:fitnc_user/service/workout-instance.service.dart';
import 'package:fitnc_user/theming.dart';
import 'package:fitnc_user/widget/dark-mode.widget.dart';
import 'package:fitness_domain/constants.dart';
import 'package:fitness_domain/middleware/is_connected_middleware.dart';
import 'package:fitness_domain/middleware/layout_notifier_middleware.dart';
import 'package:fitness_domain/service/auth.service.dart';
import 'package:fitness_domain/service/display.service.dart';
import 'package:fitness_domain/service/firebase-storage.service.dart';
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

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Firebase.initializeApp(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          ConfigService configService = Get.put(ConfigService());
          Get.lazyPut(() => DarkModeController());
          Get.lazyPut(() => ConnectivityService());
          Get.lazyPut(() => DisplayTypeService());
          Get.lazyPut(() => AuthService());
          Get.lazyPut(() => FitnessUserService());
          Get.lazyPut(() => PublishedProgrammeService());
          Get.lazyPut(() => TrainersService());
          Get.lazyPut(() => FirebaseStorageService());
          Get.lazyPut(() => ExerciceService());
          Get.lazyPut(() => WorkoutInstanceService());
          Get.lazyPut(() => UserSetService());

          // Pour les tests sur Cloud Functions
          if (configService.get(FitnessMobileConstants.profileCommandLineArgument) ==
              'DEV') {
            print(
                '[WARNING] Application launched with profile DEV : Firebase Function emulators will be used.');
            FirebaseFunctions.instanceFor(region: FitnessMobileConstants.firebaseRegion)
                .useFunctionsEmulator('localhost', 5001);
          }

          return OKToast(
            child: DarkModeWidget(
              builder: () {
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
        return Container();
      },
    );
  }

  ///
  /// Routing de l'application
  ///
  List<GetPage<dynamic>> getPages() {
    return <GetPage<dynamic>>[
      GetPage<MainPage>(
        name: FitnessConstants.routeHome,
        middlewares: <GetMiddleware>[
          IsConnectedMiddleware(),
          LayoutNotifierMiddleware(),
        ],
        page: () => MainPage(),
      ),
      GetPage<SignUpPage>(
        transition: Transition.rightToLeft,
        name: FitnessConstants.routeSignUp,
        middlewares: <GetMiddleware>[LayoutNotifierMiddleware()],
        page: () => SignUpPage(callback: (userCredential) => Get.offNamed(FitnessConstants.routeHome),),
      ),
      GetPage<LoginPage>(
        transition: Transition.rightToLeft,
        name: FitnessConstants.routeLogin,
        middlewares: <GetMiddleware>[LayoutNotifierMiddleware()],
        page: () => LoginPage(),
      ),
    ];
  }
}
