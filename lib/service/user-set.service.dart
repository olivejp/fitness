
import 'package:fitnc_user/service/workout-instance.service.dart';
import 'package:fitness_domain/domain/user.set.domain.dart';
import 'package:fitness_domain/domain/workout-instance.domain.dart';
import 'package:fitness_domain/service/abstract.service.dart';

class UserSetService extends AbstractFirebaseSubcollectionCrudService<UserSet, WorkoutInstance, WorkoutInstanceService> {
  final String collectionName = 'userSet';

  @override
  UserSet fromJson(Map<String, dynamic> map) {
    return UserSet.fromJson(map);
  }

  @override
  String getCollectionName() {
    return collectionName;
  }
}
