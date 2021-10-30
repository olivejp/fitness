import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'constants.dart';

class Theming {
  static ThemeData getLightTheme() {
    return ThemeData(
        primarySwatch: Colors.amber,
        bottomAppBarTheme: const BottomAppBarTheme(
          color: FitnessNcColors.white50,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          color: FitnessNcColors.darkChipBackground,
          titleTextStyle: TextStyle(color: FitnessNcColors.amber),
        ),
        textTheme: TextTheme(bodyText1: GoogleFonts.comfortaa())
    );
  }

  static ThemeData getDarkTheme() {
    return ThemeData(
      primarySwatch: Colors.amber,
      cardColor: Colors.grey[800],
      dividerColor: const Color(0x1FFFFFFF),
      canvasColor: Colors.grey[850],
      bottomAppBarTheme: BottomAppBarTheme(
        color: Colors.grey[850],
      ),
      shadowColor: Colors.black54,
      iconTheme: const IconThemeData(color: Colors.white),
      textTheme: Typography.material2014(platform: TargetPlatform.android).white,
    );
  }
}