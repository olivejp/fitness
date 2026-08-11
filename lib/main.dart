import 'dart:developer' as developer;

import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fitnc_user/di.dart';
import 'package:fitnc_user/l10n/l10n.dart';
import 'package:fitnc_user/page/startup-error/startup-error.page.dart';
import 'package:fitnc_user/router.dart';
import 'package:fitnc_user/service/config.service.dart';
import 'package:fitnc_user/theming.dart';
import 'package:fitnc_user/widget/connectivity-banner.widget.dart';
import 'package:fitnc_user/widget/layout-display.widget.dart';
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';

import 'package:fitnc_user/constants.dart';
import 'package:fitnc_user/service/dark-mode.service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Enregistrement des services avant tout rendu. Seul SharedPreferences est
  // réellement construit ici ; les autres singletons restent lazy, donc aucune
  // dépendance à Firebase à ce stade.
  await configureDependencies();

  runApp(const MyApp());
}

///
/// Amorçage de l'application.
///
/// L'initialisation de Firebase est lancée **une seule fois**, dans initState.
/// Elle était auparavant déclenchée depuis build() via un FutureBuilder : elle
/// repartait donc à chaque reconstruction, et son échec n'était pas traité du
/// tout — l'application restait sur un écran blanc muet.
///
class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

enum _StartupState { pending, ready, failed }

class _MyAppState extends State<MyApp> {
  _StartupState _state = _StartupState.pending;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    setState(() {
      _state = _StartupState.pending;
      _error = null;
    });

    try {
      await Firebase.initializeApp();
      _configureFunctionsEmulator();
      if (mounted) {
        setState(() => _state = _StartupState.ready);
      }
    } catch (error, stackTrace) {
      developer.log(
        "Échec de l'initialisation de Firebase.",
        name: 'startup',
        error: error,
        stackTrace: stackTrace,
        level: 1000,
      );
      if (mounted) {
        setState(() {
          _state = _StartupState.failed;
          _error = error;
        });
      }
    }
  }

  /// Pour les tests sur Cloud Functions.
  void _configureFunctionsEmulator() {
    final ConfigService configService = di<ConfigService>();
    if (configService.get(FitnessConstants.profileCommandLineArgument) ==
        'DEV') {
      developer.log(
        '[WARNING] Application launched with profile DEV : Firebase Function emulators will be used.',
        level: 100,
      );
      FirebaseFunctions.instanceFor(
              region: FitnessConstants.firebaseRegion)
          .useFunctionsEmulator('localhost', 5001);
    }
  }

  ///
  /// Habillage commun aux deux `MaterialApp`, inséré au-dessus du `Navigator`.
  ///
  /// [LayoutNotifier] remplace LayoutNotifierMiddleware : le notifier était
  /// appliqué à chacune des trois routes, il enveloppe désormais l'application
  /// entière. [ConnectivityBanner] signale la perte de réseau sur tous les
  /// écrans.
  ///
  Widget _wrap(BuildContext context, Widget? child) {
    return LayoutNotifier(
      child: ConnectivityBanner(child: child ?? const SizedBox.shrink()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return OKToast(
      child: ValueListenableBuilder<bool>(
        valueListenable: di<DarkModeService>().notifier,
        builder: (_, bool isDarkMode, __) {
          // Le routeur n'est monté qu'une fois Firebase prêt : ses gardes
          // interrogent FirebaseAuth, qui n'existe pas avant.
          if (_state == _StartupState.ready) {
            return MaterialApp.router(
              routerConfig: appRouter,
              title: FitnessConstants.appTitle,
              debugShowCheckedModeBanner: false,
              themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
              darkTheme: Theming.getDarkTheme(),
              theme: Theming.getLightTheme(),
              // La locale suit l'appareil ; l'anglais sert de repli.
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              builder: _wrap,
            );
          }

          return MaterialApp(
            title: FitnessConstants.appTitle,
            debugShowCheckedModeBanner: false,
            themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
            darkTheme: Theming.getDarkTheme(),
            theme: Theming.getLightTheme(),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            // Le même habillage que l'application prête : l'écran d'échec de
            // démarrage invite à vérifier la connexion, autant lui dire quand
            // c'est précisément elle qui manque.
            builder: _wrap,
            home: _state == _StartupState.failed
                ? StartupErrorPage(
                    error: _error ?? 'Erreur inconnue',
                    onRetry: _initialize,
                  )
                : const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  ),
          );
        },
      ),
    );
  }
}
