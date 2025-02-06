// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout.domain.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Workout _$WorkoutFromJson(Map<String, dynamic> json) => Workout()
  ..id = (json['id'] as num?)?.toInt()
  ..created_at = json['created_at']
  ..timerType = json['timer_type'] as String?
  ..description = json['description'] as String?
  ..totalTime = (json['total_time'] as num?)?.toInt();

Map<String, dynamic> _$WorkoutToJson(Workout instance) => <String, dynamic>{
      'id': instance.id,
      'created_at': instance.created_at,
      'timer_type': instance.timerType,
      'description': instance.description,
      'total_time': instance.totalTime,
    };
