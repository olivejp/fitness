import 'package:json_annotation/json_annotation.dart';

import 'abstract.domain.dart';

part 'utilisateur.domain.g.dart';

@JsonSerializable()
class Utilisateur extends AbstractDomain {
  Utilisateur();

  factory Utilisateur.fromJson(Map<String, dynamic> data) => _$UtilisateurFromJson(data);

  @override
  Map<String, dynamic> toJson() => _$UtilisateurToJson(this);

  String? nom;
  String? prenom;
  String? email;
  String? telephone1;
  String? description;
  String? sexe;

  @JsonKey(name: "photo_url")
  String? photoUrl;
}
