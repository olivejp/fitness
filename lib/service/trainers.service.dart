import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness_domain/domain/trainers.domain.dart';
import 'package:fitness_domain/service/abstract.service.dart';

class TrainersService extends AbstractFitnessStorageService<Trainers> {
  final FirebaseFirestore firestoreInstance = FirebaseFirestore.instance;
  final FirebaseAuth authInstance = FirebaseAuth.instance;

  @override
  Trainers fromJson(Map<String, dynamic> map) {
    return Trainers.fromJson(map);
  }

  @override
  CollectionReference<Object?> getCollectionReference() {
    return firestoreInstance.collection('trainers');
  }

  @override
  String getStorageRef(User user, Trainers domain) {
    return "trainers/${user.uid}/mainImage";
  }

  @override
  Stream<List<Trainers>> listenAll() {
    return getCollectionReference().snapshots().map((QuerySnapshot querySnapshot) =>
        querySnapshot.docs.map((QueryDocumentSnapshot docSnapshot) => Trainers.fromJson(docSnapshot.data() as Map<String, dynamic>)).toList());
  }

  @override
  Trainers mapSnapshotToModel(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    return Trainers.fromJson(snapshot.data()!);
  }
}
