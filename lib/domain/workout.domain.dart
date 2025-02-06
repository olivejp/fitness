import 'package:json_annotation/json_annotation.dart';

import 'abstract.domain.dart';

part 'workout.domain.g.dart';

@JsonSerializable()
class Workout extends AbstractDomain {
  Workout();

  factory Workout.fromJson(Map<String, dynamic> data) => _$WorkoutFromJson(data);

  @JsonKey(name: 'timer_type')
  String? timerType;

  String? description;

  @JsonKey(name: 'total_time')
  int? totalTime;

  @override
  Map<String, dynamic> toJson() => _$WorkoutToJson(this);
}
