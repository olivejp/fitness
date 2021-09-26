import 'package:fitnc_user/page/calendar/calendar.page.dart';
import 'package:fitnc_user/page/my_programs/my_program.page.dart';
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

  final int searchIndex = 0;
  final int calendarIndex = 1;
  final int myProgramsIndex = 2;
  final int chartsIndex = 3;
  final int profilIndex = 4;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Obx(
        () => Scaffold(
          bottomNavigationBar: SizedBox(
            height: 70,
            child: Container(
              decoration: BoxDecoration(boxShadow: [
                BoxShadow(
                  color: Theme.of(context).shadowColor,
                  blurRadius: 5,
                )
              ]),
              child: BottomAppBar(
                clipBehavior: Clip.antiAlias,
                child: Row(
                  children: [
                    Expanded(
                      flex: 5,
                      child: BottomNavigationBar(
                        type: BottomNavigationBarType.fixed,
                        elevation: 0,
                        showSelectedLabels: false,
                        showUnselectedLabels: false,
                        currentIndex: controller.currentPageIndex.value,
                        items: <BottomNavigationBarItem>[
                          BottomNavigationBarItem(
                            label: 'Rechercher',
                            activeIcon: Icon(
                              Icons.search,
                              color: Theme.of(context).primaryColor,
                            ),
                            icon: IconButton(
                                onPressed: () => controller.currentPageIndex.value = searchIndex,
                                icon: const Icon(
                                  Icons.search,
                                  color: Colors.grey,
                                )),
                          ),
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
                            label: 'Programmes',
                            activeIcon: Icon(
                              Icons.account_tree_outlined,
                              color: Theme.of(context).primaryColor,
                            ),
                            icon: IconButton(
                                onPressed: () => controller.currentPageIndex.value = myProgramsIndex,
                                icon: Icon(
                                  Icons.account_tree_outlined,
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
                                      foregroundImage: NetworkImage(controller.user.value!.imageUrl!),
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
                  ],
                ),
              ),
            ),
          ),
          body: Builder(builder: (context) {
            if (controller.currentPageIndex.value == searchIndex) {
              return SearchPage();
            } else if (controller.currentPageIndex.value == calendarIndex) {
              return CalendarPage();
            } else if (controller.currentPageIndex.value == myProgramsIndex) {
              return MyProgramsPage();
            } else if (controller.currentPageIndex.value == chartsIndex) {
              // TODO Faire la page des charts.
              throw Exception('Aucune page pour index ${controller.currentPageIndex.value}');
            } else if (controller.currentPageIndex.value == profilIndex) {
              return ProfilPage();
            }
            throw Exception('Aucune page pour index ${controller.currentPageIndex.value}');
          }),
        ),
      ),
    );
  }
}
