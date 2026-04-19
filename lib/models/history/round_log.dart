import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:trainer_backend/models/history/exercise_log.dart';

part 'round_log.g.dart';

@JsonSerializable(
  fieldRename: FieldRename.snake,
  explicitToJson: true,
  genericArgumentFactories: true,
)
@CopyWith()
class RoundLog<T extends ExerciseLog> {
  /// Creates an instance of [RoundLog].
  const RoundLog({
    required this.id,
    required this.roundNumber,
    required this.exercises,
  });

  /// A factory for creating a [RoundLog] for insertion into the database.
  ///
  /// The [id] is initialized to 0 as it will be assigned by the database.
  factory RoundLog.forCreation({
    required int roundNumber,
    required List<T> exercises,
  }) => RoundLog<T>(id: 0, roundNumber: roundNumber, exercises: exercises);

  /// Creates a [RoundLog] from a JSON object.
  ///
  /// This factory supports generic deserialization for the list of exercises.
  factory RoundLog.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) => _$RoundLogFromJson(json, fromJsonT);

  /// Converts this [RoundLog] to a JSON object.
  ///
  /// This method supports generic serialization for the list of exercises.
  Map<String, dynamic> toJson(Object? Function(T value) toJsonT) =>
      _$RoundLogToJson(this, toJsonT);

  /// The unique identifier for the round log.
  final int id;

  /// The number of the round within the session (e.g., 1, 2, 3).
  final int roundNumber;

  /// A list of exercise logs recorded for this round.
  ///
  /// The generic type [T] must be a subclass of [ExerciseLog].
  final List<T> exercises;
}
