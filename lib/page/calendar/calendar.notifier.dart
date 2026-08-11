import 'package:fitnc_user/service/user-set.service.dart';
import 'package:fitnc_user/service/workout-instance.service.dart';
import 'package:fitnc_user/di.dart';
import 'package:fitnc_user/domain/user-set.domain.dart';
import 'package:fitnc_user/domain/workout-instance.domain.dart';
import 'package:flutter/foundation.dart';

class CalendarNotifier extends ChangeNotifier {
  final WorkoutInstanceService workoutInstanceService = di<WorkoutInstanceService>();
  final UserSetService userSetService = di<UserSetService>();

  final ValueNotifier<DateTime> selectedDate =
      ValueNotifier<DateTime>(DateTime.now());
  final ValueNotifier<DateTime> initialDate =
      ValueNotifier<DateTime>(DateTime.now());

  @override
  void dispose() {
    selectedDate.dispose();
    initialDate.dispose();
    super.dispose();
  }

  Stream<List<UserSet>> listenUserSet(WorkoutInstance workoutInstance) {
    return userSetService.orderByListen(workoutInstance.uid!, 'createDate', false);
  }

  Future<WorkoutInstance> createNewWorkoutInstance(DateTime dateTime) async {
    DateTime now = DateTime.now();
    WorkoutInstance instance = WorkoutInstance();
    instance.date = DateTime(dateTime.year, dateTime.month, dateTime.day, now.hour, now.minute, now.second);
    workoutInstanceService.create(instance);
    return instance;
  }

  Stream<List<WorkoutInstance>> listenWorkoutInstanceByDate(DateTime dateTime) {
    return workoutInstanceService.listenByDate(dateTime);
  }

  Future<void> deleteWorkout(WorkoutInstance instance) {
    return workoutInstanceService.delete(instance);
  }

  Future<void> deleteUserSet(UserSet set) {
    return userSetService.delete(set);
  }

  Future<void> updateDate(WorkoutInstance instance, DateTime dateSelected) {
    instance.date = dateSelected;
    return workoutInstanceService.update(instance);
  }


  Stream<bool> areAllChecked(String uidWorkout) {
   return userSetService.areAllChecked(uidWorkout);
  }
}
