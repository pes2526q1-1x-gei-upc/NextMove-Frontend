import 'package:flutter/foundation.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:nextmove_app/graphql/mutations.dart';
import '../../../../graphql/queries.dart';

class AuthService {
  final GraphQLClient _client;

  AuthService(this._client);

  Future<Map<String, dynamic>?> getCurrentUser() async {
    final QueryOptions options = QueryOptions(
      document: gql(GraphQLQueries.getMeQuery),
      fetchPolicy: FetchPolicy.networkOnly,
    );

    try {
      final QueryResult result = await _client.query(options);

      if (result.hasException) {
        if (kDebugMode) {
          print('Error al obtener usuario: ${result.exception.toString()}');
        }
        /*
        throw Exception(
          'Error al obtener usuario: ${result.exception.toString()}',
        );*/ return null;
      }

      if (result.data != null && result.data!['me'] != null) {
        return result.data!['me'] as Map<String, dynamic>;
      }
      if (kDebugMode) {
        print('WARNING: usuario vacío');
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error al obtener usuario: $e');
      }
      //throw Exception('Error en getCurrentUser: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> upsertUserFromFirebase({
    required String firebaseUid,
    required String? email,
    required String? name,
    bool? needsToRegister,
    bool regWithGoogle = false, // per defecte, false
  }) async {
    final MutationOptions options = MutationOptions(
      document: gql(GraphQLMutations.updateUserMutation),
      variables: {
        'id': firebaseUid,
        'email': email,
        'name': name,
        'needsToRegister': needsToRegister,
        'regWithGoogle': regWithGoogle,
      },
      fetchPolicy: FetchPolicy.networkOnly,
    );

    try {
      final result = await _client.mutate(options);

      if (result.hasException) {
        if (kDebugMode) {
          print('Error en upsert: ${result.exception}');
        }
        return null;
      }

      return result.data?['insert_users_one'];
    } catch (e) {
      if (kDebugMode) {
        print('Error en upsertUser: $e');
      }
      return null;
    }
  }
}
