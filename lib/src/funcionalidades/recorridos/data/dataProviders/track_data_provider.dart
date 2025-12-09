import 'package:flutter/foundation.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:nextmove_app/config/graphql_config.dart';
import 'package:nextmove_app/graphql/mutations.dart';
import 'package:nextmove_app/graphql/queries.dart';
import 'package:nextmove_app/main.dart';
import 'package:nextmove_app/src/core/errors/exceptions.dart'
    as custom_exceptions;
import 'package:nextmove_app/src/funcionalidades/recorridos/domain/recording_track.dart';
import 'package:nextmove_app/src/funcionalidades/recorridos/domain/recorded_track.dart';

class TrackDataProvider {
  GraphQLClient get client => GraphQLConfig.client.value;
  Future<void> saveRecordingTrack(RecordingTrack track) async {
    final MutationOptions options = MutationOptions(
      document: gql(GraphQLMutations.createTrackMutation),
      variables: {
        'user_email': userProvider.email,
        'distancia': track.totalDistanceMeters,
        'velocidad_media': track.averageSpeedKmH,
        'velocidad_maxima': track.maxSpeedKmH,
        'co2': track.co2SavedKG,
        'kcal': track.kcalBurned,
        'elevacion_positiva': track.elevationGainMeters,
        'elevacion_negativa': track.elevationLossMeters,
        'origen': {
          'latitude': track.origin?.latitude,
          'longitude': track.origin?.longitude,
        },
        'destino': {
          'latitude': track.destination?.latitude,
          'longitude': track.destination?.longitude,
        },
        'tiempo_inicio': track.startTime.toIso8601String(),
        'tiempo_fin': track.endTime.toIso8601String(),
        'fecha_recorrido': track.startTime.toLocal().toIso8601String(),
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

  Future<List<RecordedTrack>> getRecordedTracksByUser(String userEmail) async {
    final QueryOptions options = QueryOptions(
      document: gql(GraphQLQueries.getRecorridosByUserQuery),
      variables: {'userEmail': userEmail},
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
