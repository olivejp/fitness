import 'package:fitnc_user/domain/parametre.domain.dart';
import 'package:fitnc_user/repository/repository.interface.dart';

class ParametreRepository extends IRepository<Parametre, String> {
  @override
  String getTableName() => 'parametre';

  @override
  Parametre convertToEntity(Map<String, dynamic> map) {
    return Parametre.fromJson(map);
  }

  @override
  Map<String, dynamic> convertToJson(Parametre map) {
    return map.toJson();
  }
}
