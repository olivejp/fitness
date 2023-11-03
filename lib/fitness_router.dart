import 'dart:async';

import 'package:fitnc_user/page/calendar/calendar.page.dart';
import 'package:fitnc_user/page/exercice/exercice-detail.page.dart';
import 'package:fitnc_user/page/exercice/exercice.page.dart';
import 'package:fitnc_user/page/home/home.page.dart';
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

class FitnessRouter {
  static String home = '/home';
  static String calendar = '/calendar';
  static String exercises = '/exercises-list';
  static String exercisesDetail = '/exercises/:id';
  static String exercisesNew = '/exercises/new';
  static String profile = '/profile';
  static String programs = '/programs';
  static String settings = '/settings';
  static String seances = '/seances';
  static String signIn = '/sign-in';
  static String signUp = '/sign-up';
  static String pageNotFound = '/page-not-found';
  static String messages = '/messages';
  static String notifications = '/notifications';

  /// Possibles navigation targets list
  static List<NavigationTarget> targets = [
    NavigationTarget(
      label: 'home',
      icon: Icons.home_outlined,
      selectedIcon: Icons.home,
      direction: home,
    ),
    NavigationTarget(
      label: 'calendar',
      icon: Icons.calendar_month_outlined,
      selectedIcon: Icons.calendar_month,
      direction: calendar,
    ),
    NavigationTarget(
      label: 'programs',
      icon: Icons.shop_outlined,
      selectedIcon: Icons.shop,
      direction: programs,
    ),
    NavigationTarget(
      label: 'exercises',
      icon: Icons.accessibility_outlined,
      selectedIcon: Icons.accessibility,
      direction: exercises,
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
  /// Redirection Function
  ///
  static GoRouter getRouter() {
    FutureOr<String?> redirectFunction(BuildContext context, GoRouterState state) {
      DebugPrinter.printLn('Redirect fullPath: ${state.fullPath}');
      final AuthService authService = GetIt.I.get();

      /// A chaque redirection (context.go()) on vérifie que l'utilisateur est bien connecté.
      /// Sinon on redirige vers la page /sign-in.
      if (![signUp, signIn].contains(state.fullPath) && !authService.isConnected()) {
        return signIn;
      }
      return null;
    }

    return GoRouter(
      initialLocation: home,
      redirect: redirectFunction,
      errorBuilder: (context, state) => const PageNotFound(),
      routes: [
        ShellRoute(
            builder: (context, state, child) => MainPage(
                  child: child,
                ),
            routes: [
              GoRoute(
                path: home,
                pageBuilder: (context, state) => buildPageWithDefaultTransition(
                  context: context,
                  state: state,
                  child: const HomePage(),
                ),
              ),
              GoRoute(
                path: calendar,
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
                path: exercises,
                pageBuilder: (context, state) => buildPageWithDefaultTransition(
                  context: context,
                  state: state,
                  child: const ExercisePage(),
                ),
              ),
              GoRoute(
                path: exercisesNew,
                pageBuilder: (context, state) => buildPageWithDefaultTransition(
                  context: context,
                  state: state,
                  child: ExerciseDetailPage(),
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
          path: signIn,
          name: 'sign-in',
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: signUp,
          name: 'sign-up',
          builder: (context, state) => const SignUpPage(),
        ),
        GoRoute(
          path: pageNotFound,
          name: 'page-not-found',
          builder: (context, state) => const PageNotFound(),
        ),
      ],
    );
  }
}
