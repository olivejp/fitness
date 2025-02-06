import 'dart:async';

import 'package:fitnc_user/service/debug_printer.dart';
import 'package:fitnc_user/service/fitness-user.service.dart';
import 'package:fitnc_user/service/supabase/supabase.auth.service.dart';
import 'package:fitness_domain/domain/fitness-user.domain.dart';
import 'package:fitness_domain/domain/storage-file.dart';
import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfilePageNotifier extends ChangeNotifier {
  // final AuthService authService = GetIt.I.get();
  final SupabaseAuthService supabaseAuthService = GetIt.I.get();
  final FitnessUserService fitnessUserService = GetIt.I.get();
  FitnessUser? user;

  ProfilePageNotifier() {
    DebugPrinter.printLn('Creating ProfilePageNotifier');
    supabaseAuthService.listenUserConnected().listen(setUser);
  }

  void setUser(User? userConnected) {
    DebugPrinter.printLn('setUser : $userConnected');
    fitnessUserService.read(userConnected!.id).then((FitnessUser? fitnessUser) {
      DebugPrinter.printLn('FitnessUser : $fitnessUser');
      user = fitnessUser ?? FitnessUser()
        ..uid = userConnected.id
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
    return supabaseAuthService.signOut();
  }
}
