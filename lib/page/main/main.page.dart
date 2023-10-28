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
              onTap: (index) => context.go(FitncRouter.getNavigationRouteFromIndex(index)),
              currentIndex: notifier.currentIndex,
              items: FitncRouter.targets
                  .map((e) => BottomNavigationBarItem(icon: Icon(e.icon), label: e.label.i18n()))
                  .toList());
        }),
        body: child,
      ),
    );
  }
}
//
// class HomeBottomAppBar2 extends StatelessWidget {
//   const HomeBottomAppBar2({
//     super.key,
//     this.iconSizedBox = 20,
//   });
//
//   final double iconSizedBox;
//
//   @override
//   Widget build(BuildContext context) {
//     return BottomAppBar(
//       clipBehavior: Clip.antiAlias,
//       child: BottomIconInherited(
//         selectedColor: Theme.of(context).primaryColor,
//         unselectedColor: Colors.grey,
//         height: 60,
//         width: 80,
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//           children: [
//             Flexible(
//               child: BottomIcon(
//                 label: 'calendar'.tr,
//                 iconData: Icons.calendar_today,
//                 indexPage: IndexPage.calendar,
//               ),
//             ),
//             Flexible(
//               child: BottomIcon(
//                 label: 'search'.tr,
//                 iconData: Icons.school_outlined,
//                 indexPage: IndexPage.search,
//               ),
//             ),
//             Flexible(
//               child: BottomIcon(
//                 label: 'profile'.tr,
//                 iconData: Icons.person,
//                 indexPage: IndexPage.profile,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class BottomIconInherited extends InheritedWidget {
//   const BottomIconInherited(
//       {super.key,
//       required this.height,
//       required this.width,
//       required this.selectedColor,
//       required this.unselectedColor,
//       required super.child});
//
//   final Color selectedColor;
//   final Color unselectedColor;
//   final double height;
//   final double width;
//
//   static BottomIconInherited of(BuildContext context) =>
//       context.dependOnInheritedWidgetOfExactType<BottomIconInherited>() as BottomIconInherited;
//
//   @override
//   bool updateShouldNotify(covariant InheritedWidget oldWidget) {
//     BottomIconInherited old = (oldWidget as BottomIconInherited);
//     return old.selectedColor != selectedColor || old.unselectedColor != unselectedColor;
//   }
// }
//
// class BottomIcon extends StatelessWidget {
//   const BottomIcon({super.key, required this.label, required this.iconData, required this.indexPage});
//
//   final String label;
//   final IconData iconData;
//   final IndexPage indexPage;
//
//   @override
//   Widget build(BuildContext context) {
//     Color selectedColor = BottomIconInherited.of(context).selectedColor;
//     Color unselectedColor = BottomIconInherited.of(context).unselectedColor;
//     double height = BottomIconInherited.of(context).height;
//     double width = BottomIconInherited.of(context).width;
//     return Consumer<MainController>(builder: (context, controller, child) {
//       return InkWell(
//         radius: 25,
//         borderRadius: const BorderRadius.all(Radius.circular(25)),
//         onTap: () => controller.setCurrentIndex(indexPage),
//         child: SizedBox(
//           height: height,
//           width: width,
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Icon(iconData, color: controller.currentIndex == indexPage ? selectedColor : unselectedColor),
//               Text(
//                 label,
//                 style: TextStyle(color: controller.currentIndex == indexPage ? selectedColor : unselectedColor),
//               ),
//             ],
//           ),
//         ),
//       );
//     });
//   }
// }
//
// class HomeBottomAppBar extends StatelessWidget {
//   const HomeBottomAppBar({
//     super.key,
//     required this.controller,
//     this.iconSizedBox = 20,
//   });
//
//   final MainController controller;
//   final double iconSizedBox;
//
//   @override
//   Widget build(BuildContext context) {
//     return BottomAppBar(
//       clipBehavior: Clip.antiAlias,
//       child: Obx(
//         () => BottomNavigationBarTheme(
//           data: BottomNavigationBarThemeData(
//             selectedItemColor: Theme.of(context).primaryColor,
//             unselectedItemColor: Colors.grey,
//           ),
//           child: BottomNavigationBar(
//             type: BottomNavigationBarType.fixed,
//             elevation: 0,
//             showSelectedLabels: true,
//             showUnselectedLabels: true,
//             currentIndex: controller.currentIndex.index,
//             items: <BottomNavigationBarItem>[
//               BottomNavigationBarItem(
//                 label: 'calendar'.tr,
//                 activeIcon: const Icon(
//                   Icons.calendar_today,
//                 ),
//                 icon: SizedBox(
//                   height: iconSizedBox,
//                   width: iconSizedBox,
//                   child: IconButton(
//                     padding: const EdgeInsets.all(0),
//                     onPressed: () => controller.setCurrentIndex(IndexPage.calendar),
//                     icon: const Icon(
//                       Icons.calendar_today,
//                     ),
//                   ),
//                 ),
//               ),
//               BottomNavigationBarItem(
//                 label: 'search'.tr,
//                 activeIcon: const Icon(
//                   Icons.explore_rounded,
//                 ),
//                 icon: SizedBox(
//                   height: iconSizedBox,
//                   width: iconSizedBox,
//                   child: IconButton(
//                     padding: const EdgeInsets.all(0),
//                     onPressed: () => controller.setCurrentIndex(IndexPage.search),
//                     icon: const Icon(
//                       Icons.explore_rounded,
//                     ),
//                   ),
//                 ),
//               ),
//               BottomNavigationBarItem(
//                 label: 'profile'.tr,
//                 icon: SizedBox(
//                   height: iconSizedBox,
//                   width: iconSizedBox,
//                   child: IconButton(
//                     padding: const EdgeInsets.all(0),
//                     icon: Consumer<UserNotifier>(
//                       builder: (context, userNotifier, child) {
//                         if (userNotifier.user?.imageUrl != null) {
//                           return CircleAvatar(
//                             radius: 30,
//                             foregroundImage: CachedNetworkImageProvider(userNotifier.user!.imageUrl!),
//                           );
//                         }
//                         return CircleAvatar(
//                           radius: 30,
//                           backgroundColor: Theme.of(context).primaryColor,
//                         );
//                       },
//                     ),
//                     onPressed: () => controller.setCurrentIndex(IndexPage.profile),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
