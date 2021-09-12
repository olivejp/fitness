import 'package:get/get.dart';

enum DisplayType {
  desktop,
  tablet,
  mobile,
}


/// Controller qui permet de savoir quel est l'affichage courant
class DisplayTypeController extends GetxController {
  Rx<DisplayType> displayType = DisplayType.mobile.obs;

  void changeDisplay(DisplayType newDisplayType) {
    displayType.value = newDisplayType;
    update();
  }
}
