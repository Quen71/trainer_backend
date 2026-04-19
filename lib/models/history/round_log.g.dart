// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'round_log.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$RoundLogCWProxy<T extends ExerciseLog> {
  RoundLog<T> id(int id);

  RoundLog<T> roundNumber(int roundNumber);

  RoundLog<T> exercises(List<T> exercises);

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `RoundLog<T>(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// RoundLog<T>(...).copyWith(id: 12, name: "My name")
  /// ```
  RoundLog<T> call({int id, int roundNumber, List<T> exercises});
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfRoundLog.copyWith(...)` or call `instanceOfRoundLog.copyWith.fieldName(value)` for a single field.
class _$RoundLogCWProxyImpl<T extends ExerciseLog>
    implements _$RoundLogCWProxy<T> {
  const _$RoundLogCWProxyImpl(this._value);

  final RoundLog<T> _value;

  @override
  RoundLog<T> id(int id) => call(id: id);

  @override
  RoundLog<T> roundNumber(int roundNumber) => call(roundNumber: roundNumber);

  @override
  RoundLog<T> exercises(List<T> exercises) => call(exercises: exercises);

  @override
  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `RoundLog<T>(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// RoundLog<T>(...).copyWith(id: 12, name: "My name")
  /// ```
  RoundLog<T> call({
    Object? id = const $CopyWithPlaceholder(),
    Object? roundNumber = const $CopyWithPlaceholder(),
    Object? exercises = const $CopyWithPlaceholder(),
  }) {
    return RoundLog<T>(
      id: id == const $CopyWithPlaceholder() || id == null
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as int,
      roundNumber:
          roundNumber == const $CopyWithPlaceholder() || roundNumber == null
          ? _value.roundNumber
          // ignore: cast_nullable_to_non_nullable
          : roundNumber as int,
      exercises: exercises == const $CopyWithPlaceholder() || exercises == null
          ? _value.exercises
          // ignore: cast_nullable_to_non_nullable
          : exercises as List<T>,
    );
  }
}

extension $RoundLogCopyWith<T extends ExerciseLog> on RoundLog<T> {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfRoundLog.copyWith(...)` or `instanceOfRoundLog.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$RoundLogCWProxy<T> get copyWith => _$RoundLogCWProxyImpl<T>(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RoundLog<T> _$RoundLogFromJson<T extends ExerciseLog>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) => RoundLog<T>(
  id: (json['id'] as num).toInt(),
  roundNumber: (json['round_number'] as num).toInt(),
  exercises: (json['exercises'] as List<dynamic>).map(fromJsonT).toList(),
);

Map<String, dynamic> _$RoundLogToJson<T extends ExerciseLog>(
  RoundLog<T> instance,
  Object? Function(T value) toJsonT,
) => <String, dynamic>{
  'id': instance.id,
  'round_number': instance.roundNumber,
  'exercises': instance.exercises.map(toJsonT).toList(),
};
