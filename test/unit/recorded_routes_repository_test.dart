import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nextmove_app/src/core/errors/exceptions.dart';
import 'package:nextmove_app/src/core/errors/failure.dart';
import 'package:nextmove_app/src/funcionalidades/recorridos/data/dataProviders/recorded_route_data_provider.dart';
import 'package:nextmove_app/src/funcionalidades/recorridos/data/repositories/recorded_routes_repository.dart';
import 'package:nextmove_app/src/funcionalidades/recorridos/domain/recorded_route.dart';

class MockRecordedRouteDataProvider extends Mock
    implements RecordedRouteDataProvider {}

void main() {
  late MockRecordedRouteDataProvider mockProvider;
  late RecordedRoutesRepository repository;

  setUp(() {
    mockProvider = MockRecordedRouteDataProvider();
    repository =
        RecordedRoutesRepository(recordedRouteDataProvider: mockProvider);
  });

  tearDown(() {
    reset(mockProvider);
  });

  test('getRecordedRoutesByUser returns Right list on success', () async {
    final routes = [
      RecordedRoute(
        id: 'r1',
        userEmail: 'user@test.com',
        distance: 1000,
        timestamp: DateTime.parse('2024-01-01T10:00:00Z'),
      ),
    ];

    when(() => mockProvider.getRecordedRoutes(any()))
        .thenAnswer((_) async => routes);

    final result = await repository.getRecordedRoutesByUser('user@test.com');

    expect(result, isA<Right<Failure, List<RecordedRoute>>>());
    expect(result.getOrElse(() => []), routes);
  });

  test('returns empty list when ServerException indicates no routes', () async {
    when(() => mockProvider.getRecordedRoutes(any())).thenThrow(
      const ServerException('no hay recorridos'),
    );

    final result = await repository.getRecordedRoutesByUser('user@test.com');

    expect(result, isA<Right<Failure, List<RecordedRoute>>>());
    expect(result.getOrElse(() => []), isEmpty);
  });

  test('returns ServerFailure on generic ServerException', () async {
    when(() => mockProvider.getRecordedRoutes(any())).thenThrow(
      const ServerException('server down'),
    );

    final result = await repository.getRecordedRoutesByUser('user@test.com');

    expect(result, isA<Left<Failure, List<RecordedRoute>>>());
    expect(result.fold((l) => l, (r) => null), isA<ServerFailure>());
  });

  test('returns ConnectionFailure on ConnectionException', () async {
    when(() => mockProvider.getRecordedRoutes(any()))
        .thenThrow(ConnectionException());

    final result = await repository.getRecordedRoutesByUser('user@test.com');

    expect(result, isA<Left<Failure, List<RecordedRoute>>>());
    expect(result.fold((l) => l, (r) => null), isA<ConnectionFailure>());
  });

  test('returns UnknownFailure on unexpected errors', () async {
    when(() => mockProvider.getRecordedRoutes(any()))
        .thenThrow(StateError('boom'));

    final result = await repository.getRecordedRoutesByUser('user@test.com');

    expect(result, isA<Left<Failure, List<RecordedRoute>>>());
    expect(result.fold((l) => l, (r) => null), isA<UnknownFailure>());
  });
}
