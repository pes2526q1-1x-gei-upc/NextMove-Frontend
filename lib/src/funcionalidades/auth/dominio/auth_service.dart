// src/funcionalidades/auth/dominio/auth_service.dart
import 'package:graphql_flutter/graphql_flutter.dart';
import '../../../../config/graphql_config.dart';
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
        throw Exception('Error al obtener usuario: ${result.exception.toString()}');
      }

      if (result.data != null && result.data!['me'] != null) {
        return result.data!['me'] as Map<String, dynamic>;
      }

      return null;
    } catch (e) {
      throw Exception('Error en getCurrentUser: $e');
    }
  }
}