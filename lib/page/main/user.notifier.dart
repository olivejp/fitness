import 'dart:async';

import 'package:fitnc_user/service/debug_printer.dart';
import 'package:fitnc_user/service/fitness-user.service.dart';
import 'package:fitness_domain/domain/fitness-user.domain.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class UserNotifier extends ChangeNotifier {
  final FitnessUserService fitnessUserService = GetIt.I.get();
  FitnessUser? user = FitnessUser();
  StreamSubscription? s;
  StreamSubscription? s2;

  UserNotifier() {
    fitnessUserService.authService.listenUserConnected().listen((userConnected) {
      // On se désinscrits des Streams.
      s?.cancel();
      s2?.cancel();

      if (userConnected != null) {
        s = fitnessUserService.listenFitnessUser().listen((FitnessUser? fitnessUser) {
          DebugPrinter.printLn('Fitness user has been changed 1');
          user = fitnessUser;
          notifyListeners();
        });

        s2 = fitnessUserService.listenFitnessUserChanges().listen((FitnessUser? fitnessUser) {
          DebugPrinter.printLn('Fitness user has been changed 2');
          user = fitnessUser;
          notifyListeners();
        });
      }
    });
  }
}
