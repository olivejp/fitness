import 'dart:async';

import 'package:fitnc_user/domain/utilisateur.domain.dart';
import 'package:fitnc_user/repository/utilisateur.repository.dart';
import 'package:fitnc_user/service/debug_printer.dart';
import 'package:fitnc_user/service/supabase/supabase.auth.service.dart';
import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfilePageNotifier extends ChangeNotifier {
  final SupabaseAuthService supabaseAuthService = GetIt.I.get();
  final UtilisateurRepository utilisateurRepository = GetIt.I.get();
  Utilisateur? user;

  ProfilePageNotifier() {
    DebugPrinter.printLn('Creating ProfilePageNotifier');
    supabaseAuthService.listenUserConnected().listen(setUser);
  }

  void setUser(User? userConnected) {
    DebugPrinter.printLn('setUser : $userConnected');
    utilisateurRepository.get(userConnected!.id).then((Utilisateur? utilisateur) {
      DebugPrinter.printLn('FitnessUser : $utilisateur');
      user = utilisateur;
      notifyListeners();
    });
  }

  Future<void> save() async {
    if (user != null) {
      await utilisateurRepository.update(user!);
    } else {
      throw Exception('No Trainer domain to save');
    }
  }

  Future<void> signOut() {
    return supabaseAuthService.signOut();
  }
}
