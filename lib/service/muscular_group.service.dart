enum MuscularPart {
  FRONT(1),
  BACK(2);

  final int order;

  const MuscularPart(this.order);
}

enum MuscularBackGroup {
  TRAPEZE(1, MuscularPart.BACK),
  GRAND_ROND(2, MuscularPart.BACK),
  LAT(3, MuscularPart.BACK),
  DELTOID_REAR(4, MuscularPart.BACK),
  TRICEPS(5, MuscularPart.BACK),
  LOMBAIRE(6, MuscularPart.BACK),
  FESSIER(7, MuscularPart.BACK),
  ISCIO(8, MuscularPart.BACK),
  MOLLET(9, MuscularPart.BACK);

  final int order;
  final MuscularPart part;

  const MuscularBackGroup(this.order, this.part);
}

enum MuscularFrontGroup {
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

  const MuscularFrontGroup(this.order, this.part);
}

class MuscularGroupService {
  static List<MuscularFrontGroup> getListFront() {
    List<MuscularFrontGroup> list = [];
    list.addAll(MuscularFrontGroup.values);
    list.sort((a, b) => a.order.compareTo(b.order));
    return list;
  }

  static List<MuscularBackGroup> getListBack() {
    List<MuscularBackGroup> list = [];
    list.addAll(MuscularBackGroup.values);
    list.sort((a, b) => a.order.compareTo(b.order));
    return list;
  }
}
