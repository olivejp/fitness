import 'package:fitnc_user/repository/repository.interface.dart';

import '../domain/exercice.domain.dart';

class ExerciceRepository extends IRepository<Exercice> {
  @override
  String getTableName() => 'exercice';

  @override
  Stream<Iterable<Exercice>> listenByUtilisateurId(int utilisateurId) {
    return getSupabaseClient()
        .from(getTableName())
        .stream(primaryKey: ['id'])
        .eq('utilisateur_id', utilisateurId)
        .map((rows) => rows.map((e) => Exercice.fromJson(e)));
  }

  @override
  Future<List<Exercice>> getByUtilisateurId(int utilisateurId) {
    return getSupabaseClient()
        .from(getTableName())
        .select()
        .eq('utilisateur_id', utilisateurId)
        .then((value) => value.map((e) => Exercice.fromJson(e)).toList());
  }

  @override
  Future<List<Exercice>> create(Exercice exercice) {
    return getSupabaseClient()
        .from(getTableName())
        .insert(exercice.toJson())
        .select()
        .then((value) => value.map((e) => Exercice.fromJson(e)).toList());
  }

  @override
  Future<void> delete(int id) {
    return getSupabaseClient().from(getTableName()).delete().eq('id', id);
  }
}
