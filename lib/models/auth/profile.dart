import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:trainer_backend/models/auth/enums/user_role.dart';

part 'profile.g.dart';

/// Represents a user's profile in the application.
///
/// This model holds all the information related to a user's account,
/// such as username, full name, role, and timestamps.
@JsonSerializable()
@CopyWith()
class Profile {
  /// Creates an instance of [Profile].
  const Profile({
    required this.id,
    required this.username,
    required this.createdAt,
    required this.updatedAt,
    this.fullName,
    this.role = UserRole.standard,
  });

  /// Creates a [Profile] from a JSON object.
  factory Profile.fromJson(Map<String, dynamic> json) => _$ProfileFromJson(json);

  /// The unique identifier for the user, typically a UUID from Supabase Auth.
  final String id;

  /// The user's unique username.
  final String username;

  /// The user's full name. Can be null.
  @JsonKey(name: 'full_name')
  final String? fullName;

  /// The role of the user within the application.
  /// Defaults to [UserRole.standard].
  final UserRole role;

  /// The timestamp when the user profile was created.
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  /// The timestamp when the user profile was last updated.
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  /// Converts this [Profile] to a JSON object.
  Map<String, dynamic> toJson() => _$ProfileToJson(this);
}
