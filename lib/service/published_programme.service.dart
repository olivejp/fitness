import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness_domain/domain/published_programme.domain.dart';
import 'package:fitness_domain/service/abstract.service.dart';

class PublishedProgrammeService extends AbstractFitnessStorageService<PublishedProgramme> {
  final FirebaseFirestore firestoreInstance = FirebaseFirestore.instance;
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final String publishedProgrammeCollectionName = 'publishedProgrammes';

  @override
  PublishedProgramme fromJson(Map<String, dynamic> map) {
    return PublishedProgramme.fromJson(map);
  }

  @override
  Stream<List<PublishedProgramme>> listenAll() {
    return getCollectionReference().orderBy('name').snapshots().map((QuerySnapshot<Object?> event) =>
        event.docs.map((QueryDocumentSnapshot<Object?> e) => PublishedProgramme.fromJson(e.data() as Map<String, dynamic>)).toList());
  }

  @override
  CollectionReference<Object?> getCollectionReference() {
    return firestoreInstance.collection(publishedProgrammeCollectionName);
  }

  @override
  String getStorageRef(User user, PublishedProgramme programme) {
    return '$publishedProgrammeCollectionName/${programme.uid}';
  }
}
