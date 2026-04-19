import 'package:json_annotation/json_annotation.dart';

/// JSON converter for Map<String, int> that handles both string and int values.
///
/// The database may return values as strings (e.g., "5") or integers (e.g., 5),
/// so this converter ensures they are always converted to integers.6
class SessionsCountMapConverter
    implements JsonConverter<Map<String, int>, Map<String, dynamic>> {
  /// Creates a new [SessionsCountMapConverter].
  const SessionsCountMapConverter();

  @override
  // ignore: always_specify_types
  Map<String, int> fromJson(Map<String, dynamic> json) => json.map((
    String key,
    value,
  ) {
    if (value is int) {
      return MapEntry<String, int>(key, value);
    } else if (value is String) {
      return MapEntry<String, int>(key, int.parse(value));
    } else if (value is num) {
      return MapEntry<String, int>(key, value.toInt());
    } else {
      throw FormatException(
        'Expected int, String, or num for sessions_count_by_program value, got ${value.runtimeType}',
      );
    }
  });

  @override
  Map<String, dynamic> toJson(Map<String, int> object) => object.map(
    (String key, int value) => MapEntry<String, dynamic>(key, value),
  );
}
