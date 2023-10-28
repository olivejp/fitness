import 'dart:async';

import 'package:fitnc_user/service/debug_printer.dart';
import 'package:fitnc_user/service/user-set.service.dart';
import 'package:fitnc_user/service/workout-instance.service.dart';
import 'package:fitness_domain/domain/user.set.domain.dart';
import 'package:fitness_domain/domain/workout-instance.domain.dart';
import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';

class CalendarNotifier extends ChangeNotifier {
  final WorkoutInstanceService workoutInstanceService = GetIt.I.get();
  final UserSetService userSetService = GetIt.I.get();

  DateTime _selectedValue = DateTime.now();
  DateTime _initialDate = DateTime.now();

  DateTime get selectedDate => _selectedValue;

  set selectedDate(DateTime dateTime) {
    DebugPrinter.printLn('selectedDate $dateTime');
    _selectedValue = dateTime;
  }

  selectDateAndNotify(DateTime dateTime) {
    DebugPrinter.printLn('Selected date : $dateTime');
    _selectedValue = dateTime;
    notifyListeners();
  }

  DateTime get initialDate => _initialDate;

  set initialDate(DateTime dateTime) {
    _initialDate = dateTime;
  }

  setInitialDateAndNotify(DateTime dateTime) {
    _initialDate = dateTime;
    notifyListeners();
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

  Stream<List<WorkoutInstance>> listenWorkoutInstanceWhereDateTime(DateTime dateTime) {
    return workoutInstanceService.listenAll();
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
