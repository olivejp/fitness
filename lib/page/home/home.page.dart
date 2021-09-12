import 'package:cached_network_image/cached_network_image.dart';
import 'package:fab_circular_menu/fab_circular_menu.dart';
import 'package:fitnc_user/page/calendar/calendar.page.dart';
import 'package:fitnc_user/page/profil/profil.page.dart';
import 'package:fitnc_user/page/search/search.page.dart';
import 'package:fitness_domain/service/auth.service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'home.controller.dart';

class HomePage extends StatelessWidget {
  final AuthService authService = Get.find();
  final HomeController controller = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Obx(
        () => Scaffold(
          floatingActionButton: FabCircularMenu(
            fabOpenIcon: const Icon(
              Icons.menu,
              color: Colors.white,
            ),
            fabCloseIcon: const Icon(
              Icons.close,
              color: Colors.white,
            ),
            animationDuration: const Duration(milliseconds: 150),
            ringColor: Colors.amberAccent,
            children: <Widget>[
              IconButton(
                hoverColor: Color(Colors.transparent.value),
                splashRadius: 30,
                iconSize: 50,
                icon: Icon(
                  Icons.calendar_today,
                  color: (controller.currentPageIndex.value != 0) ? Colors.grey : Colors.white,
                ),
                onPressed: () => controller.currentPageIndex.value = 0,
              ),
              IconButton(
                hoverColor: Color(Colors.transparent.value),
                splashRadius: 30,
                iconSize: 50,
                icon: Icon(
                  Icons.bar_chart,
                  color: (controller.currentPageIndex.value != 1) ? Colors.grey : Colors.white,
                ),
                onPressed: () => controller.currentPageIndex.value = 1,
              ),
              IconButton(
                hoverColor: Color(Colors.transparent.value),
                splashRadius: 30,
                iconSize: 50,
                icon: Icon(
                  Icons.message,
                  color: (controller.currentPageIndex.value != 2) ? Colors.grey : Colors.white,
                ),
                onPressed: () => controller.currentPageIndex.value = 2,
              ),
              IconButton(
                hoverColor: Color(Colors.transparent.value),
                splashRadius: 30,
                iconSize: 50,
                icon: Icon(
                  Icons.search,
                  color: (controller.currentPageIndex.value != 3) ? Colors.grey : Colors.white,
                ),
                onPressed: () => controller.currentPageIndex.value = 3,
              ),
              IconButton(
                hoverColor: Color(Colors.transparent.value),
                splashRadius: 30,
                iconSize: 50,
                icon: const CircleAvatar(
                  foregroundImage: CachedNetworkImageProvider(
                    'https://firebasestorage.googleapis.com/v0/b/fitnc-7be2e.appspot.com/o/trainers%2F3JRhaFnStYXbGDiLfzTRQH2QOQn2%2Fexercices%2F3PQjyBoHliMGjrYaZF2n%2Fsquat-sumo.jpg?alt=media&token=a8b755c4-6d3d-4cde-89e0-ad8a9e8dd0e9',
                  ),
                ),
                onPressed: () => controller.currentPageIndex.value = 4,
              ),
            ],
          ),
          body: Obx(() {
            switch (controller.currentPageIndex.value) {
              case 0:
                return CalendarPage();
              case 3:
                return SearchPage();
              case 4:
                return ProfilPage();
              default:
                throw Exception('Aucune page pour index ${controller.currentPageIndex.value}');
            }
          }),
        ),
      ),
    );
  }
}
