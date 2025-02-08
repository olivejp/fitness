import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

import 'abstract.domain.dart';

part 'utilisateur.domain.g.dart';

@HiveType(typeId: 0)
@JsonSerializable()
class Utilisateur extends AbstractDomain {
  Utilisateur();

  factory Utilisateur.fromJson(Map<String, dynamic> data) => _$UtilisateurFromJson(data);

  @override
  Map<String, dynamic> toJson() => _$UtilisateurToJson(this);

  @HiveField(3)
  String? nom;

  @HiveField(4)
  String? prenom;

  @HiveField(5)
  String? email;

  @HiveField(6)
  String? telephone1;

  @HiveField(7)
  String? description;

  @HiveField(8)
  String? sexe;

  @HiveField(9)
  @JsonKey(name: "photo_url")
  String? photoUrl;
}
