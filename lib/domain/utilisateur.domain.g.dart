// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'utilisateur.domain.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Utilisateur _$UtilisateurFromJson(Map<String, dynamic> json) => Utilisateur()
  ..id = json['id'] as String?
  ..created_at = json['created_at']
  ..nom = json['nom'] as String?
  ..prenom = json['prenom'] as String?
  ..email = json['email'] as String?
  ..telephone = (json['telephone'] as num?)?.toInt()
  ..description = json['description'] as String?
  ..photoUrl = json['photo_url'] as String?;

Map<String, dynamic> _$UtilisateurToJson(Utilisateur instance) =>
    <String, dynamic>{
      'id': instance.id,
      'created_at': instance.created_at,
      'nom': instance.nom,
      'prenom': instance.prenom,
      'email': instance.email,
      'telephone': instance.telephone,
      'description': instance.description,
      'photo_url': instance.photoUrl,
    };
