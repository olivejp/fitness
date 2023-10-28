import 'dart:async';

import 'package:fitnc_user/page/calendar/calendar.page.dart';
import 'package:fitnc_user/page/exercice/exercice.page.dart';
import 'package:fitnc_user/page/login/login.page.dart';
import 'package:fitnc_user/page/main/main.page.dart';
import 'package:fitnc_user/page/my_programs/my_program.page.dart';
import 'package:fitnc_user/page/profile/profile.page.dart';
import 'package:fitnc_user/page/sign_up/sign-up.page.dart';
import 'package:fitness_domain/service/auth.service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../service/debug_printer.dart';
import 'page/page_not_found/page_not_found.dart';

/// Classe utilitaire pour la NavigationBar
/// Chaque destination de la NavigationBar est une NavigationTarget.
class NavigationTarget {
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final String direction;

  NavigationTarget({required this.label, required this.icon, required this.selectedIcon, required this.direction});
}

class FitncRouter {
  static String accueil = '/accueil';
  static String exercices = '/exercices-list';
  static String exercices_detail = '/exercices/:id';
  static String exercices_new = '/exercices/new';
  static String profile = '/profile';
  static String programs = '/programs';
  static String settings = '/settings';
  static String seances = '/seances';
  static String sign_in = '/sign-in';
  static String sign_up = '/sign-up';
  static String page_not_found = '/page-not-found';
  static String messages = '/messages';
  static String notifications = '/notifications';

  /// Possibles navigation targets list
  static List<NavigationTarget> targets = [
    NavigationTarget(
      label: 'calendar',
      icon: Icons.calendar_month_outlined,
      selectedIcon: Icons.calendar_month,
      direction: accueil,
    ),
    NavigationTarget(
      label: 'programs',
      icon: Icons.shop_outlined,
      selectedIcon: Icons.shop,
      direction: programs,
    ),
    NavigationTarget(
      label: 'exercises',
      icon: Icons.add_chart_outlined,
      selectedIcon: Icons.add_chart,
      direction: exercices,
    ),
    NavigationTarget(
      label: 'profile',
      icon: Icons.person_outlined,
      selectedIcon: Icons.person,
      direction: profile,
    ),
  ];

  static String getNavigationRouteFromIndex(int index) {
    return targets.elementAt(index).direction;
  }

  /// Méthode de transition entre les navigations
  static CustomTransitionPage buildPageWithDefaultTransition<T>({
    required BuildContext context,
    required GoRouterState state,
    required Widget child,
  }) {
    return CustomTransitionPage<T>(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 1),
      transitionsBuilder: (context, animation, secondaryAnimation, child) =>
          FadeTransition(opacity: animation, child: child),
    );
  }

  ///
  /// Fonction de redirection
  ///
  static GoRouter getRouter() {
    FutureOr<String?> redirectFunction(BuildContext context, GoRouterState state) {
      DebugPrinter.printLn('Redirect fullPath: ${state.fullPath}');
      final AuthService authService = GetIt.I.get();

      /// A chaque redirection (context.go()) on vérifie que l'utilisateur est bien connecté.
      /// Sinon on redirige vers la page /sign-in.
      if (!authService.isConnected()) {
        return sign_in;
      }
      return null;
    }

    return GoRouter(
      initialLocation: accueil,
      redirect: redirectFunction,
      errorBuilder: (context, state) => const PageNotFound(),
      routes: [
        ShellRoute(
            builder: (context, state, child) => MainPage(
                  child: child,
                ),
            routes: [
              GoRoute(
                path: accueil,
                pageBuilder: (context, state) => buildPageWithDefaultTransition(
                  context: context,
                  state: state,
                  child: const CalendarPage(),
                ),
              ),
              GoRoute(
                path: programs,
                pageBuilder: (context, state) => buildPageWithDefaultTransition(
                  context: context,
                  state: state,
                  child: MyProgramsPage(),
                ),
              ),
              GoRoute(
                path: exercices,
                pageBuilder: (context, state) => buildPageWithDefaultTransition(
                  context: context,
                  state: state,
                  child: const ExercisePage(),
                ),
              ),
              GoRoute(
                path: profile,
                pageBuilder: (context, state) => buildPageWithDefaultTransition(
                  context: context,
                  state: state,
                  child: ProfilePage(),
                ),
              ),
            ]),
        GoRoute(
          path: sign_in,
          name: 'sign-in',
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: sign_up,
          name: 'sign-up',
          builder: (context, state) => const SignUpPage(),
        ),
        GoRoute(
          path: page_not_found,
          name: 'page-not-found',
          builder: (context, state) => const PageNotFound(),
        ),
      ],
    );
  }
}
