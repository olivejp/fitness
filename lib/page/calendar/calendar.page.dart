import 'package:date_picker_timeline/date_picker_widget.dart';
import 'package:fitnc_user/page/home/home.controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CalendarPage extends StatelessWidget {
  CalendarPage({Key? key}) : super(key: key);
  final DatePickerController datePickerController = DatePickerController();
  final DaySelectionController daySelectionController = Get.put(DaySelectionController());
  final HomeController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    // Future.delayed(Duration(seconds: 1)).then((value) => datePickerController.jumpToSelection());
    return Center(
      child: Column(
        children: <Widget>[
          DatePicker(
            DateTime.now().subtract(const Duration(days: 183)),
            daysCount: 365,
            controller: datePickerController,
            dateTextStyle: TextStyle(
              color: Color(Colors.amber.value),
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            initialSelectedDate: DateTime.now(),
            selectionColor: Theme.of(context).primaryColor,
            onDateChange: (DateTime date) => daySelectionController.selectedDate = date,
            locale: "fr_FR",
          ),
        ],
      ),
    );
  }
}
