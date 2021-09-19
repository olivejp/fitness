import 'package:get/get.dart';

class DaySelectionController extends GetxController {
   final Rx<DateTime> _selectedValue = DateTime.now().obs;

  DateTime get selectedDate => _selectedValue.value;

  set selectedDate(DateTime dateTime) {
    _selectedValue.value = dateTime;
    update();
  }
}
