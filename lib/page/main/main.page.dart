import 'package:fitnc_user/fitness_router.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:localization/localization.dart';
import 'package:provider/provider.dart';

import 'main.controller.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        bottomNavigationBar: Consumer<MainController>(builder: (context, notifier, child) {
          return BottomNavigationBar(
              onTap: (index) {
                context.go(FitnessRouter.getNavigationRouteFromIndex(index));
                notifier.setCurrentIndex(index);
              },
              currentIndex: notifier.currentIndex,
              items: FitnessRouter.targets
                  .map(
                    (e) => BottomNavigationBarItem(
                      icon: Icon(e.icon),
                      label: e.label.i18n(),
                    ),
                  )
                  .toList());
        }),
        body: child,
      ),
    );
  }
}
