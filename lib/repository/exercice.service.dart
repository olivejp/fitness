import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/exercice.dart';

class ExerciceService {
  // Get a reference your Supabase client
  final supabase = Supabase.instance.client;

  static getTableName() => 'exercice';

  Stream<Iterable<Exercice>> listenByUtilisateurId(int utilisateurId) {
    return supabase
        .from(getTableName())
        .stream(primaryKey: ['id'])
        .eq('utilisateur_id', utilisateurId)
        .map((rows) => rows.map((e) => Exercice.fromJson(e)));
  }

  Future<List<Exercice>> getByUtilisateurId(int utilisateurId) {
    return supabase
        .from(getTableName())
        .select()
        .eq('utilisateur_id', utilisateurId)
        .then((value) => value.map((e) => Exercice.fromJson(e)).toList());
  }

  Future<List<Exercice>> createExercice(Exercice exercice) {
    return supabase
        .from(getTableName())
        .insert(exercice.toJson())
        .select()
        .then((value) => value.map((e) => Exercice.fromJson(e)).toList());
  }
}
