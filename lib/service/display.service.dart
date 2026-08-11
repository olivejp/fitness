import 'package:flutter/foundation.dart';

/// Enumération des différents types d'affichage possibles
enum DisplayType { mobile, tablet, desktop }

/// Notifier qui permet de savoir quel est l'affichage courant
class DisplayTypeService {
  final ValueNotifier<DisplayType> displayType =
      ValueNotifier<DisplayType>(DisplayType.mobile);

  void changeDisplay(DisplayType newDisplayType) {
    displayType.value = newDisplayType;
  }
}