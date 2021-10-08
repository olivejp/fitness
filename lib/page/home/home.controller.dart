import 'package:fitnc_user/service/fitness-user.service.dart';
import 'package:fitness_domain/domain/fitness-user.domain.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  HomeController() {
    fitnessUserService.listenFitnessUser().listen((FitnessUser? fitnessUser) {
      user.value = fitnessUser;
      user.refresh();
    });

    fitnessUserService.listenFitnessUserChanges().listen((FitnessUser? fitnessUser) {
      user.value = fitnessUser;
      user.refresh();
    });
  }

  final FitnessUserService fitnessUserService = Get.find();
  final RxInt currentPageIndex = 0.obs;
  final Rx<FitnessUser?> user = FitnessUser().obs;
}
