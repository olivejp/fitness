import 'package:flutter/material.dart';
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class DateChangePicker extends StatelessWidget {
  const DateChangePicker({Key? key, required this.initialDate, required this.onDateChanged}) : super(key: key);
  final DateTime? initialDate;
  final void Function(DateTime dateTime) onDateChanged;


  @override
  Widget build(BuildContext context) {
    DateTime dateSelected = initialDate ?? DateTime.now();
    DateTime timeSelected = initialDate ?? DateTime.now();
    return Column(
      children: [
        SfDateRangePicker(
          selectionMode: DateRangePickerSelectionMode.single,
          initialDisplayDate: initialDate,
          initialSelectedDate: initialDate,
          onSelectionChanged: (dateRangePickerSelectionChangedArgs) {
            DateTime dateItemSelected = dateRangePickerSelectionChangedArgs.value;
            dateSelected = DateTime(dateItemSelected.year, dateItemSelected.month, dateItemSelected.day, timeSelected.hour, timeSelected.minute, timeSelected.second);
            onDateChanged(dateSelected);
          },
        ),
        TimePickerSpinner(
          time: initialDate,
          onTimeChange: (dateTime) {
            timeSelected = DateTime(dateSelected.year, dateSelected.month, dateSelected.day, dateTime.hour, dateTime.minute, dateTime.second);
            onDateChanged(timeSelected);
          },
        ),
      ],
    );
  }
}

class FitnessDatePicker extends StatelessWidget {
  const FitnessDatePicker({
    Key? key,
    this.onMonthChange,
    required this.initialDate,
    this.onDateChange,
    this.unselectedDayColor,
    this.selectedDayColor,
    this.selectedDayTextStyle,
    this.unselectedDayTextStyle,
    this.builder,
    this.heigthMonth = 50,
    this.widthMonth = 100,
    this.trailing,
    this.leading,
  }) : super(key: key);

  final Color? unselectedDayColor;
  final Color? selectedDayColor;
  final TextStyle? selectedDayTextStyle;
  final TextStyle? unselectedDayTextStyle;
  final double heigthMonth;
  final double widthMonth;
  final ValueChanged<DateTime>? onDateChange;
  final ValueChanged<int?>? onMonthChange;
  final DateTime initialDate;
  final Widget? leading;
  final Widget? trailing;
  final Widget Function(DateTime dateTime, bool selected)? builder;

  void emitNewDate(int year, int month, int day) {
    if (onDateChange != null) {
      onDateChange!(DateTime(year, month, day));
    }
  }

  @override
  Widget build(BuildContext context) {
    final int initialYear = initialDate.year;
    final int initialMonth = initialDate.month;
    final int initialDay = initialDate.day;

    final ValueNotifier<int> vnMonthSelected = ValueNotifier(initialMonth);
    final ScrollController scrollController = ScrollController();

    int year = initialYear;
    int month = initialMonth;
    int day = initialDay;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            if (leading != null) leading!,
            MonthDropDown(
              year: initialYear,
              month: initialMonth,
              height: heigthMonth,
              width: widthMonth,
              onChanged: (monthValue) {
                if (monthValue == null) return;
                month = monthValue + 1;
                vnMonthSelected.value = month;
                scrollController.animateTo(0, duration: const Duration(seconds: 1), curve: Curves.easeInSine);
                if (onMonthChange != null) {
                  onMonthChange!(month);
                }
                emitNewDate(year, month, day);
              },
            ),
            if (trailing != null) trailing!,
          ],
        ),
        ValueListenableBuilder(
          valueListenable: vnMonthSelected,
          builder: (_, int monthSelected, __) {
            return DayTimeline(
              scrollController: scrollController,
              year: initialYear,
              month: monthSelected,
              initialDay: day,
              selectedDayTextStyle: selectedDayTextStyle,
              selectedColor: selectedDayColor,
              unselectedColor: unselectedDayColor,
              builder: builder,
              onDaySelect: (int daySelected) {
                day = daySelected;
                emitNewDate(year, month, day);
              },
            );
          },
        )
      ],
    );
  }
}

class MonthDropDown extends StatelessWidget {
  MonthDropDown({Key? key, required this.year, required this.month, required this.onChanged, this.height, this.width})
      : super(key: key);

  final int year;
  final int month;
  final double? height;
  final double? width;
  final ValueChanged<int?> onChanged;

  final List<String> monthList = [
    'JAN.',
    'FÉV.',
    'MAR.',
    'AVR.',
    'MAI',
    'JUIN',
    'JUIL.',
    'AOUT',
    'SEP.',
    'OCT.',
    'NOV.',
    'DÉC.'
  ];
  final GlobalKey gkKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    List<DropdownMenuItem<int>> listDropdown = [];
    for (int i = 0; i < monthList.length; i++) {
      listDropdown.add(
        DropdownMenuItem(
          child: Center(
            child: RichText(
              text: TextSpan(
                text: monthList.elementAt(i),
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 18,
                ),
                children: [
                  TextSpan(
                    text: year.toString().substring(2, 4),
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                ],
              ),
            ),
          ),
          value: i,
        ),
      );
    }
    return SizedBox(
      width: width,
      height: height,
      child: DropdownButtonFormField<int>(
        key: gkKey,
        decoration: InputDecoration(
            enabledBorder: InputBorder.none,
            constraints: BoxConstraints(
              minHeight: height ?? 50,
              minWidth: width ?? double.infinity,
            )),
        items: listDropdown,
        value: month - 1,
        elevation: month,
        onChanged: onChanged,
      ),
    );
  }
}

class DayTimeline extends StatelessWidget {
  const DayTimeline({
    Key? key,
    required this.year,
    required this.month,
    this.builder,
    required this.initialDay,
    required this.scrollController,
    required this.onDaySelect,
    this.unselectedColor,
    this.selectedColor,
    this.selectedDayTextStyle,
    this.unselectedDayTextStyle,
  }) : super(key: key);

  final int year;
  final int month;
  final int initialDay;
  final Color? unselectedColor;
  final Color? selectedColor;
  final TextStyle? selectedDayTextStyle;
  final TextStyle? unselectedDayTextStyle;
  final ScrollController scrollController;
  final Widget Function(DateTime dateTime, bool selected)? builder;
  final void Function(int daySelected) onDaySelect;

  @override
  Widget build(BuildContext context) {
    final ValueNotifier<int> vnDaySelected = ValueNotifier(initialDay);

    List<DateTime> listDateTime = [];
    DateTime lastDay = DateTime(year, month + 1, 0);
    for (int i = 1; i < lastDay.day + 1; i++) {
      listDateTime.add(DateTime(year, month, i));
    }

    WidgetsBinding.instance?.addPostFrameCallback((_) {
      double maxScroll = scrollController.position.maxScrollExtent;
      double offsetOfInitialDay = (maxScroll / lastDay.day) * initialDay;
      scrollController.jumpTo(offsetOfInitialDay);
    });

    return SingleChildScrollView(
      controller: scrollController,
      scrollDirection: Axis.horizontal,
      child: ValueListenableBuilder<int>(
        valueListenable: vnDaySelected,
        builder: (_, selectedDay, __) => Row(
          children: listDateTime.map((dateTime) {
            bool isSelected = selectedDay == dateTime.day;
            if (builder != null) {
              return GestureDetector(
                child: builder!(dateTime, isSelected),
                onTap: () {
                  vnDaySelected.value = dateTime.day;
                  onDaySelect(dateTime.day);
                },
              );
            } else {
              return DayCard(
                  dateTime: dateTime,
                  isSelected: isSelected,
                  selectedColor: selectedColor,
                  unselectedColor: unselectedColor,
                  vnDaySelected: vnDaySelected,
                  onDaySelect: onDaySelect,
                  selectedDayTextStyle: selectedDayTextStyle,
                  unselectedDayTextStyle: unselectedDayTextStyle);
            }
          }).toList(),
        ),
      ),
    );
  }
}

class DayCard extends StatelessWidget {
  const DayCard({
    Key? key,
    required this.dateTime,
    required this.isSelected,
    required this.selectedColor,
    required this.unselectedColor,
    required this.vnDaySelected,
    required this.onDaySelect,
    required this.selectedDayTextStyle,
    required this.unselectedDayTextStyle,
  }) : super(key: key);

  final DateTime dateTime;
  final bool isSelected;
  final Color? selectedColor;
  final Color? unselectedColor;
  final ValueNotifier<int> vnDaySelected;
  final void Function(int daySelected) onDaySelect;
  final TextStyle? selectedDayTextStyle;
  final TextStyle? unselectedDayTextStyle;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isSelected ? (selectedColor ?? Colors.amber) : (unselectedColor ?? Colors.white),
      child: InkWell(
        onTap: () {
          vnDaySelected.value = dateTime.day;
          onDaySelect(dateTime.day);
        },
        child: SizedBox(
          height: 50,
          width: 50,
          child: Center(
            child: Text(
              dateTime.day.toString(),
              style: isSelected ? selectedDayTextStyle : unselectedDayTextStyle,
            ),
          ),
        ),
      ),
    );
  }
}
