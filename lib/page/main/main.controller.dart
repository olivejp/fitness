import 'package:fitnc_user/service/fitness-user.service.dart';
import 'package:fitness_domain/domain/fitness-user.domain.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';

import '../../constants.dart';

class MainController extends ChangeNotifier {
  final FitnessUserService fitnessUserService = GetIt.I.get();
  FitnessUser? user = FitnessUser();
  IndexPage _currentIndex = IndexPage.calendar;

  setCurrentIndex(IndexPage indexPage) {
    _currentIndex = indexPage;
    notifyListeners();
  }

  IndexPage get currentIndex => _currentIndex;

  MainController() {
    fitnessUserService.listenFitnessUser().listen((FitnessUser? fitnessUser) {
      user = fitnessUser;
      notifyListeners();
    });

    fitnessUserService.listenFitnessUserChanges().listen((FitnessUser? fitnessUser) {
      user = fitnessUser;
      notifyListeners();
    });
  }
}
