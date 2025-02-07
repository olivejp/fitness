import 'package:fitnc_user/domain/utilisateur.domain.dart';
import 'package:fitnc_user/repository/repository.interface.dart';

class UtilisateurRepository extends IRepository<Utilisateur> {
  @override
  String getTableName() => 'utilisateur';

  Future<Utilisateur?> getById(String? id) {
    if (id != null) {
      return getSupabaseClient()
          .from(getTableName())
          .select()
          .eq('id', id)
          .single()
          .then((value) => Utilisateur.fromJson(value));
    } else {
      return Future.value(null);
    }
  }

  @override
  Stream<Iterable<Utilisateur>> listenByUtilisateurId(int utilisateurId) {
    return getSupabaseClient()
        .from(getTableName())
        .stream(primaryKey: ['id'])
        .eq('utilisateur_id', utilisateurId)
        .map((rows) => rows.map((e) => Utilisateur.fromJson(e)));
  }

  @override
  Future<List<Utilisateur>> getByUtilisateurId(int utilisateurId) {
    return getSupabaseClient()
        .from(getTableName())
        .select()
        .eq('id', utilisateurId)
        .then((value) => value.map((e) => Utilisateur.fromJson(e)).toList());
  }

  @override
  Future<List<Utilisateur>> create(Utilisateur exercice) {
    return getSupabaseClient()
        .from(getTableName())
        .insert(exercice.toJson())
        .select()
        .then((value) => value.map((e) => Utilisateur.fromJson(e)).toList());
  }

  @override
  Future<void> delete(int id) {
    return getSupabaseClient().from(getTableName()).delete().eq('id', id);
  }
}
