import 'package:cached_network_image/cached_network_image.dart';
import 'package:fitnc_user/page/calendar/calendar.page.dart';
import 'package:fitnc_user/page/profile/profile.page.dart';
import 'package:fitnc_user/page/search/search.page.dart';
import 'package:fitnc_user/service/workout-instance.service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'home.controller.dart';

class HomePage extends StatelessWidget {
  HomePage({Key? key}) : super(key: key);

  final WorkoutInstanceService workoutInstanceService = Get.find();
  final HomeController controller = Get.put(HomeController());

  final int calendarIndex = 0;
  final int searchIndex = 1;
  final int chartsIndex = 2;
  final int profileIndex = 3;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        bottomNavigationBar: HomeBottomAppBar(
            controller: controller,
            calendarIndex: calendarIndex,
            searchIndex: searchIndex,
            chartsIndex: chartsIndex,
            profileIndex: profileIndex),
        body: Obx(() {
          if (controller.currentPageIndex.value == calendarIndex) {
            return CalendarPage();
          } else if (controller.currentPageIndex.value == searchIndex) {
            return SearchPage();
          } else if (controller.currentPageIndex.value == chartsIndex) {
            // TODO Faire la page des charts.
            throw Exception(
                'Aucune page pour index ${controller.currentPageIndex.value}');
          } else if (controller.currentPageIndex.value == profileIndex) {
            return ProfilePage();
          }
          throw Exception(
              'Aucune page pour index ${controller.currentPageIndex.value}');
        }),
      ),
    );
  }
}

class HomeBottomAppBar extends StatelessWidget {
  const HomeBottomAppBar({
    Key? key,
    required this.controller,
    required this.searchIndex,
    required this.calendarIndex,
    required this.chartsIndex,
    required this.profileIndex,
    this.iconSizedBox = 20,
  }) : super(key: key);

  final HomeController controller;
  final int searchIndex;
  final int calendarIndex;
  final int chartsIndex;
  final int profileIndex;
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
            showSelectedLabels: false,
            showUnselectedLabels: false,
            currentIndex: controller.currentPageIndex.value,
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
                    onPressed: () =>
                        controller.currentPageIndex.value = calendarIndex,
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
                    onPressed: () =>
                        controller.currentPageIndex.value = searchIndex,
                    icon: const Icon(
                      Icons.explore_rounded,
                    ),
                  ),
                ),
              ),
              BottomNavigationBarItem(
                label: 'tracking'.tr,
                activeIcon: const Icon(
                  Icons.bar_chart,
                ),
                icon: SizedBox(
                  height: iconSizedBox,
                  width: iconSizedBox,
                  child: IconButton(
                    padding: const EdgeInsets.all(0),
                    onPressed: () =>
                        controller.currentPageIndex.value = chartsIndex,
                    icon: const Icon(
                      Icons.bar_chart,
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
                        if (controller.user.value?.imageUrl != null) {
                          return CircleAvatar(
                            radius: 30,
                            foregroundImage: CachedNetworkImageProvider(
                                controller.user.value!.imageUrl!),
                          );
                        }
                        return CircleAvatar(
                          radius: 30,
                          backgroundColor: Theme.of(context).primaryColor,
                        );
                      },
                    ),
                    onPressed: () =>
                        controller.currentPageIndex.value = profileIndex,
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
