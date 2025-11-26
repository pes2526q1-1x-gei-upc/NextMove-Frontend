import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:graphql_flutter/graphql_flutter.dart' hide ServerException;
import 'package:nextmove_app/config/graphql_config.dart';
import 'package:nextmove_app/graphql/queries.dart';
import 'package:nextmove_app/src/core/errors/exceptions.dart';


class AssessmentRemoteDataProvider {
  GraphQLClient get client => GraphQLConfig.client.value;

  Future<String?> get _authHeader async {
    final fireBaseUser = FirebaseAuth.instance.currentUser;
    if (fireBaseUser != null) {
      final token = await fireBaseUser.getIdToken();
      return 'Bearer $token';
    }
    return null;
  }

  Future<void> createAssessment(String stationId, int score, String description) async {
    try {
      final authHeader = await _authHeader;

      final MutationOptions options = MutationOptions(
        document: gql(GraphQLQueries.createAssessmentQuery), 
        variables: {
          'station_id': stationId,
          'score': score,
          'comments': description,
        },
        context: Context().withEntry(
          HttpLinkHeaders(headers: {
            'Authorization': authHeader ?? '',
          }),
        ),
      );

      debugPrint("Enviando valoración al servidor...");
      final QueryResult result = await client.mutate(options);

      if (result.hasException) {
        debugPrint('Excepción devuelta por GraphQL: ${result.exception.toString()}');
        throw ServerException('Error al crear valoración: ${result.exception.toString()}');
      }
      
      debugPrint("Valoración creada con éxito");

    } catch (e, stackTrace) {
      debugPrint("Error antes de enviar: $e");
      debugPrint("Stack trace: $stackTrace");
      throw ServerException('Error interno al preparar la petición: $e');
    }
  }
}