import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

///
/// Préférence de thème, persistée localement.
///
/// SharedPreferences est chargé une fois au démarrage (voir
/// `configureDependencies()`), ce qui rend les lectures synchrones : plus besoin
/// d'attendre l'initialisation du stockage avant de construire l'application.
///
class DarkModeService {
  DarkModeService(this._preferences) {
    notifier.value = _preferences.getBool(_isDarkModeKey) ?? false;
  }

  static const String _isDarkModeKey = 'isDarkMode';

  final SharedPreferences _preferences;
  final ValueNotifier<bool> notifier = ValueNotifier<bool>(false);

  /// Appelée par get_it quand le service est désenregistré.
  void dispose() {
    notifier.dispose();
  }

  Future<void> switchDarkMode() {
    final bool enabled = !notifier.value;
    notifier.value = enabled;
    return _preferences.setBool(_isDarkModeKey, enabled);
  }
}
