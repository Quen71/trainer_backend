import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:trainer_backend/models/training/session.dart';

part 'program.g.dart';

/// Represents a training program, which is a collection of training sessions.
@JsonSerializable(fieldRename: FieldRename.snake)
@CopyWith()
class Program {
  /// Creates an instance of [Program].
  const Program({
    required this.id,
    required this.userId,
    required this.name,
    this.description,
    this.sessions = const <Session>[],
    required this.createdAt,
    required this.updatedAt,
  });

  /// A factory for creating a [Program] for insertion into the database.
  ///
  /// The [id] and [userId] are initialized with placeholder values
  /// as they will be assigned by the backend.
  factory Program.forCreation({
    required String name,
    String? description,
    required List<Session> sessions,
  }) =>
      Program(
        id: 0,
        userId: '',
        name: name,
        description: description,
        sessions: sessions,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

  /// Creates a [Program] from a JSON object.
  factory Program.fromJson(Map<String, dynamic> json) => _$ProgramFromJson(json);

  /// The unique identifier for the program.
  final int id;

  /// The ID of the user who owns this program.
  final String userId;

  /// The name of the program.
  final String name;

  /// An optional description of the program.
  final String? description;

  /// The list of sessions that make up this program.
  final List<Session> sessions;

  /// The timestamp when the program was created.
  final DateTime createdAt;

  /// The timestamp when the program was last updated.
  final DateTime updatedAt;

  /// Converts this [Program] to a JSON object.
  Map<String, dynamic> toJson() => _$ProgramToJson(this);
}
