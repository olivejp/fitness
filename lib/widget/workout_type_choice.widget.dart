import 'package:fitness_domain/enum/type_workout.enum.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:localization/localization.dart';

typedef TypeWorkoutTapCallback = void Function(TypeWorkout typeWorkout);

class WorkoutTypeChoice extends StatelessWidget {
  const WorkoutTypeChoice({super.key, required this.onTap});
  final TypeWorkoutTapCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 400,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'chooseWorkoutType'.i18n(),
              style: GoogleFonts.anton(
                color: Colors.amber,
                fontSize: 18.0,
              ),
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              child: ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemBuilder: (_, index) {
                  final TypeWorkout typeWorkout = TypeWorkout.values[index];
                  return InkWell(
                    onTap: () => onTap(typeWorkout),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 8.0,
                              bottom: 8.0,
                            ),
                            child: Text(
                              typeWorkout.name,
                              style: GoogleFonts.anton(
                                fontSize: 16.0,
                              ),
                            ),
                          ),
                          Text(typeWorkout.name.i18n()),
                        ],
                      ),
                    ),
                  );
                },
                separatorBuilder: (_, __) => const Divider(height: 2.0),
                itemCount: TypeWorkout.values.length,
              ),
            ),
          )
        ],
      ),
    );
  }
}
