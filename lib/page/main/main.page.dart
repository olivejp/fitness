import 'package:cached_network_image/cached_network_image.dart';
import 'package:fitnc_user/page/calendar/calendar.page.dart';
import 'package:fitnc_user/page/profile/profile.page.dart';
import 'package:fitnc_user/page/search/search.page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../constants.dart';
import 'main.controller.dart';

class MainPage extends StatelessWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ChangeNotifierProvider.value(
          value: MainController(),
          builder: (context, child) {
            return Consumer<MainController>(builder: (context, controller, child) {
              Widget? widget;
              switch (controller.currentIndex) {
                case IndexPage.calendar:
                  widget = const CalendarPage();
                  break;
                case IndexPage.search:
                  widget = const SearchPage();
                  break;
                case IndexPage.profile:
                  widget = ProfilePage();
                  break;
              }
              return Scaffold(
                bottomNavigationBar: HomeBottomAppBar2(
                  controller: controller,
                ),
                body: Stack(
                  children: [
                    widget,
                  ],
                ),
              );
            });
          }),
    );
  }
}

class HomeBottomAppBar2 extends StatelessWidget {
  const HomeBottomAppBar2({
    Key? key,
    required this.controller,
    this.iconSizedBox = 20,
  }) : super(key: key);

  final MainController controller;
  final double iconSizedBox;

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      clipBehavior: Clip.antiAlias,
      child: BottomIconInherited(
        selectedColor: Theme.of(context).primaryColor,
        unselectedColor: Colors.grey,
        height: 60,
        width: 80,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Flexible(
              child: BottomIcon(
                label: 'calendar'.tr,
                iconData: Icons.calendar_today,
                indexPage: IndexPage.calendar,
              ),
            ),
            Flexible(
              child: BottomIcon(
                label: 'search'.tr,
                iconData: Icons.school_outlined,
                indexPage: IndexPage.search,
              ),
            ),
            Flexible(
              child: BottomIcon(
                label: 'profile'.tr,
                iconData: Icons.person,
                indexPage: IndexPage.profile,
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
      {Key? key,
      required this.height,
      required this.width,
      required this.selectedColor,
      required this.unselectedColor,
      required Widget child})
      : super(key: key, child: child);

  final Color selectedColor;
  final Color unselectedColor;
  final double height;
  final double width;

  static BottomIconInherited of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<BottomIconInherited>() as BottomIconInherited;

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    BottomIconInherited old = (oldWidget as BottomIconInherited);
    return old.selectedColor != selectedColor || old.unselectedColor != unselectedColor;
  }
}

class BottomIcon extends StatelessWidget {
  const BottomIcon({Key? key, required this.label, required this.iconData, required this.indexPage}) : super(key: key);

  final String label;
  final IconData iconData;
  final IndexPage indexPage;

  @override
  Widget build(BuildContext context) {
    Color selectedColor = BottomIconInherited.of(context).selectedColor;
    Color unselectedColor = BottomIconInherited.of(context).unselectedColor;
    double height = BottomIconInherited.of(context).height;
    double width = BottomIconInherited.of(context).width;
    return Consumer<MainController>(builder: (context, controller, child) {
      return InkWell(
        radius: 25,
        borderRadius: const BorderRadius.all(Radius.circular(25)),
        onTap: () => controller.setCurrentIndex(indexPage),
        child: SizedBox(
          height: height,
          width: width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(iconData, color: controller.currentIndex == indexPage ? selectedColor : unselectedColor),
              Text(
                label,
                style: TextStyle(color: controller.currentIndex == indexPage ? selectedColor : unselectedColor),
              ),
            ],
          ),
        ),
      );
    });
  }
}

class HomeBottomAppBar extends StatelessWidget {
  const HomeBottomAppBar({
    Key? key,
    required this.controller,
    this.iconSizedBox = 20,
  }) : super(key: key);

  final MainController controller;
  final double iconSizedBox;

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      clipBehavior: Clip.antiAlias,
      child: Obx(
        () => BottomNavigationBarTheme(
          data: BottomNavigationBarThemeData(
            selectedItemColor: Theme.of(context).primaryColor,
            unselectedItemColor: Colors.grey,
          ),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            elevation: 0,
            showSelectedLabels: true,
            showUnselectedLabels: true,
            currentIndex: controller.currentIndex.index,
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                label: 'calendar'.tr,
                activeIcon: const Icon(
                  Icons.calendar_today,
                ),
                icon: SizedBox(
                  height: iconSizedBox,
                  width: iconSizedBox,
                  child: IconButton(
                    padding: const EdgeInsets.all(0),
                    onPressed: () => controller.setCurrentIndex(IndexPage.calendar),
                    icon: const Icon(
                      Icons.calendar_today,
                    ),
                  ),
                ),
              ),
              BottomNavigationBarItem(
                label: 'search'.tr,
                activeIcon: const Icon(
                  Icons.explore_rounded,
                ),
                icon: SizedBox(
                  height: iconSizedBox,
                  width: iconSizedBox,
                  child: IconButton(
                    padding: const EdgeInsets.all(0),
                    onPressed: () => controller.setCurrentIndex(IndexPage.search),
                    icon: const Icon(
                      Icons.explore_rounded,
                    ),
                  ),
                ),
              ),
              BottomNavigationBarItem(
                label: 'profile'.tr,
                icon: SizedBox(
                  height: iconSizedBox,
                  width: iconSizedBox,
                  child: IconButton(
                    padding: const EdgeInsets.all(0),
                    icon: Obx(
                      () {
                        if (controller.user?.imageUrl != null) {
                          return CircleAvatar(
                            radius: 30,
                            foregroundImage: CachedNetworkImageProvider(controller.user!.imageUrl!),
                          );
                        }
                        return CircleAvatar(
                          radius: 30,
                          backgroundColor: Theme.of(context).primaryColor,
                        );
                      },
                    ),
                    onPressed: () => controller.setCurrentIndex(IndexPage.profile),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
