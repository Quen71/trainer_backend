import 'package:supabase_flutter/supabase_flutter.dart' hide Session;
import 'package:trainer_backend/clients/trainer.api.dart';
import 'package:trainer_backend/exceptions/exceptions.export.dart';
import 'package:trainer_backend/models/training/program.dart';
import 'package:trainer_backend/models/training/session.dart';
import 'package:trainer_backend/utils/rpc.guard.dart';

/// A service class for managing training programs.
///
/// This class provides static methods to handle the full lifecycle of a
/// [Program], including creation, retrieval, updates, and deletion.
/// It also manages the sessions within a program.
///
/// All methods normalize Supabase errors into [TrainerBackendException]
/// subclasses via [RpcGuard]. Subscription-related RPC errors are surfaced as
/// [TrainerBackendSubscriptionException]; generic Postgres failures become
/// [TrainerBackendRpcException]; network failures become
/// [TrainerBackendNetworkException]; and any remaining errors become
/// [TrainerBackendUnknownException].
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
  ///
  /// Throws a [TrainerBackendSubscriptionException] if a subscription limit is
  /// exceeded or the subscription is inactive/expired.
  /// Throws a [TrainerBackendRpcException] if the RPC call fails.
  /// Throws a [TrainerBackendNetworkException] on network failure.
  /// Throws a [TrainerBackendUnknownException] for any other error.
  static Future<Program> createFullProgram(Program program) => RpcGuard.run(
    operation: 'createFullProgram',
    body: () async {
      final dynamic data = await _client.rpc(
        'create_full_program',
        params: <String, dynamic>{'full_program_data': program.toJson()},
      );
      return Program.fromJson(data as PostgrestMap);
    },
  );

  /// Fetches a paginated list of programs for the current user.
  ///
  /// - [page]: The page number to retrieve.
  /// - [pageSize]: The number of programs per page. Defaults to 5.
  ///
  /// Returns a [Future] with a list of [Program] objects.
  /// Returns an empty list if no programs are found.
  ///
  /// Throws a [TrainerBackendRpcException] if the RPC call fails.
  /// Throws a [TrainerBackendNetworkException] on network failure.
  /// Throws a [TrainerBackendUnknownException] for any other error.
  static Future<List<Program>> fetchUserPrograms({required int page, int pageSize = 5}) => RpcGuard.run(
    operation: 'fetchUserPrograms',
    body: () async {
      final dynamic response = await _client.rpc(
        'get_user_programs',
        params: <String, dynamic>{'page_number': page, 'page_size': pageSize},
      );

      if (response == null) return <Program>[];

      return (response as List<dynamic>).map((dynamic p) => Program.fromJson(p as Map<String, dynamic>)).toList();
    },
  );

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
  /// Returns a [Future] with the updated [Program] object.
  ///
  /// Throws a [TrainerBackendRpcException] if the RPC call fails or if the
  /// program does not belong to the current user.
  /// Throws a [TrainerBackendNetworkException] on network failure.
  /// Throws a [TrainerBackendUnknownException] for any other error.
  static Future<Program> updateFullProgram(Program program) => RpcGuard.run(
    operation: 'updateFullProgram',
    body: () async {
      final dynamic data = await _client.rpc(
        'update_full_program',
        params: <String, dynamic>{'full_program_data': program.toJson()},
      );
      return Program.fromJson(data as Map<String, dynamic>);
    },
  );

  /// Adds a new session to an existing program.
  ///
  /// - [programId]: The ID of the program to which the session will be added.
  /// - [session]: The [Session] object to add.
  ///
  /// Returns a [Future] with the updated [Program] object containing the new session.
  ///
  /// Throws a [TrainerBackendSubscriptionException] if a subscription limit is
  /// exceeded or the subscription is inactive/expired.
  /// Throws a [TrainerBackendRpcException] if the RPC call fails.
  /// Throws a [TrainerBackendNetworkException] on network failure.
  /// Throws a [TrainerBackendUnknownException] for any other error.
  static Future<Program> addSessionToProgram({required int programId, required Session session}) => RpcGuard.run(
    operation: 'addSessionToProgram',
    body: () async {
      final dynamic data = await _client.rpc(
        'add_session_to_program',
        params: <String, dynamic>{'p_program_id': programId, 'session_data': session.toJson()},
      );
      return Program.fromJson(data as Map<String, dynamic>);
    },
  );

  /// Deletes a session from its program.
  ///
  /// - [sessionId]: The ID of the session to delete.
  ///
  /// Returns a [Future] with the updated [Program] object after session deletion.
  ///
  /// Throws a [TrainerBackendRpcException] if the RPC call fails.
  /// Throws a [TrainerBackendNetworkException] on network failure.
  /// Throws a [TrainerBackendUnknownException] for any other error.
  static Future<Program> deleteSession(int sessionId) => RpcGuard.run(
    operation: 'deleteSession',
    body: () async {
      final dynamic data = await _client.rpc(
        'delete_session_from_program',
        params: <String, dynamic>{'p_session_id': sessionId},
      );
      return Program.fromJson(data as Map<String, dynamic>);
    },
  );

  /// Deletes a program and all its associated data.
  ///
  /// - [programId]: The ID of the program to delete.
  ///
  /// Returns a [Future] with the ID of the deleted program.
  ///
  /// Throws a [TrainerBackendRpcException] if the RPC call fails.
  /// Throws a [TrainerBackendNetworkException] on network failure.
  /// Throws a [TrainerBackendUnknownException] for any other error.
  static Future<int> deleteProgram(int programId) => RpcGuard.run(
    operation: 'deleteProgram',
    body: () async {
      final dynamic deletedId = await _client.rpc(
        'delete_program',
        params: <String, dynamic>{'p_program_id': programId},
      );
      return deletedId as int;
    },
  );

  /// Adds a program to the user's favorites.
  ///
  /// - [programId]: The ID of the program to add to favorites.
  ///
  /// Returns a [Future] with the updated [Program] object.
  ///
  /// Throws a [TrainerBackendRpcException] if the RPC call fails.
  /// Throws a [TrainerBackendNetworkException] on network failure.
  /// Throws a [TrainerBackendUnknownException] for any other error.
  static Future<Program> addProgramToFavorites(int programId) => RpcGuard.run(
    operation: 'addProgramToFavorites',
    body: () async {
      final dynamic data = await _client.rpc(
        'add_program_to_favorites',
        params: <String, dynamic>{'p_program_id': programId},
      );
      return Program.fromJson(data as Map<String, dynamic>);
    },
  );

  /// Removes a program from the user's favorites.
  ///
  /// - [programId]: The ID of the program to remove from favorites.
  ///
  /// Returns a [Future] with the updated [Program] object.
  ///
  /// Throws a [TrainerBackendRpcException] if the RPC call fails.
  /// Throws a [TrainerBackendNetworkException] on network failure.
  /// Throws a [TrainerBackendUnknownException] for any other error.
  static Future<Program> removeProgramFromFavorites(int programId) => RpcGuard.run(
    operation: 'removeProgramFromFavorites',
    body: () async {
      final dynamic data = await _client.rpc(
        'remove_program_from_favorites',
        params: <String, dynamic>{'p_program_id': programId},
      );
      return Program.fromJson(data as Map<String, dynamic>);
    },
  );
}
