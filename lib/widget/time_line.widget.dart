import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitnc_user/page/calendar/calendar.page.controller.dart';
import 'package:fitnc_user/page/calendar/calendar.page.dart';
import 'package:fitnc_user/widget/fitness-date-picker.widget.dart';
import 'package:fitness_domain/domain/workout-instance.domain.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:localization/localization.dart';
import 'package:provider/provider.dart';

import '../constants.dart';

class Timeline extends StatelessWidget {
  const Timeline({
    super.key,
    required this.list,
  });

  final List<WorkoutInstance> list;

  @override
  Widget build(BuildContext context) {
    final CalendarNotifier notifierReadOnly = Provider.of<CalendarNotifier>(context, listen: false);
    return Consumer<TodayNotifier>(
      builder: (context, notifier, child) => FitnessDatePicker(
        heigthMonth: 50,
        initialDate: notifierReadOnly.selectedDate,
        onDateChange: notifierReadOnly.selectDateAndNotify,
        selectedDayTextStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        trailing: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: TextButton(
                onPressed: () {
                  notifierReadOnly.initialDate = DateTime.now();
                  notifierReadOnly.selectedDate = DateTime.now();
                  notifierReadOnly.selectDateAndNotify(notifierReadOnly.initialDate);
                  notifier.onTodayClick();
                },
                child: Text(
                  'today'.i18n(),
                  style: GoogleFonts.antonio(),
                ),
              ),
            ),
          ],
        ),
        builder: (dateTime, selected) {
          List<DateTime> listWorkoutForTheDay = list
              .where((workout) => workout.date != null)
              .map((workout) => workout.date)
              .map((date) => DateTime.fromMicrosecondsSinceEpoch((date as Timestamp).microsecondsSinceEpoch))
              .map((date) => DateTime(date.year, date.month, date.day))
              .where((date) => date.compareTo(dateTime) == 0)
              .take(4)
              .toList();
          return CalendarDayCard(
            dateTime: dateTime,
            listWorkoutForTheDay: listWorkoutForTheDay,
            selected: selected,
          );
        },
      ),
    );
  }
}

class CalendarDayCard extends StatelessWidget {
  const CalendarDayCard({
    super.key,
    required this.listWorkoutForTheDay,
    required this.selected,
    required this.dateTime,
  });

  final List<DateTime> listWorkoutForTheDay;
  final bool selected;
  final DateTime dateTime;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: (selected)
            ? Border(
                bottom: BorderSide(
                  color: Theme.of(context).primaryColor,
                  width: 4,
                ),
              )
            : null,
      ),
      child: SizedBox(
        height: 65,
        width: 50,
        child: Column(
          children: [
            Expanded(
              flex: 2,
              child: Center(
                child: Column(
                  children: [
                    Text(
                      DateFormat('EE').format(dateTime),
                      style: GoogleFonts.anton(
                        color: selected ? FitnessNcColors.amber : FitnessNcColors.black800,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      dateTime.day.toString(),
                      style: GoogleFonts.antonio(
                        color: selected ? FitnessNcColors.amber : FitnessNcColors.black800,
                        fontSize: 14,
                        fontWeight: FontWeight.w100,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Flexible(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: listWorkoutForTheDay
                    .map((e) => Icon(
                          Icons.circle,
                          size: 5,
                          color: selected ? Theme.of(context).primaryColor : null,
                        ))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
