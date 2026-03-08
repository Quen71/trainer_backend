import 'package:supabase_flutter/supabase_flutter.dart' hide Session;
import 'package:trainer_backend/clients/trainer.api.dart';
import 'package:trainer_backend/models/training/program.dart';
import 'package:trainer_backend/models/training/session.dart';

/// A service class for managing training programs.
///
/// This class provides static methods to handle the full lifecycle of a
/// [Program], including creation, retrieval, updates, and deletion.
/// It also manages the sessions within a program.
class ProgramsService {
  /// The constructor is private to prevent instantiation of the class.
  const ProgramsService._();

  /// A private getter for the Supabase client instance.
  static SupabaseClient get _client => TrainerAPI.client;

  /// Creates a new program with all its sessions and exercises.
  ///
  /// The [program] object should contain all the necessary details,
  /// including a non-empty list of sessions, and each session must include
  /// at least one exercise.
  ///
  /// Returns a [Future] with the created [Program] object, including IDs.
  /// Throws a [PostgrestException] if the RPC call fails. The RPC enforces
  /// the following constraints and will raise an error if violated:
  /// - A program must have at least one session.
  /// - Each session must have at least one exercise.
  ///
  /// **Subscription Limit Exceptions:**
  /// The RPC may raise exceptions with the following error codes if subscription limits are exceeded:
  /// - `LIMIT_EXCEEDED:MAX_PROGRAMS:X/Y` - Maximum number of programs reached
  /// - `LIMIT_EXCEEDED:MAX_SESSIONS:X/Y` - Maximum number of sessions per program exceeded
  /// - `LIMIT_EXCEEDED:MAX_EXERCISES:X/Y` - Maximum number of exercises exceeded
  /// - `SUBSCRIPTION_INACTIVE` - User's subscription is not active
  /// - `SUBSCRIPTION_EXPIRED` - User's subscription has expired
  static Future<Program> createFullProgram(Program program) async {
    final Map<String, dynamic> programJson = program.toJson();

    final dynamic newProgramData = await _client.rpc(
      'create_full_program',
      params: <String, dynamic>{'full_program_data': programJson},
    );

    return Program.fromJson(newProgramData as PostgrestMap);
  }

  /// Fetches a paginated list of programs for the current user.
  ///
  /// - [page]: The page number to retrieve.
  /// - [pageSize]: The number of programs per page. Defaults to 5.
  ///
  /// Returns a [Future] with a list of [Program] objects.
  /// Returns an empty list if no programs are found.
  /// Throws a [PostgrestException] if the RPC call fails.
  static Future<List<Program>> fetchUserPrograms({
    required int page,
    int pageSize = 5,
  }) async {
    final dynamic response = await _client.rpc(
      'get_user_programs',
      params: <String, dynamic>{
        'page_number': page,
        'page_size': pageSize,
      },
    );

    if (response == null) {
      return <Program>[];
    }

    final List<dynamic> programsJson = response as List<dynamic>;

    return programsJson.map((dynamic p) => Program.fromJson(p as Map<String, dynamic>)).toList();
  }

  /// Updates an existing program's metadata and the order of its sessions.
  ///
  /// This method updates the program's `name` and `description`. It also
  /// iterates through the sessions provided in the [program] object and updates
  /// their `orderInProgram` in the database.
  ///
  /// **Important:** This function does not update the content of the sessions
  /// (e.g., name, type, exercises). It only handles the reordering of sessions.
  ///
  /// The [program] object should contain the complete, updated data for the
  /// program and all its sessions.
  ///
  /// Returns a [Future] with the updated [Program] object, reflecting the
  /// changes.
  /// Throws a [PostgrestException] if the RPC call fails or if the program
  /// does not belong to the current user.
  static Future<Program> updateFullProgram(Program program) async {
    final Map<String, dynamic> programJson = program.toJson();

    final dynamic updatedProgramData = await _client.rpc(
      'update_full_program',
      params: <String, dynamic>{'full_program_data': programJson},
    );

    return Program.fromJson(updatedProgramData as Map<String, dynamic>);
  }

  /// Adds a new session to an existing program.
  ///
  /// - [programId]: The ID of the program to which the session will be added.
  /// - [session]: The [Session] object to add.
  ///
  /// Returns a [Future] with the updated [Program] object containing the new session.
  /// Throws a [PostgrestException] if the RPC call fails.
  ///
  /// **Subscription Limit Exceptions:**
  /// The RPC may raise exceptions with the following error codes if subscription limits are exceeded:
  /// - `LIMIT_EXCEEDED:MAX_SESSIONS:X/Y` - Maximum number of sessions per program exceeded
  /// - `LIMIT_EXCEEDED:MAX_EXERCISES:X/Y` - Maximum number of exercises exceeded
  /// - `SUBSCRIPTION_INACTIVE` - User's subscription is not active
  /// - `SUBSCRIPTION_EXPIRED` - User's subscription has expired
  static Future<Program> addSessionToProgram({
    required int programId,
    required Session session,
  }) async {
    final Map<String, dynamic> sessionJson = session.toJson();

    final dynamic updatedProgramData = await _client.rpc(
      'add_session_to_program',
      params: <String, dynamic>{
        'p_program_id': programId,
        'session_data': sessionJson,
      },
    );

    return Program.fromJson(updatedProgramData as Map<String, dynamic>);
  }

  /// Deletes a session from its program.
  ///
  /// - [sessionId]: The ID of the session to delete.
  ///
  /// Returns a [Future] with the updated [Program] object after session deletion.
  /// Throws a [PostgrestException] if the RPC call fails.
  static Future<Program> deleteSession(int sessionId) async {
    final dynamic updatedProgramData = await _client.rpc(
      'delete_session_from_program',
      params: <String, dynamic>{'p_session_id': sessionId},
    );

    return Program.fromJson(updatedProgramData as Map<String, dynamic>);
  }

  /// Deletes a program and all its associated data.
  ///
  /// - [programId]: The ID of the program to delete.
  ///
  /// Returns a [Future] with the ID of the deleted program.
  /// Throws a [PostgrestException] if the RPC call fails.
  static Future<int> deleteProgram(int programId) async {
    final dynamic deletedId = await _client.rpc(
      'delete_program',
      params: <String, dynamic>{'p_program_id': programId},
    );

    return deletedId as int;
  }

  /// Adds a program to the user's favorites.
  ///
  /// - [programId]: The ID of the program to add to favorites.
  ///
  /// Returns a [Future] with the updated [Program] object.
  /// Throws a [PostgrestException] if the RPC call fails.
  static Future<Program> addProgramToFavorites(int programId) async {
    final dynamic updatedProgramData = await _client.rpc(
      'add_program_to_favorites',
      params: <String, dynamic>{'p_program_id': programId},
    );

    return Program.fromJson(updatedProgramData as Map<String, dynamic>);
  }

  /// Removes a program from the user's favorites.
  ///
  /// - [programId]: The ID of the program to remove from favorites.
  ///
  /// Returns a [Future] with the updated [Program] object.
  /// Throws a [PostgrestException] if the RPC call fails.
  static Future<Program> removeProgramFromFavorites(int programId) async {
    final dynamic updatedProgramData = await _client.rpc(
      'remove_program_from_favorites',
      params: <String, dynamic>{'p_program_id': programId},
    );

    return Program.fromJson(updatedProgramData as Map<String, dynamic>);
  }
}
