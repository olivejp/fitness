import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnc_user/service/workout-instance.service.dart';
import 'package:fitness_domain/domain/user.set.domain.dart';
import 'package:fitness_domain/domain/workout-instance.domain.dart';
import 'package:fitness_domain/service/abstract.service.dart';

class UserSetService
    extends AbstractFirebaseSubcollectionCrudService<UserSet, WorkoutInstance, WorkoutInstanceService> {
  final String collectionName = 'userSet';

  @override
  UserSet fromJson(Map<String, dynamic> map) {
    return UserSet.fromJson(map);
  }

  @override
  String getCollectionName() {
    return collectionName;
  }

  Future<List<UserSet>> getForExercice(String uidExercice) {
    String userUid = FirebaseAuth.instance.currentUser!.uid;
    Query query = FirebaseFirestore.instance
        .collectionGroup(collectionName)
        .where('creatorUid', isEqualTo: userUid)
        .where('uidExercice', isEqualTo: uidExercice)
        .where('date', isNull: false)
        .orderBy('date');
    return getFromQuery(query);
  }

  Stream<bool> areAllChecked(String uidWorkout) {
    return listenAll(uidWorkout).map((listUserSet) {
      bool checked = true;
      for (var userSet in listUserSet) {
        if (userSet.lines.isEmpty) {
          checked = false;
          break;
        }
        if (userSet.lines.any((element) => !element.checked)) {
          checked = false;
          break;
        }
      }
      return checked;
    });
  }
}
