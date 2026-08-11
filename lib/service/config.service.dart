import 'package:fitnc_user/constants.dart';

class ConfigService {
  ConfigService() {
    mapConfig.putIfAbsent(
      FitnessConstants.profileCommandLineArgument,
      () => const String.fromEnvironment(
          FitnessConstants.profileCommandLineArgument,
          defaultValue: ''),
    );
    mapConfig.putIfAbsent(
      'EMAIL',
      () => const String.fromEnvironment('EMAIL', defaultValue: ''),
    );
    mapConfig.putIfAbsent(
      'PASSWORD',
      () => const String.fromEnvironment('PASSWORD', defaultValue: ''),
    );
  }

  final Map<String, dynamic> mapConfig = {};

  dynamic get(String key) {
    return mapConfig[key];
  }
}
