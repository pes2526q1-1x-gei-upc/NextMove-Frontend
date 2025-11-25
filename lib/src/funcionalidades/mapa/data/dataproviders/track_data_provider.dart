import 'package:flutter/foundation.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:nextmove_app/config/graphql_config.dart';
import 'package:nextmove_app/main.dart';
import 'package:nextmove_app/src/core/errors/exceptions.dart'
    as custom_exceptions;
import 'package:nextmove_app/src/funcionalidades/mapa/domain/recorded_track.dart';
import 'package:nextmove_app/graphql/queries.dart';

class TrackDataProvider {
  GraphQLClient get client => GraphQLConfig.client.value;
  Future<void> saveRecordedTrack(RecordedTrack track) async {
    final MutationOptions options = MutationOptions(
      document: gql(GraphQLQueries.createTrackMutation),
      variables: {
        'userEmail': userProvider.email,
        'distance': track.totalDistanceMeters,
        'averageSpeed': track.averageSpeedKmH,
        'co2': track.co2SavedKG,
        'kcal': track.kcalBurned,
        'originLat': track.startPoint.location.latitude,
        'originLon': track.startPoint.location.longitude,
        'destinationLat': track.endPoint.location.latitude,
        'destinationLon': track.endPoint.location.longitude,
        'timestamp': track.startTime.toIso8601String(),
      },
    );

    final QueryResult result = await client.mutate(options);

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
        'Error al crear perfil: ${result.exception}',
      );
    }
  }
}
