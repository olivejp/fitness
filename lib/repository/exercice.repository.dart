import 'package:fitnc_user/repository/repository.interface.dart';

import '../domain/exercice.domain.dart';

class ExerciceRepository extends IRepository<Exercice, String> {
  @override
  String getTableName() => 'exercice';

  @override
  Exercice convertToEntity(Map<String, dynamic> map) {
    return Exercice.fromJson(map);
  }

  @override
  Map<String, dynamic> convertToJson(Exercice map) {
    return map.toJson();
  }

  Stream<Iterable<Exercice>> listenByUtilisateurId(int utilisateurId) {
    return getSupabaseClient()
        .from(getTableName())
        .stream(primaryKey: ['id'])
        .eq('utilisateur_id', utilisateurId)
        .map((rows) => rows.map((e) => Exercice.fromJson(e)));
  }

  Future<List<Exercice>> getByUtilisateurId(int utilisateurId) {
    return getSupabaseClient()
        .from(getTableName())
        .select()
        .eq('utilisateur_id', utilisateurId)
        .then((value) => value.map((e) => Exercice.fromJson(e)).toList());
  }
}
