import 'package:hive/hive.dart';

abstract class AbstractDomain {
  AbstractDomain();

  @HiveField(0)
  String? id;

  @HiveField(1)
  dynamic created_at;

  @HiveField(2)
  DateTime? synchronised_at;
}
