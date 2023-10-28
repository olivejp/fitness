import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnc_user/service/trainers.service.dart';
import 'package:fitness_domain/domain/published_programme.domain.dart';
import 'package:fitness_domain/domain/trainers.domain.dart';
import 'package:fitness_domain/service/abstract.service.dart';
import 'package:get_it/get_it.dart';

class PublishedProgrammeService extends AbstractFitnessStorageService<PublishedProgramme> {
  final FirebaseFirestore firestoreInstance = FirebaseFirestore.instance;
  final TrainersService trainersService = GetIt.I.get();
  final String publishedProgrammeCollectionName = 'publishedProgrammes';

  @override
  PublishedProgramme fromJson(Map<String, dynamic> map) {
    return PublishedProgramme.fromJson(map);
  }

  @override
  Stream<List<PublishedProgramme>> listenAll() {
    return getCollectionReference().orderBy('name').snapshots().map((QuerySnapshot<Object?> event) {
      return event.docs.map((QueryDocumentSnapshot<Object?> e) {
        return PublishedProgramme.fromJson(e.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  @override
  CollectionReference<Object?> getCollectionReference() {
    return firestoreInstance.collection(publishedProgrammeCollectionName);
  }

  @override
  String getStorageRef(User user, PublishedProgramme domain) {
    return '$publishedProgrammeCollectionName/${domain.uid}';
  }

  Future<List<Trainers>> getTrainersWithPublishedProgram() async {
    List<PublishedProgramme> allPublishedPrograms = await getAll();
    List<String?> listTrainersUid = allPublishedPrograms.map((e) => e.creatorUid).toList();
    return trainersService.where('uid', whereIn: listTrainersUid);
  }
}
