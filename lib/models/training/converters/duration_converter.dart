import 'package:json_annotation/json_annotation.dart';

/// A [JsonConverter] for handling the conversion between [Duration] and [int].
///
/// Supabase stores interval types as integers representing microseconds.
/// This converter facilitates the automatic conversion during JSON
/// serialization and deserialization.
class DurationConverter implements JsonConverter<Duration, int> {
  /// Creates an instance of [DurationConverter].
  const DurationConverter();

  @override
  Duration fromJson(int json) => Duration(microseconds: json);

  @override
  int toJson(Duration object) => object.inMicroseconds;
}
