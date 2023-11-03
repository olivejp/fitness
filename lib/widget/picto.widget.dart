import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:loading_animations/loading_animations.dart';

class Picto {
  String? name;
  String? imageUrl;

  static Picto fromJson(String name, Map<String, dynamic> json) {
    return Picto()
      ..name = name
      ..imageUrl = json['imageUrl'] as String?;
  }
}

enum MuscularPart {
  FRONT,
  BACK,
}

enum MuscularBackGroup {
  DELTOID_REAR,
  GRAND_ROND,
  LAT,
  LOMBAIRE,
  TRAPEZE,
  TRICEPS,
  FESSIER,
  ISCIO,
  MOLLET,
  ABDUCTEUR_REAR,
}

enum MuscularFrontGroup {
  PECS,
  DELTOID,
  BICEPS,
  DROIT_ANTERIEUR,
  MOLLET_FRONT,
  VASTE_INTERNE,
  ABDO_BOTTOM,
  ABDO_FULL,
  ABDO_LAT,
  ABDO_TOP,
  ABDUCTEUR,
  ADDUCTEUR;
}

class PictoWidget extends StatelessWidget {
  PictoWidget({super.key, required this.listFront, required this.listBack});

  final CollectionReference<Map<String, dynamic>> db = FirebaseFirestore.instance.collection('ref_muscular_groups');
  final List<MuscularFrontGroup> listFront;
  final List<MuscularBackGroup> listBack;

  Future<Picto> getFrontPicto() async {
    final front = await db.doc(MuscularPart.FRONT.name).get();
    return Picto.fromJson(front.id, front.data() as Map<String, dynamic>);
  }

  Future<Picto> getBackPicto() async {
    final back = await db.doc(MuscularPart.BACK.name).get();
    return Picto.fromJson(back.id, back.data() as Map<String, dynamic>);
  }

  Future<List<Picto>> getFrontMuscle(List<MuscularFrontGroup> list) async {
    final query = db.where(FieldPath.documentId, whereIn: list.map((e) => e.name).toList());
    final snapshot = await query.get();
    return snapshot.docs.map((e) => Picto.fromJson(e.id, e.data())).toList();
  }

  Future<List<Picto>> getBackMuscle(List<MuscularBackGroup> list) async {
    final query = db.where(FieldPath.documentId, whereIn: list.map((e) => e.name).toList());
    final snapshot = await query.get();
    return snapshot.docs.map((e) => Picto.fromJson(e.id, e.data())).toList();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: Row(
        children: [
          Flexible(
            child: Stack(
              children: [
                FutureBuilder<Picto>(
                  future: getFrontPicto(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final Picto picto = snapshot.data!;
                      return SvgPicture.network(picto.imageUrl!);
                    } else {
                      return LoadingBouncingGrid.square();
                    }
                  },
                ),
                FutureBuilder<List<Picto>>(
                  future: getFrontMuscle(listFront),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final List<Picto> list = snapshot.data!;
                      return Stack(children: list.map((e) => SvgPicture.network(e.imageUrl!)).toList());
                    } else {
                      return LoadingBouncingGrid.square();
                    }
                  },
                )
              ],
            ),
          ),
          Flexible(
            child: Stack(
              children: [
                FutureBuilder<Picto>(
                  future: getBackPicto(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final Picto picto = snapshot.data!;
                      return SvgPicture.network(picto.imageUrl!);
                    } else {
                      return LoadingBouncingGrid.square();
                    }
                  },
                ),
                FutureBuilder<List<Picto>>(
                  future: getBackMuscle(listBack),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final List<Picto> list = snapshot.data!;
                      return Stack(children: list.map((e) => SvgPicture.network(e.imageUrl!)).toList());
                    } else {
                      return LoadingBouncingGrid.square();
                    }
                  },
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PictoAssetWidget extends StatelessWidget {
  const PictoAssetWidget({super.key, required this.listFront, required this.listBack, this.height = 100});

  final List<MuscularFrontGroup> listFront;
  final List<MuscularBackGroup> listBack;
  final double? height;

  String getAssetPath(String part) {
    return 'images/picto/${part.toLowerCase()}.svg';
  }

  String getPartAssetPath(MuscularPart part) {
    return getAssetPath(part.name);
  }

  String getFrontAssetPath(MuscularFrontGroup part) {
    return getAssetPath(part.name);
  }

  String getBackAssetPath(MuscularBackGroup part) {
    return getAssetPath(part.name);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Row(
        children: [
          Flexible(
            child: Stack(children: [
              SvgPicture.asset(getPartAssetPath(MuscularPart.FRONT)),
              Stack(children: listFront.map((e) => SvgPicture.asset(getFrontAssetPath(e))).toList()),
            ]),
          ),
          Flexible(
            child: Stack(children: [
              SvgPicture.asset(getPartAssetPath(MuscularPart.BACK)),
              Stack(children: listBack.map((e) => SvgPicture.asset(getBackAssetPath(e))).toList()),
            ]),
          ),
        ],
      ),
    );
  }
}
