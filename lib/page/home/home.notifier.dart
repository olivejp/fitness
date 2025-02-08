import 'package:fitnc_user/domain/utilisateur.domain.dart';
import 'package:fitnc_user/repository/utilisateur.repository.dart';
import 'package:fitnc_user/service/supabase/supabase.auth.service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class HomePageNotifier extends ChangeNotifier {
  Utilisateur? _utilisateur;

  Utilisateur? get utilisateur => _utilisateur;

  set utilisateur(Utilisateur? value) {
    _utilisateur = value;
    notifyListeners();
  }

  void init() {
    final UtilisateurRepository utilisateurRepository = GetIt.I.get();
    final SupabaseAuthService supabaseAuthService = GetIt.I.get();
    utilisateurRepository.get(supabaseAuthService.getConnectedUser()?.id).then((value) {
      utilisateur = value;
    });
  }
}
