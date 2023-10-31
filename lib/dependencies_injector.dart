import 'package:fitnc_user/service/config.service.dart';
import 'package:fitnc_user/service/connectivity.service.dart';
import 'package:fitnc_user/service/exercice.service.dart';
import 'package:fitnc_user/service/fitness-user.service.dart';
import 'package:fitnc_user/service/group_exercice.service.dart';
import 'package:fitnc_user/service/published_programme.service.dart';
import 'package:fitnc_user/service/trainers.service.dart';
import 'package:fitnc_user/service/user-set.service.dart';
import 'package:fitnc_user/service/workout-instance.service.dart';
import 'package:fitness_domain/service/auth.service.dart';
import 'package:fitness_domain/service/firebase-storage.service.dart';
import 'package:fitness_domain/service/param.service.dart';
import 'package:get_it/get_it.dart';

class GetItDependenciesInjector {
  static initialize() {
    GetIt.I.registerSingleton(ConfigService());
    GetIt.I.registerSingleton(ParamService.getInstance());
    GetIt.I.registerSingleton(ConnectivityService());
    GetIt.I.registerLazySingleton(() => AuthService());
    GetIt.I.registerLazySingleton(() => FitnessUserService());
    GetIt.I.registerLazySingleton(() => PublishedProgrammeService());
    GetIt.I.registerLazySingleton(() => TrainersService());
    GetIt.I.registerLazySingleton(() => FirebaseStorageService());
    GetIt.I.registerLazySingleton(() => ExerciceService());
    GetIt.I.registerLazySingleton(() => GroupExerciceService());
    GetIt.I.registerLazySingleton(() => WorkoutInstanceService());
    GetIt.I.registerLazySingleton(() => UserSetService());
  }
}
