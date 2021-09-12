import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnc_user/service/published_programme.service.dart';
import 'package:fitness_domain/domain/fitness-user.domain.dart';
import 'package:fitness_domain/domain/published_programme.domain.dart';
import 'package:fitness_domain/service/abstract.service.dart';
import 'package:fitness_domain/service/auth.service.dart';
import 'package:get/get.dart';

class FitnessUserService extends AbstractFitnessStorageService<FitnessUser> {
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  final PublishedProgrammeService publishedProgrammeService = Get.find();
  final String collectionName = 'users';
  final AuthService authService = Get.find();

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

  Future<void> register(PublishedProgramme publishedProgramme) async {
    final User? user = authService.getCurrentUser();
    if (user == null) throw Exception('Aucun utilisateur connecté');

    FitnessUser? fitnessUser;
      fitnessUser = await read(user.uid);
    if (fitnessUser == null) throw Exception("Aucun utilisateur trouvé pour l'uid ${user.uid}");

    // Création d'un batch
    WriteBatch batch = firebaseFirestore.batch();
    DocumentReference userProgrammeReference = getCollectionReference().doc(fitnessUser.uid).collection('programme').doc(publishedProgramme.uid);
    batch.set(userProgrammeReference, publishedProgramme.toJson());

    // Lecture de tous les workouts.
    final QuerySnapshot<Map<String, dynamic>> mapWorkouts = await publishedProgrammeService.getCollectionReference().doc(publishedProgramme.uid).collection('workouts').get();

    for (final QueryDocumentSnapshot<Map<String, dynamic>> docs in mapWorkouts.docs) {
      final DocumentReference<Map<String, dynamic>> docRef = userProgrammeReference.collection('workouts').doc(docs.id);
      batch.set(docRef, docs.data());
    }

    return batch.commit();
  }
}
