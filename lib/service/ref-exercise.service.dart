import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitness_domain/domain/exercise.domain.dart';
import 'package:fitness_domain/service/abstract.service.dart';

class RefExerciseService extends AbstractFitnessCrudService<Exercise> {
  @override
  Exercise fromJson(Map<String, dynamic> map) {
    return Exercise.fromJson(map);
  }

  @override
  Stream<List<Exercise>> whereListen(Object field,
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
  Stream<List<Exercise>> listenAll() async* {
    yield* getCollectionReference()
        .snapshots()
        .map((event) => event.docs.map((e) => Exercise.fromJson(e.data())..origin = 'REF').toList());
  }

  @override
  Future<List<Exercise>> getAll() async {
    final future = await getCollectionReference().get();
    return future.docs.map((e) => Exercise.fromJson(e.data())..origin = 'REF').toList();
  }

  @override
  CollectionReference<Map<String, dynamic>> getCollectionReference() {
    return FirebaseFirestore.instance.collection('ref_exercices');
  }
}
