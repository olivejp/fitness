import 'package:fitnc_user/domain/abstract.domain.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class IRepository<T extends AbstractDomain, U extends Object> {
  // Get a reference your Supabase client
  SupabaseClient getSupabaseClient() {
    return Supabase.instance.client;
  }

  String getTableName();

  T convertToEntity(Map<String, dynamic> map);

  Map<String, dynamic> convertToJson(T map);

  Future<T?> create(T entity) {
    if (entity.id != null) {
      return Future.error("Id is not null");
    } else {
      return getSupabaseClient()
          .from(getTableName())
          .insert(convertToJson(entity))
          .select()
          .single()
          .then((value) => convertToEntity(value));
    }
  }

  Future<void> delete(U? id) {
    if (id == null) {
      return Future.error("Id is null");
    } else {
      return getSupabaseClient().from(getTableName()).delete().eq('id', id);
    }
  }

  Future<T?> get(U? id) {
    if (id == null) {
      return Future.error("Id is null");
    } else {
      return getSupabaseClient()
          .from(getTableName())
          .select()
          .eq('id', id)
          .single()
          .then((value) => convertToEntity(value));
    }
  }

  Stream<Iterable<T>> listen() {
    return getSupabaseClient()
        .from(getTableName())
        .stream(primaryKey: ['id']).map((rows) => rows.map((e) => convertToEntity(e)));
  }

  Future<T?> update(T entity) {
    if (entity.id == null) {
      return Future.error("Id is null");
    } else {
      return getSupabaseClient()
          .from(getTableName())
          .update(convertToJson(entity))
          .eq('id', entity.id!)
          .single()
          .then((value) => convertToEntity(value));
    }
  }
}
