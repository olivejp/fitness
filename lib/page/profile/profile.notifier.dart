import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnc_user/service/fitness-user.service.dart';
import 'package:fitness_domain/domain/fitness-user.domain.dart';
import 'package:fitness_domain/domain/storage-file.dart';
import 'package:fitness_domain/service/auth.service.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';

class ProfilePageController extends GetxController {
  final AuthService authService = GetIt.I.get();
  final FitnessUserService fitnessUserService = GetIt.I.get();
  final Rx<FitnessUser?> user = FitnessUser().obs;
  StreamSubscription? subUserConnected;

  @override
  void onInit() {
    super.onInit();

    User currentUser = AuthService.getUserConnectedOrThrow();

    subUserConnected?.cancel();
    subUserConnected = authService.listenUserConnected().listen((User? userConnected) {
      fitnessUserService.read(userConnected!.uid).then((FitnessUser? fitnessUser) {
        user.value = fitnessUser ?? FitnessUser()
          ..uid = currentUser.uid
          ..email = currentUser.email;
      });
    });
  }

  @override
  void onClose() {
    subUserConnected?.cancel();
  }

  void setStoragePair(StorageFile? stFile) {
    user.update((FitnessUser? user) {
      if (user != null) {
        user.storageFile = stFile ?? StorageFile();
        user.imageUrl = null;
      }
    });
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
