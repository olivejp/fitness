import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnc_user/di.dart';
import 'package:fitnc_user/domain/fitness-user.domain.dart';
import 'package:fitnc_user/domain/storage-file.domain.dart';
import 'package:fitnc_user/service/auth.service.dart';
import 'package:fitnc_user/service/fitness-user.service.dart';
import 'package:flutter/foundation.dart';

class ProfileNotifier extends ChangeNotifier {
  ProfileNotifier() {
    final User currentUser = AuthService.getUserConnectedOrThrow();

    subUserConnected =
        authService.listenUserConnected().listen((User? userConnected) {
      fitnessUserService
          .read(userConnected!.uid)
          .then((FitnessUser? fitnessUser) {
        user.value = fitnessUser ?? FitnessUser()
          ..uid = currentUser.uid
          ..email = currentUser.email;
      });
    });
  }

  final AuthService authService = di<AuthService>();
  final FitnessUserService fitnessUserService = di<FitnessUserService>();
  final ValueNotifier<FitnessUser?> user =
      ValueNotifier<FitnessUser?>(FitnessUser());
  StreamSubscription? subUserConnected;

  @override
  void dispose() {
    subUserConnected?.cancel();
    user.dispose();
    super.dispose();
  }

  void setStoragePair(StorageFile? stFile) {
    final FitnessUser? current = user.value;
    if (current != null) {
      current.storageFile = stFile ?? StorageFile();
      current.imageUrl = null;
      // ValueNotifier ne notifie que sur changement de référence : l'objet
      // étant muté sur place, il faut forcer la notification.
      user.notifyListeners();
    }
  }

  Future<void> save() async {
    if (user.value != null) {
      await fitnessUserService.save(user.value!);
    } else {
      throw Exception('No Trainer domain to save');
    }
  }

  Future<void> signOut() {
    return authService.signOut();
  }
}
