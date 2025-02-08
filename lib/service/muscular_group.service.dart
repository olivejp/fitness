import 'package:fitnc_user/enum/muscular_group.dart';
import 'package:fitnc_user/enum/muscular_part.dart';

class MuscularGroupService {
  static List<MuscularGroup> getAll() {
    List<MuscularGroup> list = [];
    list.addAll(MuscularGroup.values);
    list.sort((a, b) {
      int compare1 = a.part.name.compareTo(b.part.name);
      if (compare1 == 0) {
        return a.order.compareTo(b.order);
      }
      return compare1;
    });
    return list;
  }

  static List<MuscularGroup> getListFront() {
    List<MuscularGroup> list = [];
    list.addAll(MuscularGroup.values.where((element) => element.part == MuscularPart.FRONT));
    list.sort((a, b) => a.order.compareTo(b.order));
    return list;
  }

  static List<MuscularGroup> getListBack() {
    List<MuscularGroup> list = [];
    list.addAll(MuscularGroup.values.where((element) => element.part == MuscularPart.BACK));
    list.sort((a, b) => a.order.compareTo(b.order));
    return list;
  }
}
