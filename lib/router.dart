import 'dart:developer' as developer;

import 'package:fitnc_user/page/login/login.page.dart';
import 'package:fitnc_user/page/sign-up/sign-up.page.dart';
import 'package:fitnc_user/page/main/main.page.dart';
import 'package:fitnc_user/constants.dart';
import 'package:fitnc_user/di.dart';
import 'package:fitnc_user/service/auth.service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Routes ne nécessitant pas d'utilisateur connecté.
const Set<String> _publicRoutes = <String>{
  FitnessConstants.routeLogin,
  FitnessConstants.routeSignUp,
};

///
/// Routage de l'application.
///
/// Exposé au niveau module pour que les notifiers, qui n'ont pas de
/// BuildContext, puissent naviguer (`appRouter.go(...)`). Depuis un widget,
/// préférer `context.go(...)`.
///
final GoRouter appRouter = GoRouter(
  initialLocation: FitnessConstants.routeHome,
  redirect: _guardConnected,
  routes: <RouteBase>[
    GoRoute(
      path: FitnessConstants.routeHome,
      builder: (_, __) => MainPage(),
    ),
    GoRoute(
      path: FitnessConstants.routeLogin,
      pageBuilder: (_, GoRouterState state) => _slideFromRight(
        state,
        LoginPage(),
      ),
    ),
    GoRoute(
      path: FitnessConstants.routeSignUp,
      pageBuilder: (_, GoRouterState state) => _slideFromRight(
        state,
        SignUpPage(
          callback: (_) => appRouter.go(FitnessConstants.routeHome),
        ),
      ),
    ),
  ],
);

///
/// Remplace IsConnectedMiddleware : tout accès à une route privée sans
/// utilisateur connecté renvoie vers l'écran de connexion.
///
String? _guardConnected(BuildContext context, GoRouterState state) {
  if (_publicRoutes.contains(state.matchedLocation)) {
    return null;
  }

  if (!di<AuthService>().isConnected()) {
    developer.log('User not connected redirect to ${FitnessConstants.routeLogin}');
    return FitnessConstants.routeLogin;
  }

  developer.log('User connected continue to ${state.matchedLocation}');
  return null;
}

/// Équivalent de Transition.rightToLeft de GetX.
CustomTransitionPage<void> _slideFromRight(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (_, Animation<double> animation, __, Widget child) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
        child: child,
      );
    },
  );
}
