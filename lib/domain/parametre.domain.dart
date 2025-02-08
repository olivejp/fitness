import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

import 'abstract.domain.dart';

part 'parametre.domain.g.dart';

@HiveType(typeId: 1)
@JsonSerializable()
class Parametre extends AbstractDomain {
  Parametre();

  factory Parametre.fromJson(Map<String, dynamic> data) => _$ParametreFromJson(data);

  @override
  Map<String, dynamic> toJson() => _$ParametreToJson(this);

  @HiveField(3)
  String? nom;

  @HiveField(4)
  String? libelle;

  @HiveField(5)
  String? valeur;

  @HiveField(6)
  int? order;
}
