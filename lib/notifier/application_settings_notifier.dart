import 'package:fitness_domain/constants.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

class ApplicationSettingsNotifier extends ChangeNotifier {
  static const String isDarkModeKey = 'isDarkMode';

  final GetStorage box = GetStorage();

  bool dark = false;
  final Locale localeFr = const Locale('fr', 'FR');
  final Locale localeEn = const Locale('en', 'EN');
  late Locale locale;

  ApplicationSettingsNotifier() {
    locale = localeFr;

    if (box.hasData(isDarkModeKey)) {
      dark = box.read(isDarkModeKey);
    } else {
      dark = false;
    }
    notifyListeners();

    box.listenKey(isDarkModeKey, (value) {
      if (value != null && value is bool) {
        dark = value;
        notifyListeners();
      }
    });
  }

  Color getPrimaryColor() {
    return dark ? FitnessNcColors.primaryDark : FitnessNcColors.primary;
  }

  Color getSecondaryColor() {
    return dark ? FitnessNcColors.secondaryDark : FitnessNcColors.secondary;
  }

  Color getAccentColor() {
    return dark ? FitnessNcColors.accentDark : FitnessNcColors.accent;
  }

  List<Locale> getSupportedLocales() {
    return List.of({localeEn, localeFr});
  }

  bool isFrench() {
    return locale == localeFr;
  }

  void switchToEnglish() {
    locale = localeEn;
    notifyListeners();
  }

  void switchToFrench() {
    locale = localeFr;
    notifyListeners();
  }

  void switchLocale(Locale locale) {
    this.locale = locale;
    notifyListeners();
  }

  void switchDark() {
    dark = !dark;
    notifyListeners();
  }

  bool isDark() {
    return dark;
  }
}
