import 'dart:async';

import 'package:fitnc_user/service/fitness-user.service.dart';
import 'package:fitnc_user/di.dart';
import 'package:fitnc_user/domain/fitness-user.domain.dart';
import 'package:flutter/foundation.dart';

import 'package:fitnc_user/constants.dart';

class MainNotifier extends ChangeNotifier {
  MainNotifier() {
    _subscriptions.add(
      fitnessUserService.listenFitnessUser().listen(_updateUser),
    );
    _subscriptions.add(
      fitnessUserService.listenFitnessUserChanges().listen(_updateUser),
    );
  }

  final FitnessUserService fitnessUserService = di<FitnessUserService>();
  final ValueNotifier<FitnessUser?> user =
      ValueNotifier<FitnessUser?>(FitnessUser());
  final ValueNotifier<IndexPage> currentIndex =
      ValueNotifier<IndexPage>(IndexPage.calendar);

  final List<StreamSubscription<FitnessUser?>> _subscriptions =
      <StreamSubscription<FitnessUser?>>[];

  @override
  void dispose() {
    for (final StreamSubscription<FitnessUser?> subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
    user.dispose();
    currentIndex.dispose();
    super.dispose();
  }

  void _updateUser(FitnessUser? fitnessUser) {
    user.value = fitnessUser;
  }
}
