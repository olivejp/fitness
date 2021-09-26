import 'package:fitnc_user/service/user-set.service.dart';
import 'package:fitnc_user/service/workout-instance.service.dart';
import 'package:fitness_domain/domain/user.set.domain.dart';
import 'package:fitness_domain/domain/workout-instance.domain.dart';
import 'package:get/get.dart';

class CalendarController extends GetxController {
  final WorkoutInstanceService workoutInstanceService = Get.find();
  final UserSetService userSetService = Get.find();

  Stream<List<UserSet>> listenUserSet(WorkoutInstance workoutInstance) {
    return userSetService.orderByListen(workoutInstance.uid!, 'createDate', false);
  }

  Future<void> createNewWorkoutInstance(DateTime dateTime) {
    DateTime now = DateTime.now();
    WorkoutInstance instance = WorkoutInstance();
    instance.date = DateTime(dateTime.year, dateTime.month, dateTime.day, now.hour, now.minute, now.second);
    return workoutInstanceService.create(instance);
  }

  Stream<List<WorkoutInstance>> listenWorkoutInstanceByDate(DateTime dateTime) {
    return workoutInstanceService.listenByDate(dateTime);
  }

  Stream<List<WorkoutInstance>> listenWorkoutInstanceWhereDateTime(DateTime dateTime) {
    return workoutInstanceService.listenAll();
  }

  Future<void> deleteWorkout(WorkoutInstance instance) {
    return workoutInstanceService.delete(instance);
  }

  Future<void> deleteUserSet(UserSet set) {
    return userSetService.delete(set);
  }
}
