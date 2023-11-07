import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'constants.dart';

class Theming {
  static ThemeData getLightTheme() {
    return ThemeData(
      useMaterial3: true,
      primarySwatch: Colors.amber,
      primaryColor: Colors.amber,
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Colors.orangeAccent),
          minimumSize: MaterialStateProperty.all(
            const Size.fromHeight(60),
          ),
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5.0),
            ),
          ),
        ),
      ),
      chipTheme: const ChipThemeData(selectedColor: Colors.amber),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        foregroundColor: Colors.white,
        backgroundColor: Colors.amber,
        extendedTextStyle: TextStyle(color: Colors.white),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        shadowColor: Colors.red,
        elevation: 20,
        modalElevation: 20,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        showSelectedLabels: true,
        showUnselectedLabels: true,
        unselectedItemColor: FitnessNcColors.darkCardBackground,
        selectedItemColor: FitnessNcColors.amber,
        selectedLabelStyle: GoogleFonts.nunito(
          color: FitnessNcColors.amber,
          fontSize: 10,
          fontWeight: FontWeight.w900,
        ),
        unselectedLabelStyle: GoogleFonts.nunito(
          color: FitnessNcColors.darkCardBackground,
          fontSize: 10,
          fontWeight: FontWeight.w900,
        ),
      ),
      bottomAppBarTheme: const BottomAppBarTheme(
        color: FitnessNcColors.white50,
      ),
      appBarTheme: const AppBarTheme(
        elevation: 5,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: FitnessNcColors.amber,
        ),
      ),
      elevatedButtonTheme: getElevatedButtonTheme(),
      textButtonTheme: getTextButtonThemeData(),
      textTheme: getTextTheme(),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          foregroundColor: MaterialStateProperty.all(Colors.amber),
          overlayColor: MaterialStateProperty.all(Colors.amber.shade50),
          shape: MaterialStateProperty.all(
            const StadiumBorder(
              side: BorderSide(
                color: Colors.amber,
                width: 3.0,
              ),
            ),
          ),
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return Colors.amber;
          }
          return null;
        }),
      ),
    );
  }

  static TextButtonThemeData getTextButtonThemeData() {
    return TextButtonThemeData(
      style: ButtonStyle(
        foregroundColor: MaterialStateProperty.all(Colors.amber),
        textStyle: MaterialStateProperty.all(
          GoogleFonts.nunito(fontSize: 16),
        ),
      ),
    );
  }

  static ThemeData getDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      primarySwatch: Colors.amber,
      primaryColor: Colors.amber,
      chipTheme: const ChipThemeData(selectedColor: Colors.amber),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        showSelectedLabels: true,
        showUnselectedLabels: true,
        backgroundColor: FitnessNcColors.darkBottomAppBarBackground,
        unselectedItemColor: Colors.white,
        selectedItemColor: FitnessNcColors.amber,
        selectedLabelStyle: GoogleFonts.nunito(
          color: FitnessNcColors.amber,
          fontSize: 10,
          fontWeight: FontWeight.w900,
        ),
        unselectedLabelStyle: GoogleFonts.nunito(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w900,
        ),
      ),
      cardColor: Colors.grey[800],
      dividerColor: const Color(0x1FFFFFFF),
      canvasColor: Colors.grey[850],
      bottomAppBarTheme: BottomAppBarTheme(
        color: Colors.grey[850],
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        color: FitnessNcColors.darkBottomAppBarBackground,
        titleTextStyle: TextStyle(
          color: FitnessNcColors.amber,
        ),
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
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return Colors.amber;
          }
          return null;
        }),
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
