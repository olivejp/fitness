import 'package:flutter/foundation.dart';

class MainController extends ChangeNotifier {
  int _currentIndex = 0;

  setCurrentIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  int get currentIndex => _currentIndex;
}
