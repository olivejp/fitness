
import 'package:fitnc_user/constants.dart';
import 'package:get/get.dart';

class ConfigService extends GetxService {
  final Map<String, dynamic> mapConfig = {};

  dynamic get(String key) {
    return mapConfig[key];
  }

  @override
  void onInit() {
    super.onInit();
    mapConfig.putIfAbsent(
      FitnessMobileConstants.profileCommandLineArgument,
      () => const String.fromEnvironment(
          FitnessMobileConstants.profileCommandLineArgument,
          defaultValue: ''),
    );
  }
}
