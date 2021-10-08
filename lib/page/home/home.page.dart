import 'package:cached_network_image/cached_network_image.dart';
import 'package:fitnc_user/page/calendar/calendar.page.dart';
import 'package:fitnc_user/page/profil/profil.page.dart';
import 'package:fitnc_user/page/search/search.page.dart';
import 'package:fitnc_user/service/workout-instance.service.dart';
import 'package:flutter/cupertino.dart';
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
  final int profilIndex = 3;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        bottomNavigationBar: HomeBottomAppBar(
            controller: controller,
            calendarIndex: calendarIndex,
            searchIndex: searchIndex,
            chartsIndex: chartsIndex,
            profilIndex: profilIndex),
        body: Obx(() {
          if (controller.currentPageIndex.value == calendarIndex) {
            return CalendarPage();
          } else if (controller.currentPageIndex.value == searchIndex) {
            return SearchPage();
          } else if (controller.currentPageIndex.value == chartsIndex) {
            // TODO Faire la page des charts.
            throw Exception('Aucune page pour index ${controller.currentPageIndex.value}');
          } else if (controller.currentPageIndex.value == profilIndex) {
            return ProfilPage();
          }
          throw Exception('Aucune page pour index ${controller.currentPageIndex.value}');
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
    required this.profilIndex,
  }) : super(key: key);

  final HomeController controller;
  final int searchIndex;
  final int calendarIndex;
  final int chartsIndex;
  final int profilIndex;

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      clipBehavior: Clip.antiAlias,
      child: Obx(
        () => BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          currentIndex: controller.currentPageIndex.value,
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              label: 'Calendrier',
              activeIcon: Icon(
                Icons.calendar_today,
                color: Theme.of(context).primaryColor,
              ),
              icon: IconButton(
                  onPressed: () => controller.currentPageIndex.value = calendarIndex,
                  icon: Icon(
                    Icons.calendar_today,
                    color: Colors.grey,
                  )),
            ),
            BottomNavigationBarItem(
              label: 'Rechercher',
              activeIcon: Icon(
                Icons.explore_rounded,
                color: Theme.of(context).primaryColor,
              ),
              icon: IconButton(
                  onPressed: () => controller.currentPageIndex.value = searchIndex,
                  icon: const Icon(
                    Icons.explore_rounded,
                    color: Colors.grey,
                  )),
            ),
            BottomNavigationBarItem(
              label: 'Suivi',
              activeIcon: Icon(
                Icons.bar_chart,
                color: Theme.of(context).primaryColor,
              ),
              icon: IconButton(
                  onPressed: () => controller.currentPageIndex.value = chartsIndex,
                  icon: Icon(
                    Icons.bar_chart,
                    color: Colors.grey,
                  )),
            ),
            BottomNavigationBarItem(
              label: 'Profil',
              icon: IconButton(
                icon: Obx(
                  () {
                    if (controller.user.value?.imageUrl != null) {
                      return CircleAvatar(
                        radius: 30,
                        foregroundImage: CachedNetworkImageProvider(controller.user.value!.imageUrl!),
                      );
                    }
                    return CircleAvatar(
                      radius: 30,
                      backgroundColor: Theme.of(context).primaryColor,
                    );
                  },
                ),
                onPressed: () => controller.currentPageIndex.value = profilIndex,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
