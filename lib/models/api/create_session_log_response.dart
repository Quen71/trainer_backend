import 'package:json_annotation/json_annotation.dart';
import 'package:trainer_backend/models/history/session_log.dart';
import 'package:trainer_backend/models/training/session.dart';

part 'create_session_log_response.g.dart';

/// Represents the response object from the `create_session_log` remote procedure call.
///
/// This class encapsulates the two objects returned by the RPC: the newly created
/// [SessionLog] and a "preview" version of the original [Session] with its
/// `objectiveParameters` updated based on the performance of the first round.
@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class CreateSessionLogResponse {
  /// Creates an instance of [CreateSessionLogResponse].
  const CreateSessionLogResponse({
    required this.sessionLog,
    required this.updatedSessionPreview,
  });

  /// A factory for creating a [CreateSessionLogResponse] instance from a JSON object.
  factory CreateSessionLogResponse.fromJson(Map<String, dynamic> json) => _$CreateSessionLogResponseFromJson(json);

  /// The session log that was created and saved to the database.
  final SessionLog sessionLog;

  /// A preview of the original session with updated `objectiveParameters`.
  ///
  /// This object is not persisted to the database and is intended to be shown
  /// to the user as a suggestion for updating their training objectives.
  final Session updatedSessionPreview;

  /// Converts this [CreateSessionLogResponse] to a JSON object.
  Map<String, dynamic> toJson() => _$CreateSessionLogResponseToJson(this);
}
