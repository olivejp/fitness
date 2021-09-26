import 'package:get/get.dart';

class DaySelectionController extends GetxController {
  final Rx<DateTime> _selectedValue = DateTime
      .now()
      .obs;
  final Rx<DateTime> initialDate = DateTime
      .now()
      .obs;

  DateTime get selectedDate => _selectedValue.value;


  set selectedDate(DateTime dateTime) {
    _selectedValue.value = dateTime;
    update();
  }

  void changeInitialDate(DateTime dateTime) {
    initialDate.update((val) {
      val = dateTime;
    });
  }
}
