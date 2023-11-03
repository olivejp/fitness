import 'package:flutter/material.dart';

/// Notifier pour changer l'état des boutons 'Hide password'.
class HidePasswordNotifier extends ChangeNotifier {
  bool hidePassword1 = true;
  bool hidePassword2 = true;

  void switchPassword1() {
    hidePassword1 = !hidePassword1;
    notifyListeners();
  }

  void switchPassword2() {
    hidePassword2 = !hidePassword2;
    notifyListeners();
  }
}
