import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnc_user/service/debug_printer.dart';
import 'package:fitnc_user/service/fitness-user.service.dart';
import 'package:fitness_domain/domain/fitness-user.domain.dart';
import 'package:fitness_domain/domain/storage-file.dart';
import 'package:fitness_domain/service/auth.service.dart';
import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';

class ProfilePageNotifier extends ChangeNotifier {
  final AuthService authService = GetIt.I.get();
  final FitnessUserService fitnessUserService = GetIt.I.get();
  FitnessUser? user;

  ProfilePageNotifier() {
    DebugPrinter.printLn('Creating ProfilePageNotifier');
    authService.listenUserConnected().listen(setUser);
  }

  void setUser(User? userConnected) {
    DebugPrinter.printLn('setUser : $userConnected');
    fitnessUserService.read(userConnected!.uid).then((FitnessUser? fitnessUser) {
      DebugPrinter.printLn('FitnessUser : $fitnessUser');
      user = fitnessUser ?? FitnessUser()
        ..uid = userConnected.uid
        ..email = userConnected.email;
      notifyListeners();
    });
  }

  void setStoragePair(StorageFile? stFile) {
    user?.storageFile = stFile ?? StorageFile();
    user?.imageUrl = null;
  }

  Future<void> save() async {
    if (user != null) {
      await fitnessUserService.save(user!);
    } else {
      throw Exception('No Trainer domain to save');
    }
  }

  Future<void> signOut() {
    return authService.signOut();
  }
}
