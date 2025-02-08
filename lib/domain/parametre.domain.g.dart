// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'parametre.domain.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ParametreAdapter extends TypeAdapter<Parametre> {
  @override
  final int typeId = 1;

  @override
  Parametre read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Parametre()
      ..nom = fields[3] as String?
      ..libelle = fields[4] as String?
      ..valeur = fields[5] as String?
      ..order = fields[6] as int?
      ..id = fields[0] as String?
      ..created_at = fields[1] as dynamic
      ..synchronised_at = fields[2] as DateTime?;
  }

  @override
  void write(BinaryWriter writer, Parametre obj) {
    writer
      ..writeByte(7)
      ..writeByte(3)
      ..write(obj.nom)
      ..writeByte(4)
      ..write(obj.libelle)
      ..writeByte(5)
      ..write(obj.valeur)
      ..writeByte(6)
      ..write(obj.order)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.created_at)
      ..writeByte(2)
      ..write(obj.synchronised_at);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ParametreAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Parametre _$ParametreFromJson(Map<String, dynamic> json) => Parametre()
  ..id = json['id'] as String?
  ..created_at = json['created_at']
  ..synchronised_at = json['synchronised_at'] == null
      ? null
      : DateTime.parse(json['synchronised_at'] as String)
  ..nom = json['nom'] as String?
  ..libelle = json['libelle'] as String?
  ..valeur = json['valeur'] as String?
  ..order = (json['order'] as num?)?.toInt();

Map<String, dynamic> _$ParametreToJson(Parametre instance) => <String, dynamic>{
      'id': instance.id,
      'created_at': instance.created_at,
      'synchronised_at': instance.synchronised_at?.toIso8601String(),
      'nom': instance.nom,
      'libelle': instance.libelle,
      'valeur': instance.valeur,
      'order': instance.order,
    };
