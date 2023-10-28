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
        titleTextStyle: TextStyle(
          color: FitnessNcColors.amber,
        ),
      ),
      elevatedButtonTheme: getElevatedButtonTheme(),
      textButtonTheme: getTextButtonThemeData(),
      textTheme: getTextTheme(),
    );
  }

  static TextButtonThemeData getTextButtonThemeData() {
    return TextButtonThemeData(
      style: ButtonStyle(
        textStyle: MaterialStateProperty.all(
          GoogleFonts.nunito(fontSize: 15),
        ),
      ),
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
      textTheme: Typography.material2014(platform: TargetPlatform.android).white.copyWith(
            bodyLarge: GoogleFonts.nunito(),
            bodyMedium: GoogleFonts.nunito(),
            displaySmall: GoogleFonts.anton(
              fontWeight: FontWeight.w900,
              fontSize: 55,
              color: Colors.amber,
            ),
            titleLarge: GoogleFonts.anton(
              fontWeight: FontWeight.w900,
              fontSize: 55,
              color: Colors.amber,
            ),
          ),
    );
  }

  static ElevatedButtonThemeData getElevatedButtonTheme() {
    return ElevatedButtonThemeData(
      style: ButtonStyle(
        minimumSize: MaterialStateProperty.all(const Size(double.infinity, 55)),
        textStyle: MaterialStateProperty.all(
          GoogleFonts.nunito(fontSize: 20),
        ),
      ),
    );
  }

  static TextTheme getTextTheme() {
    return TextTheme(
      bodyLarge: GoogleFonts.nunito(),
      bodyMedium: GoogleFonts.nunito(),

      displayMedium: GoogleFonts.nunito(
        fontWeight: FontWeight.normal,
        fontSize: 25,
      ),

      displaySmall: GoogleFonts.anton(
        fontWeight: FontWeight.normal,
        fontSize: 30,
      ),

      /// headline 6 est réservé pour le titre de l'application, notamment sur la page de login
      titleLarge: GoogleFonts.anton(
        fontWeight: FontWeight.w900,
        fontSize: 55,
        color: Colors.amber,
      ),
    );
  }
}
