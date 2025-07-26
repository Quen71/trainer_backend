// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'round_log.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$RoundLogCWProxy<T extends ExerciseLog> {
  RoundLog<T> id(int id);

  RoundLog<T> roundNumber(int roundNumber);

  RoundLog<T> exercises(List<T> exercises);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RoundLog<T>(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RoundLog<T>(...).copyWith(id: 12, name: "My name")
  /// ````
  RoundLog<T> call({
    int id,
    int roundNumber,
    List<T> exercises,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfRoundLog.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfRoundLog.copyWith.fieldName(...)`
class _$RoundLogCWProxyImpl<T extends ExerciseLog>
    implements _$RoundLogCWProxy<T> {
  const _$RoundLogCWProxyImpl(this._value);

  final RoundLog<T> _value;

  @override
  RoundLog<T> id(int id) => this(id: id);

  @override
  RoundLog<T> roundNumber(int roundNumber) => this(roundNumber: roundNumber);

  @override
  RoundLog<T> exercises(List<T> exercises) => this(exercises: exercises);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RoundLog<T>(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RoundLog<T>(...).copyWith(id: 12, name: "My name")
  /// ````
  RoundLog<T> call({
    Object? id = const $CopyWithPlaceholder(),
    Object? roundNumber = const $CopyWithPlaceholder(),
    Object? exercises = const $CopyWithPlaceholder(),
  }) {
    return RoundLog<T>(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as int,
      roundNumber: roundNumber == const $CopyWithPlaceholder()
          ? _value.roundNumber
          // ignore: cast_nullable_to_non_nullable
          : roundNumber as int,
      exercises: exercises == const $CopyWithPlaceholder()
          ? _value.exercises
          // ignore: cast_nullable_to_non_nullable
          : exercises as List<T>,
    );
  }
}

extension $RoundLogCopyWith<T extends ExerciseLog> on RoundLog<T> {
  /// Returns a callable class that can be used as follows: `instanceOfRoundLog.copyWith(...)` or like so:`instanceOfRoundLog.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$RoundLogCWProxy<T> get copyWith => _$RoundLogCWProxyImpl<T>(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RoundLog<T> _$RoundLogFromJson<T extends ExerciseLog>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) =>
    RoundLog<T>(
      id: (json['id'] as num).toInt(),
      roundNumber: (json['round_number'] as num).toInt(),
      exercises: (json['exercises'] as List<dynamic>).map(fromJsonT).toList(),
    );

Map<String, dynamic> _$RoundLogToJson<T extends ExerciseLog>(
  RoundLog<T> instance,
  Object? Function(T value) toJsonT,
) =>
    <String, dynamic>{
      'id': instance.id,
      'round_number': instance.roundNumber,
      'exercises': instance.exercises.map(toJsonT).toList(),
    };
