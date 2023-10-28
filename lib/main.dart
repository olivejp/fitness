import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fitnc_user/dependencies_injector.dart';
import 'package:fitnc_user/firebase_options.dart';
import 'package:fitnc_user/fitness_translations.dart';
import 'package:fitnc_user/notifier/dark-mode.notifier.dart';
import 'package:fitnc_user/page/login/login.page.dart';
import 'package:fitnc_user/page/main/main.page.dart';
import 'package:fitnc_user/page/sign_up/sign-up.page.dart';
import 'package:fitnc_user/service/config.service.dart';
import 'package:fitnc_user/service/debug_printer.dart';
import 'package:fitnc_user/theming.dart';
import 'package:fitnc_user/widget/dark-mode.widget.dart';
import 'package:fitness_domain/constants.dart';
import 'package:fitness_domain/middleware/is_connected_middleware.dart';
import 'package:fitness_domain/middleware/layout_notifier_middleware.dart';
import 'package:fitness_domain/service/display.service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';

import 'constants.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  GetItDependenciesInjector.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => DisplayTypeNotifier()),
          ChangeNotifierProvider(create: (_) => DarkModeNotifier()),
        ],
        builder: (context, child) {
          final ConfigService configService = GetIt.I.get();

          // Pour les tests sur Cloud Functions
          if (configService.get(FitnessMobileConstants.profileCommandLineArgument) == 'DEV') {
            DebugPrinter.printLn(
                '[WARNING] Application launched with profile DEV : Firebase Function emulators will be used.');
            FirebaseFunctions.instanceFor(region: FitnessMobileConstants.firebaseRegion)
                .useFunctionsEmulator('localhost', 5001);
          }

          return OKToast(
            child: DarkModeWidget(
              builder: () {
                return Consumer<DarkModeNotifier>(builder: (context, darkModeNotifier, child) {
                  return GetMaterialApp(
                    initialRoute: FitnessConstants.routeHome,
                    title: FitnessMobileConstants.appTitle,
                    debugShowCheckedModeBanner: false,
                    themeMode: darkModeNotifier.isDark ? ThemeMode.dark : ThemeMode.light,
                    darkTheme: Theming.getDarkTheme(),
                    theme: Theming.getLightTheme(),
                    locale: Get.deviceLocale,
                    fallbackLocale: const Locale('en', 'US'),
                    getPages: getPages(),
                    translations: FitnessTranslations(),
                  );
                });
              },
            ),
          );
        });
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
        page: () => const MainPage(),
      ),
      GetPage<SignUpPage>(
        transition: Transition.rightToLeft,
        name: FitnessConstants.routeSignUp,
        middlewares: <GetMiddleware>[LayoutNotifierMiddleware()],
        page: () => SignUpPage(
          callback: (userCredential) => Get.offNamed(FitnessConstants.routeHome),
        ),
      ),
      GetPage<LoginPage>(
        transition: Transition.rightToLeft,
        name: FitnessConstants.routeLogin,
        middlewares: <GetMiddleware>[LayoutNotifierMiddleware()],
        page: () => const LoginPage(),
      ),
    ];
  }
}
