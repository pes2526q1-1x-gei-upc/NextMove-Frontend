import 'package:flutter/foundation.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:nextmove_app/config/graphql_config.dart';
import 'package:nextmove_app/src/core/errors/exceptions.dart'
    as custom_exceptions;
import 'package:nextmove_app/src/funcionalidades/recorridos/domain/recorded_route.dart';
import 'package:nextmove_app/graphql/queries.dart';

class RecordedTrackDataProvider {
  //i want to get the info of pasts routes of the back
  GraphQLClient get client => GraphQLConfig.client.value;
  Future<List<RecordedTrack>> getRecordedTracks(String userEmail) async {
    final QueryOptions options = QueryOptions(
      document: gql(GraphQLQueries.getRecorridosByUserQuery),
      variables: {
        'userEmail': userEmail,
      },
    );

    final QueryResult result = await client.query(options);

    if (result.hasException) {
      if (kDebugMode) {
        print('Error GraphQL Raw: ${result.exception.toString()}');
      }

      if (result.exception!.graphqlErrors.isNotEmpty) {
        final msg = result.exception!.graphqlErrors.first.message;
        if (kDebugMode) {
          print('Mensaje del servidor: "$msg"');
        }
      }

      throw custom_exceptions.ServerException(
        'Error al obtener las rutas grabadas: ${result.exception}',
      );
    }

    final List<dynamic> recordedTracks = result.data?['recorridosByUser'] ?? [];
    return recordedTracks
        .map((trackJson) => RecordedTrack.fromJson(trackJson))
        .toList();
  }
}


