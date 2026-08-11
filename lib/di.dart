import 'package:fitnc_user/service/dark-mode.service.dart';
import 'package:fitnc_user/service/config.service.dart';
import 'package:fitnc_user/service/connectivity.service.dart';
import 'package:fitnc_user/service/exercice.service.dart';
import 'package:fitnc_user/service/fitness-user.service.dart';
import 'package:fitnc_user/service/user-set.service.dart';
import 'package:fitnc_user/service/workout-instance.service.dart';
import 'package:fitnc_user/service/auth.service.dart';
import 'package:fitnc_user/service/display.service.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

///
/// Locator de services, résolu depuis toute l'application.
///
/// Il vivait auparavant dans `package:fitness_domain/di.dart`, que ce fichier
/// se contentait de ré-exporter ; la fusion du package l'a ramené ici.
///
final GetIt di = GetIt.instance;

///
/// Enregistrement des services applicatifs (portée : toute la session).
///
/// Tous sont déclarés en lazy singleton — sauf ConnectivityService — : ils ne
/// sont construits qu'à la première résolution, ce qui laisse get_it démêler
/// l'ordre des dépendances entre eux.
///
/// À ne PAS mettre ici : les notifiers de page. Ils ont une durée de vie liée
/// à leur écran et sont détruits avec lui — voir MIGRATION.md, chantier 3.
///
Future<void> configureDependencies() async {
  // Chargé une seule fois : toutes les lectures de préférences deviennent
  // ensuite synchrones.
  di.registerSingleton<SharedPreferences>(
      await SharedPreferences.getInstance());

  // Sans état, aucune ressource à libérer.
  di.registerLazySingleton<ConfigService>(() => ConfigService());
  di.registerLazySingleton<AuthService>(() => AuthService());
  di.registerLazySingleton<DisplayTypeService>(() => DisplayTypeService());

  // Portent une souscription ou un notifier : dispose explicite.
  //
  // ConnectivityService est le seul enregistrement *non* lazy : il doit
  // observer le réseau dès le lancement, sans attendre qu'un écran le demande.
  // En lazy, personne ne le résolvait et la détection de connexion ne
  // fonctionnait pas du tout.
  di.registerSingleton<ConnectivityService>(
    ConnectivityService(),
    dispose: (ConnectivityService service) => service.dispose(),
  );
  di.registerLazySingleton<DarkModeService>(
    () => DarkModeService(di<SharedPreferences>()),
    dispose: (DarkModeService service) => service.dispose(),
  );

  // Services métier Firestore.
  di.registerLazySingleton<FitnessUserService>(() => FitnessUserService());
  di.registerLazySingleton<ExerciceService>(() => ExerciceService());
  di.registerLazySingleton<WorkoutInstanceService>(
      () => WorkoutInstanceService());
  di.registerLazySingleton<UserSetService>(() => UserSetService());
}
