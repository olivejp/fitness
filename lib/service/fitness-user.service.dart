import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnc_user/service/published_programme.service.dart';
import 'package:fitness_domain/domain/exercice.domain.dart';
import 'package:fitness_domain/domain/fitness-user.domain.dart';
import 'package:fitness_domain/domain/published_programme.domain.dart';
import 'package:fitness_domain/domain/trainers.domain.dart';
import 'package:fitness_domain/domain/workout-instance.domain.dart';
import 'package:fitness_domain/service/abstract.service.dart';
import 'package:fitness_domain/service/auth.service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oktoast/oktoast.dart';

class FitnessUserService extends AbstractFitnessStorageService<FitnessUser> {
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  final PublishedProgrammeService publishedProgrammeService = Get.find();
  final AuthService authService = Get.find();
  final String collectionName = 'users';
  final String collectionMyPrograms = 'programme';
  final String collectionMyProgramsWorkouts = 'workouts';
  final String collectionMyExercices = 'exercices';
  final String collectionMyWorkoutInstance = 'workoutInstance';

  @override
  FitnessUser fromJson(Map<String, dynamic> map) {
    return FitnessUser.fromJson(map);
  }

  @override
  CollectionReference<Map<String, dynamic>> getCollectionReference() {
    return firebaseFirestore.collection(collectionName);
  }

  @override
  String getStorageRef(User user, FitnessUser domain) {
    return '$collectionName/${user.uid}';
  }

  @override
  Stream<List<FitnessUser>> listenAll() {
    return getCollectionReference().orderBy('createDate').snapshots().map((QuerySnapshot<Map<String, dynamic>> event) =>
        event.docs.map((QueryDocumentSnapshot<Map<String, dynamic>> doc) => FitnessUser.fromJson(doc.data())).toList());
  }

  Future<FitnessUser?> getConnectedUser() {
    return read(FirebaseAuth.instance.currentUser!.uid);
  }

  Stream<FitnessUser?> listenFitnessUser() {
    return authService.listenUserConnected().asyncMap((event) => read(event!.uid));
  }

  Stream<FitnessUser?> listenFitnessUserChanges() {
    return listen(FirebaseAuth.instance.currentUser!.uid);
  }

  Future<FitnessUser> _checkFitnessUserConnected() async {
    String userUid = getUserConnectedOrThrow().uid;
    FitnessUser? fitnessUser;
    fitnessUser = await read(userUid);
    if (fitnessUser == null) throw Exception("Aucun utilisateur trouvé pour l'uid $userUid");
    return fitnessUser;
  }

  CollectionReference<Map<String, dynamic>> getMyProgramsReference() {
    User? user = authService.getCurrentUser();
    if (user == null) throw Exception('Aucun utilisateur connecté');
    return getCollectionReference().doc(user.uid).collection(collectionMyPrograms);
  }

  CollectionReference<Map<String, dynamic>> getMyExerciceReference() {
    User? user = authService.getCurrentUser();
    if (user == null) throw Exception('Aucun utilisateur connecté');
    return getCollectionReference().doc(user.uid).collection(collectionMyExercices);
  }

  CollectionReference<Map<String, dynamic>> getMyWorkoutInstanceReference() {
    User? user = authService.getCurrentUser();
    if (user == null) throw Exception('Aucun utilisateur connecté');
    return getCollectionReference().doc(user.uid).collection(collectionMyWorkoutInstance);
  }

  Stream<List<PublishedProgramme>> listenMyPrograms() {
    return getMyProgramsReference().snapshots().map((event) => event.docs.map((e) => PublishedProgramme.fromJson(e.data())).toList());
  }

  Stream<List<Exercice>> listenMyExercices() async* {
    CollectionReference<Map<String, dynamic>> colRef = getMyExerciceReference();
    yield* colRef.snapshots().map((event) => event.docs.map((e) => Exercice.fromJson(e.data())).toList());
  }

  Stream<List<WorkoutInstance>> listenMyWorkoutInstance() async* {
    CollectionReference<Map<String, dynamic>> colRef = getMyWorkoutInstanceReference();
    yield* colRef.snapshots().map((event) => event.docs.map((e) => WorkoutInstance.fromJson(e.data())).toList());
  }

  Future<List<PublishedProgramme>> getMyPrograms() async {
    CollectionReference<Map<String, dynamic>> colRef = await getMyProgramsReference();
    QuerySnapshot query = await colRef.get();
    return query.docs.map((e) => PublishedProgramme.fromJson(e.data() as Map<String, dynamic>)).toList();
  }

  Future<List<Exercice>> getMyExercices() async {
    CollectionReference<Map<String, dynamic>> colRef = await getMyExerciceReference();
    QuerySnapshot query = await colRef.get();
    return query.docs.map((e) => Exercice.fromJson(e.data() as Map<String, dynamic>)).toList();
  }

  Future<void> register(PublishedProgramme publishedProgramme) async {
    FitnessUser fitnessUser = await _checkFitnessUserConnected();

    // Vérification que le programme n'a pas déjà enregistré.
    if ((await getMyPrograms()).map((e) => e.uid).contains(publishedProgramme.uid)) {
      showToast('Vous êtes déjà abonné à ce programme.', backgroundColor: Colors.red, duration: const Duration(seconds: 5));
      return;
    }

    // Création d'un batch
    WriteBatch batch = firebaseFirestore.batch();
    DocumentReference userProgrammeReference =
        getCollectionReference().doc(fitnessUser.uid).collection(collectionMyPrograms).doc(publishedProgramme.uid);

    // Copie toutes les informations propres au programme.
    batch.set(userProgrammeReference, publishedProgramme.toJson());

    // Lecture de tous les workouts.
    final QuerySnapshot<Object?> mapWorkouts =
        await publishedProgrammeService.getCollectionReference().doc(publishedProgramme.uid).collection(collectionMyProgramsWorkouts).get();

    // Copie toutes les informations des workouts qui composent le programme.
    for (final QueryDocumentSnapshot<Object?> docs in mapWorkouts.docs) {
      final DocumentReference<Object?> docRef = userProgrammeReference.collection(collectionMyProgramsWorkouts).doc(docs.id);
      batch.set(docRef, docs.data());
    }

    return batch.commit();
  }

  Future<void> unregister(PublishedProgramme publishedProgramme) async {
    FitnessUser fitnessUser = await _checkFitnessUserConnected();

    // Création d'un batch
    WriteBatch batch = firebaseFirestore.batch();
    DocumentReference userProgrammeReference =
        getCollectionReference().doc(fitnessUser.uid).collection(collectionMyPrograms).doc(publishedProgramme.uid);

    // Suppression de tous les workouts qui composent le programme.
    QuerySnapshot<Object?> value = await userProgrammeReference.collection(collectionMyProgramsWorkouts).get();
    for (final QueryDocumentSnapshot<Object?> element in value.docs) {
      batch.delete(element.reference);
    }

    // Suppression de toutes les informations propres au programme.
    batch.delete(userProgrammeReference);

    return batch.commit();
  }

  ///
  /// Permet d'ajouter un trainer à sa liste de favoris.
  ///
  Future<void> addToFavorite(Trainers trainer) {
    // TODO
    return Future<void>.value();
  }
}
