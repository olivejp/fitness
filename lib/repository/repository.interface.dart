import 'package:supabase_flutter/supabase_flutter.dart';

abstract class IRepository<T> {
  // Get a reference your Supabase client
  SupabaseClient getSupabaseClient() {
    return Supabase.instance.client;
  }

  String getTableName();

  Stream<Iterable<T>> listenByUtilisateurId(int utilisateurId);

  Future<List<T>> getByUtilisateurId(int utilisateurId);

  Future<List<T>> create(T exercice);

  Future<void> delete(int id);
}
