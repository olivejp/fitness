import 'package:fitnc_user/service/fitness-user.service.dart';
import 'package:fitnc_user/service/workout-instance.service.dart';
import 'package:fitness_domain/domain/fitness-user.domain.dart';
import 'package:fitness_domain/domain/workout-instance.domain.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  HomeController() {
    fitnessUserService.listenFitnessUser().listen((FitnessUser? fitnessUser) {
      user.value = fitnessUser;
    });
  }

  final FitnessUserService fitnessUserService = Get.find();
  final WorkoutInstanceService workoutInstanceService = Get.find();
  final RxInt currentPageIndex = 0.obs;
  final Rx<FitnessUser?> user = FitnessUser().obs;

  Future<void> createNewWorkoutInstance(DateTime dateTime) {
    WorkoutInstance instance = WorkoutInstance();
    instance.date = dateTime;
    return workoutInstanceService.create(instance);
  }
}
