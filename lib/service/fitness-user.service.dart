import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnc_user/di.dart';
import 'package:fitnc_user/domain/exercice.domain.dart';
import 'package:fitnc_user/domain/fitness-user.domain.dart';
import 'package:fitnc_user/domain/workout-instance.domain.dart';
import 'package:fitnc_user/service/abstract.service.dart';
import 'package:fitnc_user/service/auth.service.dart';

class FitnessUserService extends AbstractFitnessStorageService<FitnessUser> {
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  final AuthService authService = di<AuthService>();
  final String collectionName = 'users';
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
    return getCollectionReference().orderBy('createDate').snapshots().map(
        (QuerySnapshot<Map<String, dynamic>> event) => event.docs
            .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
                FitnessUser.fromJson(doc.data()))
            .toList());
  }

  Future<FitnessUser?> getConnectedUser() {
    User? user = AuthService.getUserConnected();
    if (user != null) {
      return read(user.uid);
    }
    return Future.value(null);
  }

  Stream<FitnessUser?> listenFitnessUser() {
    return authService
        .listenUserConnected()
        .asyncMap((event) => read(event!.uid));
  }

  Stream<FitnessUser?> listenFitnessUserChanges() {
    return listen(FirebaseAuth.instance.currentUser!.uid);
  }

  CollectionReference<Map<String, dynamic>> getMyExerciceReference() {
    User user = AuthService.getUserConnectedOrThrow();
    return getCollectionReference()
        .doc(user.uid)
        .collection(collectionMyExercices);
  }

  CollectionReference<Map<String, dynamic>> getMyWorkoutInstanceReference() {
    User user = AuthService.getUserConnectedOrThrow();
    return getCollectionReference()
        .doc(user.uid)
        .collection(collectionMyWorkoutInstance);
  }

  Stream<List<Exercice>> listenMyExercices() async* {
    CollectionReference<Map<String, dynamic>> colRef = getMyExerciceReference();
    yield* colRef.snapshots().map(
        (event) => event.docs.map((e) => Exercice.fromJson(e.data())).toList());
  }

  Stream<List<WorkoutInstance>> listenMyWorkoutInstance() async* {
    CollectionReference<Map<String, dynamic>> colRef =
        getMyWorkoutInstanceReference();
    yield* colRef.snapshots().map((event) =>
        event.docs.map((e) => WorkoutInstance.fromJson(e.data())).toList());
  }

  Future<List<Exercice>> getMyExercices() async {
    CollectionReference<Map<String, dynamic>> colRef = getMyExerciceReference();
    QuerySnapshot query = await colRef.get();
    return query.docs
        .map((e) => Exercice.fromJson(e.data() as Map<String, dynamic>))
        .toList();
  }
}
