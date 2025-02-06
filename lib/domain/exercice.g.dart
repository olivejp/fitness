// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercice.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Exercice _$ExerciseFromJson(Map<String, dynamic> json) => Exercice()
  ..type = $enumDecodeNullable(_$TypeExerciseEnumMap, json['type'])
  ..video_url = json['video_url'] as String?
  ..youtube_url = json['youtube_url'] as String?
  ..description = json['description'] as String;

Map<String, dynamic> _$ExerciseToJson(Exercice instance) => <String, dynamic>{
      'type': _$TypeExerciseEnumMap[instance.type],
      'video_url': instance.video_url,
      'youtube_url': instance.youtube_url,
      'description': instance.description,
    };

const _$TypeExerciseEnumMap = {
  TypeExercise.REPS: 'REPS',
  TypeExercise.REPS_WEIGHT: 'REPS_WEIGHT',
  TypeExercise.TIME: 'TIME',
  TypeExercise.DISTANCE: 'DISTANCE',
};
