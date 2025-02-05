import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fitnc_user/dependencies_injector.dart';
import 'package:fitnc_user/firebase_options.dart';
import 'package:fitnc_user/fitness_router.dart';
import 'package:fitnc_user/notifier/application_settings_notifier.dart';
import 'package:fitnc_user/page/main/main.controller.dart';
import 'package:fitnc_user/page/main/user.notifier.dart';
import 'package:fitnc_user/service/config.service.dart';
import 'package:fitnc_user/service/debug_printer.dart';
import 'package:fitnc_user/theming.dart';
import 'package:fitness_domain/service/display.service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:localization/localization.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'constants.dart';

/**
 * Méthode main qui permet de lancer l'application.
 **/
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Init de Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Init de Supabase
  await Supabase.initialize(
    url: 'https://pfiomrpdmpgjwqdumdoq.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBmaW9tcnBkbXBnandxZHVtZG9xIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzgyODI2OTQsImV4cCI6MjA1Mzg1ODY5NH0.tkkYqny8QnCre54ajUMsfvECiZnSQ_zBByQ7Xj-1_p8',
  );

  // Persist all data in local repository (Web only).
  if (kIsWeb) {
    FirebaseFirestore db = FirebaseFirestore.instance;
    db.enablePersistence(const PersistenceSettings(synchronizeTabs: true));
  }

  GetItDependenciesInjector.initialize();

  runApp(const MyApp());
}

/**
 * Widget principal de l'application.
 */
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    LocalJsonLocalization.delegate.directories = ['i18n'];
    return MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: ApplicationSettingsNotifier()),
          ChangeNotifierProvider.value(value: DisplayTypeNotifier()),
          ChangeNotifierProvider.value(value: MainController()),
          ChangeNotifierProvider.value(value: UserNotifier()),
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
          return Consumer<ApplicationSettingsNotifier>(builder: (_, settingsNotifier, __) {
            return MaterialApp.router(
              themeMode: settingsNotifier.dark ? ThemeMode.dark : ThemeMode.light,
              debugShowCheckedModeBanner: false,
              title: FitnessMobileConstants.appTitle,
              routerConfig: FitnessRouter.getRouter(),
              theme: Theming.getLightTheme(),
              darkTheme: Theming.getDarkTheme(),
              locale: settingsNotifier.locale,
              supportedLocales: settingsNotifier.getSupportedLocales(),
              localizationsDelegates: [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
                LocalJsonLocalization.delegate,
              ],
            );
          });
        });
  }
}
