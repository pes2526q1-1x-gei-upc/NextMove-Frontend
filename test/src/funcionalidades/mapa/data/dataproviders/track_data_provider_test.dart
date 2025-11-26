import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/data/dataproviders/track_data_provider.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/domain/recorded_track.dart';
import 'package:nextmove_app/src/core/errors/exceptions.dart' as custom_exceptions;
import 'track_data_provider_test.mocks.dart';

// Generate mocks
// Run: flutter pub run build_runner build
@GenerateMocks([GraphQLClient])
void main() {
  late TrackDataProvider dataProvider;
  late MockGraphQLClient mockClient;

  setUp(() {
    mockClient = MockGraphQLClient();
    dataProvider = TrackDataProvider(mockClient);
  });

  group('saveRecordedTrack', () {
    test('succeeds on valid response', () async {
      // Arrange
      const userEmail = 'test@example.com';
      final startPoint = TrackPoint(
        location: const LatLng(0, 0),
        altitude: 0,
        timestamp: DateTime.now(),
      );
      final endPoint = TrackPoint(
        location: const LatLng(1, 1),
        altitude: 0,
        timestamp: DateTime.now().add(const Duration(minutes: 1)),
      );
      final mockTrack = RecordedTrack();
      mockTrack.points.add(startPoint);
      mockTrack.points.add(endPoint);

      when(mockClient.mutate(any)).thenAnswer((invocation) async {
        final options = invocation.positionalArguments[0] as MutationOptions;
        return QueryResult(
          options: options,
          source: QueryResultSource.network,
          data: {'createTrack': 'success'},
          exception: null,
        );
      });

      // Act
      await dataProvider.saveRecordedTrack(mockTrack, userEmail);

      // Assert
      verify(mockClient.mutate(any)).called(1);
    });

    test('throws ServerException on GraphQL error', () async {
      // Arrange
      const userEmail = 'test@example.com';
      final startPoint = TrackPoint(
        location: const LatLng(0, 0),
        altitude: 0,
        timestamp: DateTime.now(),
      );
      final endPoint = TrackPoint(
        location: const LatLng(1, 1),
        altitude: 0,
        timestamp: DateTime.now().add(const Duration(minutes: 1)),
      );
      final mockTrack = RecordedTrack();
      mockTrack.points.add(startPoint);
      mockTrack.points.add(endPoint);

      when(mockClient.mutate(any)).thenAnswer((invocation) async {
        final options = invocation.positionalArguments[0] as MutationOptions;
        return QueryResult(
          options: options,
          source: QueryResultSource.network,
          exception: OperationException(
            graphqlErrors: [const GraphQLError(message: 'Error')],
          ),
        );
      });

      // Act & Assert
      expect(
        () => dataProvider.saveRecordedTrack(mockTrack, userEmail),
        throwsA(isA<custom_exceptions.ServerException>()),
      );
    });
  });
}