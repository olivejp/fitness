import 'package:fitnc_user/controller/display-type.controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LayoutDisplayNotifier extends StatelessWidget {
  LayoutDisplayNotifier({
    Key? key,
    required this.child,
    this.desktopSize = 1280,
    this.tabletSize = 768,
  }) : super(key: key);
  final int desktopSize;
  final int tabletSize;
  final Widget child;
  final DisplayTypeController displayTypeController = Get.find();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, BoxConstraints constraints) {
        /// Mise à jour du displayType selon la largeur de l'écran.
        DisplayType displayType = DisplayType.desktop;
        if (constraints.maxWidth >= desktopSize) {
          displayType = DisplayType.desktop;
        } else if (constraints.maxWidth >= tabletSize && constraints.maxWidth <= desktopSize - 1) {
          displayType = DisplayType.tablet;
        } else {
          displayType = DisplayType.mobile;
        }
        displayTypeController.changeDisplay(displayType);
        return child;
      },
    );
  }
}
