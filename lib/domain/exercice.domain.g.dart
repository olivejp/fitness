// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercice.domain.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Exercice _$ExerciceFromJson(Map<String, dynamic> json) => Exercice()
  ..id = json['id'] as String?
  ..created_at = json['created_at']
  ..synchronised_at = json['synchronised_at'] == null
      ? null
      : DateTime.parse(json['synchronised_at'] as String)
  ..type = $enumDecodeNullable(_$TypeExerciseEnumMap, json['type'])
  ..videoUrl = json['video_url'] as String?
  ..youtubeUrl = json['youtube_url'] as String?
  ..description = json['description'] as String;

Map<String, dynamic> _$ExerciceToJson(Exercice instance) => <String, dynamic>{
      'id': instance.id,
      'created_at': instance.created_at,
      'synchronised_at': instance.synchronised_at?.toIso8601String(),
      'type': _$TypeExerciseEnumMap[instance.type],
      'video_url': instance.videoUrl,
      'youtube_url': instance.youtubeUrl,
      'description': instance.description,
    };

const _$TypeExerciseEnumMap = {
  TypeExercise.REPS: 'REPS',
  TypeExercise.REPS_WEIGHT: 'REPS_WEIGHT',
  TypeExercise.TIME: 'TIME',
  TypeExercise.DISTANCE: 'DISTANCE',
};
