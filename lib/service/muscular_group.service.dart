enum MuscularPart {
  FRONT(1),
  BACK(2);

  final int order;
  const MuscularPart(this.order);
}

enum MuscularGroup {
  TRAPEZE(1, MuscularPart.BACK),
  GRAND_ROND(2, MuscularPart.BACK),
  LAT(3, MuscularPart.BACK),
  DELTOID_REAR(4, MuscularPart.BACK),
  TRICEPS(5, MuscularPart.BACK),
  LOMBAIRE(6, MuscularPart.BACK),
  FESSIER(7, MuscularPart.BACK),
  ISCIO(8, MuscularPart.BACK),
  MOLLET(9, MuscularPart.BACK),

  PECS(1, MuscularPart.FRONT),
  DELTOID(2, MuscularPart.FRONT),
  BICEPS(3, MuscularPart.FRONT),
  ABDO_TOP(4, MuscularPart.FRONT),
  ABDO_BOTTOM(5, MuscularPart.FRONT),
  OBLIQUE(6, MuscularPart.FRONT),
  DROIT_ANTERIEUR(7, MuscularPart.FRONT),
  VASTE_INTERNE(8, MuscularPart.FRONT),
  VASTE_EXTERNE(9, MuscularPart.FRONT),
  ADDUCTEUR(10, MuscularPart.FRONT);

  final int order;
  final MuscularPart part;

  const MuscularGroup(this.order, this.part);
}

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
