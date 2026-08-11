import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:fitnc_user/constants.dart';

class Theming {
  /// Ambre de la marque, celui du logo et des titres.
  static const Color _seed = FitnessNcColors.amber;

  ///
  /// Palette dérivée de l'ambre de la marque.
  ///
  /// Les thèmes déclaraient auparavant `primarySwatch: Colors.amber`. Depuis
  /// que Material 3 est le mode par défaut (Flutter 3.16), `primarySwatch`
  /// n'est plus lu : sans `colorScheme` ni `colorSchemeSeed`, `ThemeData`
  /// retombe sur la palette M3 de base, violette. L'application affichait donc
  /// du violet partout sans que rien ne le signale, ni à la compilation ni à
  /// l'analyse.
  ///
  /// `fromSeed` assombrit volontairement l'ambre en mode clair (`primary`
  /// devient un or foncé) pour garantir le contraste du texte : de l'ambre pur
  /// sur fond blanc plafonne à ~1,7:1, très en deçà du seuil AA. Le
  /// `filledButtonTheme` ci-dessous rétablit l'ambre de la marque là où il est
  /// lisible, c'est-à-dire en aplat avec du texte noir (~11:1).
  ///
  static ColorScheme _colorScheme(Brightness brightness) {
    return ColorScheme.fromSeed(seedColor: _seed, brightness: brightness);
  }

  static FilledButtonThemeData getFilledButtonTheme() {
    return FilledButtonThemeData(
      style: ButtonStyle(
        backgroundColor: const WidgetStatePropertyAll<Color>(_seed),
        foregroundColor: const WidgetStatePropertyAll<Color>(Colors.black),
        textStyle: WidgetStatePropertyAll<TextStyle>(
          GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  static ThemeData getLightTheme() {
    return ThemeData(
      colorScheme: _colorScheme(Brightness.light),
      bottomAppBarTheme: const BottomAppBarThemeData(
        color: FitnessNcColors.white50,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        backgroundColor: FitnessNcColors.darkChipBackground,
        titleTextStyle: TextStyle(
          color: FitnessNcColors.amber,
        ),
      ),
      elevatedButtonTheme: getElevatedButtonTheme(),
      filledButtonTheme: getFilledButtonTheme(),
      textButtonTheme: getTextButtonThemeData(),
      textTheme: getTextTheme(),
    );
  }

  static TextButtonThemeData getTextButtonThemeData() {
    return TextButtonThemeData(
      style: ButtonStyle(
        textStyle: WidgetStatePropertyAll<TextStyle>(
          GoogleFonts.nunito(fontSize: 15),
        ),
      ),
    );
  }

  static ThemeData getDarkTheme() {
    return ThemeData(
      colorScheme: _colorScheme(Brightness.dark),
      filledButtonTheme: getFilledButtonTheme(),
      cardColor: Colors.grey[800],
      dividerColor: const Color(0x1FFFFFFF),
      canvasColor: Colors.grey[850],
      bottomAppBarTheme: BottomAppBarThemeData(
        color: Colors.grey[850],
      ),
      shadowColor: Colors.black54,
      iconTheme: const IconThemeData(color: Colors.white),
      textTheme: Typography.material2014(platform: TargetPlatform.android)
          .white
          .copyWith(
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
        minimumSize:
            const WidgetStatePropertyAll<Size>(Size(double.infinity, 55)),
        textStyle: WidgetStatePropertyAll<TextStyle>(
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
