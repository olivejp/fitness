import 'package:fitnc_user/service/fitness-user.service.dart';
import 'package:fitness_domain/domain/fitness-user.domain.dart';
import 'package:get/get.dart';

class DaySelectionController extends GetxController {
  DateTime _selectedValue = DateTime.now();

  DateTime get selectedDate => _selectedValue;

  set selectedDate(DateTime dateTime) {
    _selectedValue = dateTime;
    update();
  }
}

class HomeController extends GetxController {
  HomeController() {
    fitnessUserService.listenFitnessUser().listen((FitnessUser? fitnessUser) {
      user.value = fitnessUser;
    });
  }

  final FitnessUserService fitnessUserService = Get.find();
  final RxInt currentPageIndex = 0.obs;
  final Rx<FitnessUser?> user = FitnessUser().obs;
}
