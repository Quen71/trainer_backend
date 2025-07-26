import 'package:json_annotation/json_annotation.dart';
import 'package:trainer_backend/models/training/session.dart';

part 'session_api_response.g.dart';

/// Represents the API response for session-related operations.
///
/// This class is used to structure the data returned from the backend after
/// operations like updating a session. It contains the updated [Session]
/// and the ID of the parent program.
@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class SessionApiResponse {
  /// Creates an instance of [SessionApiResponse].
  const SessionApiResponse({
    required this.programId,
    required this.session,
  });

  /// Creates a [SessionApiResponse] from a JSON object.
  factory SessionApiResponse.fromJson(Map<String, dynamic> json) => _$SessionApiResponseFromJson(json);

  /// The ID of the program that this session belongs to.
  final int programId;

  /// The session object itself.
  ///
  /// This contains the full session data, including exercises and parameters.
  final Session session;

  /// Converts this [SessionApiResponse] to a JSON object.
  Map<String, dynamic> toJson() => _$SessionApiResponseToJson(this);
}
