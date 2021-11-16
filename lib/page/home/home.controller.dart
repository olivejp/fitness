import 'package:fitnc_user/service/fitness-user.service.dart';
import 'package:fitness_domain/domain/fitness-user.domain.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  HomeController();

  final FitnessUserService fitnessUserService = Get.find();

  Future<FitnessUser?> getConnectedUser() {
    return fitnessUserService.getConnectedUser();
  }
}
