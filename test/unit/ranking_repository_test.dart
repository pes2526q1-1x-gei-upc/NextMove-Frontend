import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nextmove_app/src/core/errors/exceptions.dart';
import 'package:nextmove_app/src/core/errors/failure.dart';
import 'package:nextmove_app/src/funcionalidades/competition/ranking/data/dataproviders/ranking_remote_data_provider.dart';
import 'package:nextmove_app/src/funcionalidades/competition/ranking/data/repositories/ranking_repository.dart';
import 'package:nextmove_app/src/funcionalidades/competition/ranking/domain/ranking_entry.dart';

class MockRankingRemoteDataProvider extends Mock
    implements RankingRemoteDataProvider {}

void main() {
  late MockRankingRemoteDataProvider mockProvider;
  late RankingRepository repository;

  setUp(() {
    mockProvider = MockRankingRemoteDataProvider();
    repository = RankingRepository(rankingRemoteDataProvider: mockProvider);
  });

  tearDown(() {
    reset(mockProvider);
  });

  test('getRankingData maps provider response to RankingEntry', () async {
    final payload = [
      {
        'email': 'user@test.com',
        'nickname': 'user',
        'num_rutas': 3,
        'km_recorridos': 12.5,
      },
    ];

    when(() => mockProvider.getRanking(any()))
        .thenAnswer((_) async => payload);

    final result = await repository.getRankingData('distance');

    expect(result, isA<Right<Failure, List<RankingEntry>?>>());
    final entries = result.getOrElse(() => []);
    expect(entries?.length, 1);
    expect(entries?.first.nickname, 'user');
    expect(entries?.first.distance, 12.5);
  });

  test('getRankingData returns ServerFailure on ServerException', () async {
    when(() => mockProvider.getRanking(any()))
        .thenThrow(const ServerException('bad'));

    final result = await repository.getRankingData('distance');

    expect(result, isA<Left<Failure, List<RankingEntry>?>>());
    expect(result.fold((l) => l, (r) => null), isA<ServerFailure>());
  });

  test('getRankingData returns ConnectionFailure on ConnectionException',
      () async {
    when(() => mockProvider.getRanking(any()))
        .thenThrow(ConnectionException());

    final result = await repository.getRankingData('distance');

    expect(result, isA<Left<Failure, List<RankingEntry>?>>());
    expect(result.fold((l) => l, (r) => null), isA<ConnectionFailure>());
  });

  test('getRankingData throws UnknownFailure on unexpected errors', () async {
    when(() => mockProvider.getRanking(any())).thenThrow(StateError('oops'));

    expect(
      () => repository.getRankingData('distance'),
      throwsA(isA<UnknownFailure>()),
    );
  });
}
