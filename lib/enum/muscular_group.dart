import 'muscular_part.dart';

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
