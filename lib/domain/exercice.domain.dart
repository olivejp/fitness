import 'package:fitness_domain/enum/type_exercise.enum.dart';
import 'package:json_annotation/json_annotation.dart';

import 'abstract.domain.dart';

part 'exercice.domain.g.dart';

@JsonSerializable()
class Exercice extends AbstractDomain {
  Exercice() : super();

  TypeExercise? type;

  @JsonKey(name: 'video_url')
  String? videoUrl;

  @JsonKey(name: 'youtube_url')
  String? youtubeUrl;

  String description = '';

  @override
  Map<String, dynamic> toJson() => _$ExerciceToJson(this);

  factory Exercice.fromJson(Map<String, dynamic> data) => _$ExerciceFromJson(data);
}
