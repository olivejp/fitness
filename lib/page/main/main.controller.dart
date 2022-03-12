import 'package:fitnc_user/service/fitness-user.service.dart';
import 'package:fitness_domain/domain/fitness-user.domain.dart';
import 'package:get/get.dart';

import '../../constants.dart';

class MainController extends GetxController {
  MainController() {
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
  final Rx<FitnessUser?> user = FitnessUser().obs;
  final Rx<IndexPage> currentIndex = IndexPage.calendar.obs;
}
