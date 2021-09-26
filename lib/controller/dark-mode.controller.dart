import 'package:fitnc_user/widget/dark-mode.widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class DarkModeController extends GetxController {
  final GetStorage box = GetStorage();

  DarkModeController() {
    notifier.value = box.read(LocalStorageWidget.isDarkModeKey);
    box.listenKey(LocalStorageWidget.isDarkModeKey, (value) {
      if (value != null && value is bool) {
        notifier.value = value;
      }
    });
  }

  void switchDarkMode() {
    box.write(LocalStorageWidget.isDarkModeKey, !notifier.value).then((value) => print('Saved on file !'));
  }

  final ValueNotifier<bool> notifier = ValueNotifier(false);
}
