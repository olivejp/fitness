import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitness_domain/domain/exercice.domain.dart';
import 'package:fitness_domain/service/abstract.service.dart';

class RefExerciceService extends AbstractFitnessCrudService<Exercice> {
  @override
  Exercice fromJson(Map<String, dynamic> map) {
    return Exercice.fromJson(map);
  }

  @override
  Stream<List<Exercice>> whereListen(Object field,
      {Object? isEqualTo,
      Object? isNotEqualTo,
      Object? isLessThan,
      Object? isLessThanOrEqualTo,
      Object? isGreaterThan,
      Object? isGreaterThanOrEqualTo,
      Object? arrayContains,
      List<Object?>? arrayContainsAny,
      List<Object?>? whereIn,
      List<Object?>? whereNotIn,
      bool? isNull}) {
    return super
        .whereListen(field,
            isEqualTo: isEqualTo,
            isNotEqualTo: isNotEqualTo,
            isLessThan: isLessThan,
            isLessThanOrEqualTo: isLessThanOrEqualTo,
            isGreaterThan: isGreaterThan,
            isGreaterThanOrEqualTo: isGreaterThanOrEqualTo,
            arrayContains: arrayContains,
            arrayContainsAny: arrayContainsAny,
            whereIn: whereIn,
            whereNotIn: whereNotIn,
            isNull: isNull)
        .map((event) => event.map((e) => e..origin = 'REF').toList());
  }

  @override
  Stream<List<Exercice>> listenAll() async* {
    yield* getCollectionReference()
        .snapshots()
        .map((event) => event.docs.map((e) => Exercice.fromJson(e.data())..origin = 'REF').toList());
  }

  @override
  Future<List<Exercice>> getAll() async {
    final future = await getCollectionReference().get();
    return future.docs.map((e) => Exercice.fromJson(e.data())..origin = 'REF').toList();
  }

  @override
  CollectionReference<Map<String, dynamic>> getCollectionReference() {
    return FirebaseFirestore.instance.collection('ref_exercices');
  }
}
