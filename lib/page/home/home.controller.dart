import 'package:get/get.dart';

class DaySelectionController extends GetxController {
  DateTime _selectedValue = DateTime.now();

  DateTime get selectedDate => _selectedValue;

  set selectedDate(DateTime dateTime) {
    _selectedValue = dateTime;
    update();
  }
}

class HomeController extends GetxController {
  RxInt currentPageIndex = 0.obs;
}