import 'package:fitnc_user/l10n/l10n.dart';
import 'package:fitnc_user/page/calendar/calendar.page.dart';
import 'package:fitnc_user/page/profile/profile.page.dart';
import 'package:flutter/material.dart';

import 'package:fitnc_user/constants.dart';
import 'package:fitnc_user/page/main/main.notifier.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final MainNotifier notifier = MainNotifier();

  @override
  void dispose() {
    notifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        bottomNavigationBar: HomeBottomAppBar2(
          notifier: notifier,
        ),
        body: ValueListenableBuilder<IndexPage>(
          valueListenable: notifier.currentIndex,
          builder: (_, IndexPage index, __) {
            switch (index) {
              case IndexPage.calendar:
                return const CalendarPage();
              case IndexPage.profile:
                return const ProfilePage();
            }
          },
        ),
      ),
    );
  }
}

class HomeBottomAppBar2 extends StatelessWidget {
  const HomeBottomAppBar2({
    Key? key,
    required this.notifier,
    this.iconSizedBox = 20,
  }) : super(key: key);

  final MainNotifier notifier;
  final double iconSizedBox;

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      clipBehavior: Clip.antiAlias,
      child: BottomIconInherited(
        selectedColor: Theme.of(context).colorScheme.primary,
        unselectedColor: Colors.grey,
        height: 60,
        width: 80,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Flexible(
              child: BottomIcon(
                label: context.l10n.calendar,
                iconData: Icons.calendar_today,
                indexPage: IndexPage.calendar,
                notifier: notifier,
              ),
            ),
            Flexible(
              child: BottomIcon(
                label: context.l10n.profile,
                iconData: Icons.person,
                indexPage: IndexPage.profile,
                notifier: notifier,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BottomIconInherited extends InheritedWidget {
  const BottomIconInherited(
      {required this.height,
      required this.width,
      required this.selectedColor,
      required this.unselectedColor,
      required Widget child})
      : super(child: child);

  final Color selectedColor;
  final Color unselectedColor;
  final double height;
  final double width;

  static BottomIconInherited of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<BottomIconInherited>()
          as BottomIconInherited;

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    BottomIconInherited old = (oldWidget as BottomIconInherited);
    return old.selectedColor != selectedColor ||
        old.unselectedColor != unselectedColor;
  }
}

class BottomIcon extends StatelessWidget {
  const BottomIcon(
      {Key? key,
      required this.label,
      required this.iconData,
      required this.indexPage,
      required this.notifier})
      : super(key: key);

  final String label;
  final IconData iconData;
  final IndexPage indexPage;
  final MainNotifier notifier;

  @override
  Widget build(BuildContext context) {
    Color selectedColor = BottomIconInherited.of(context).selectedColor;
    Color unselectedColor = BottomIconInherited.of(context).unselectedColor;
    double height = BottomIconInherited.of(context).height;
    double width = BottomIconInherited.of(context).width;
    return InkWell(
      radius: 25,
      borderRadius: const BorderRadius.all(Radius.circular(25)),
      onTap: () => notifier.currentIndex.value = indexPage,
      child: SizedBox(
        height: height,
        width: width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            ValueListenableBuilder<IndexPage>(
              valueListenable: notifier.currentIndex,
              builder: (_, IndexPage current, __) {
                final Color color =
                    current == indexPage ? selectedColor : unselectedColor;
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(iconData, color: color),
                    Text(label, style: TextStyle(color: color)),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
