import 'package:fitnc_user/widget/dark-mode.widget.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

class DarkModeNotifier extends ChangeNotifier {
  final GetStorage box = GetStorage();

  bool _isDark = false;

  DarkModeNotifier() {
    _isDark = box.read(DarkModeWidget.isDarkModeKey);
    notifyListeners();

    box.listenKey(DarkModeWidget.isDarkModeKey, (value) {
      if (value != null && value is bool) {
        _isDark = value;
        notifyListeners();
      }
    });
  }

  bool get isDark => _isDark;

  void switchDarkMode() {
    box.write(DarkModeWidget.isDarkModeKey, !_isDark).then((value) => print('Saved on file !'));
  }
}
