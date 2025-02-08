import 'package:fitnc_user/domain/utilisateur.domain.dart';
import 'package:fitnc_user/repository/repository.interface.dart';

class UtilisateurRepository extends IRepository<Utilisateur, String> {
  @override
  String getTableName() => 'utilisateur';

  @override
  Utilisateur convertToEntity(Map<String, dynamic> map) {
    return Utilisateur.fromJson(map);
  }

  @override
  Map<String, dynamic> convertToJson(Utilisateur map) {
    return map.toJson();
  }
}
