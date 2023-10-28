import 'package:fitnc_user/constants.dart';

class ConfigService {
  final Map<String, dynamic> mapConfig = {};

  dynamic get(String key) {
    return mapConfig[key];
  }

  ConfigService() {
    mapConfig.putIfAbsent(
      FitnessMobileConstants.profileCommandLineArgument,
      () => const String.fromEnvironment(FitnessMobileConstants.profileCommandLineArgument, defaultValue: ''),
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
}
