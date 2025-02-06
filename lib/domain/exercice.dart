import 'package:fitness_domain/enum/type_exercise.enum.dart';
import 'package:json_annotation/json_annotation.dart';

part 'exercice.g.dart';

@JsonSerializable()
class Exercice {
  Exercice() : super();

  TypeExercise? type;
  String? video_url;
  String? youtube_url;
  String description = '';

  @override
  Map<String, dynamic> toJson() => _$ExerciseToJson(this);

  @override
  List<String> searchFields() {
    return <String>['name', 'description'];
  }

  factory Exercice.fromJson(Map<String, dynamic> data) => _$ExerciseFromJson(data);
}
