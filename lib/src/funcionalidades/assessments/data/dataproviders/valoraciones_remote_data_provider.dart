import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:graphql_flutter/graphql_flutter.dart' hide ServerException;
import 'package:nextmove_app/config/graphql_config.dart';
import 'package:nextmove_app/src/core/errors/exceptions.dart';
import '../../../../../../graphql/queries.dart';

class SocialRemoteDataProvider {
  GraphQLClient get client => GraphQLConfig.client.value;

  Future<String?> get _authHeader async {
    final fireBaseUser = FirebaseAuth.instance.currentUser;
    String? authHeader = '';  
    if (fireBaseUser != null) {
      final token = await fireBaseUser.getIdToken();
      authHeader = 'Bearer $token';
    }
    return authHeader;
  }

  Future<void> createAssessment(String station_id, int score, String description) async {
    String? authHeader = await _authHeader;
    final MutationOptions options = MutationOptions(
      document: gql(GraphQLQueries.createAssessmentQuery),
      variables:{
        'station_id': station_id,
        'score': score,
        'description': description,
      },
      context: Context().withEntry(HttpLinkHeaders(headers: {
        'Authorization': ?authHeader,
      })),
    );
    debugPrint("Creamos valoración...");
    final QueryResult result = await client.mutate(options);

    if (result.hasException) {
      debugPrint('Error al crear valoración: ${result.exception.toString()}');
      throw ServerException('Error al crear valoración: ${result.exception.toString()}');
    }
  }

}