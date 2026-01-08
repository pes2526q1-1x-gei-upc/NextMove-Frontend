import 'package:flutter/foundation.dart';
import 'package:graphql_flutter/graphql_flutter.dart' hide ServerException;
import 'package:nextmove_app/config/graphql_config.dart';
import 'package:nextmove_app/graphql/queries.dart';
import 'package:nextmove_app/src/core/errors/exceptions.dart';
import 'package:nextmove_app/src/funcionalidades/registro/datos/dataproviders/auth_remote_data_provider.dart';

class ChallengesRemoteDataProvider {
  GraphQLClient get client => GraphQLConfig.client.value;

  Future<List<Map<String, dynamic>>?> getAllChallenges() async {
    final authHeader = await AuthRemoteDataProvider().authHeader;

    final QueryOptions options = QueryOptions(
      document: gql(GraphQLQueries.getAllChallenges),
      context: Context().withEntry(
        HttpLinkHeaders(headers: {'Authorization': authHeader ?? ''}),
      ),
      fetchPolicy: FetchPolicy.networkOnly,
    );

    final QueryResult result = await client.query(options);

    if (result.hasException) {
      throw ServerException('Error en query: ${result.exception.toString()}');
    }

    final data = result.data?['getAllChallenges'];

    if (kDebugMode) {
      print('Challenges data: $data');
    }

    return data != null ? List<Map<String, dynamic>>.from(data) : null;
  }

  Future<List<Map<String, dynamic>>?> getEnrolledChallenge() async {
    final authHeader = await AuthRemoteDataProvider().authHeader;

    final QueryOptions options = QueryOptions(
      document: gql(GraphQLQueries.getEnrolledChallenge),
      context: Context().withEntry(
        HttpLinkHeaders(headers: {'Authorization': authHeader ?? ''}),
      ),
      fetchPolicy: FetchPolicy.networkOnly,
    );

    final QueryResult result = await client.query(options);

    if (result.hasException) {
      throw ServerException('Error en query: ${result.exception.toString()}');
    }

    final List<dynamic>? data = result.data?['getEnrolledChallenges'];

    if (kDebugMode) {
      print('Enrolled Challenge full data: $data');
    }

    return data != null ? List<Map<String, dynamic>>.from(data) : null;
  }

  Future<void> enrollInChallenge(String challengeId) async {
    final authHeader = await AuthRemoteDataProvider().authHeader;

    final MutationOptions options = MutationOptions(
      document: gql(GraphQLQueries.enrollInChallenge),
      variables: {'challengeId': challengeId},
      context: Context().withEntry(
        HttpLinkHeaders(headers: {'Authorization': authHeader ?? ''}),
      ),
    );

    final QueryResult result = await client.mutate(options);

    if (result.hasException) {
      throw ServerException('Error en mutation: ${result.exception.toString()}');
    }

    if (kDebugMode) {
      print('Successfully enrolled in challenge with ID: $challengeId');
    }
  }

  Future<List<String>?> getCompletedChallenges() async {
    final authHeader = await AuthRemoteDataProvider().authHeader;

    final QueryOptions options = QueryOptions(
      document: gql(GraphQLQueries.getCompletedChallenges),
      context: Context().withEntry(
        HttpLinkHeaders(headers: {'Authorization': authHeader ?? ''}),
      ),
      fetchPolicy: FetchPolicy.networkOnly,
    );

    final QueryResult result = await client.query(options);

    if (result.hasException) {
      throw ServerException('Error en query: ${result.exception.toString()}');
    }

    final List<dynamic>? data = result.data?['getTrophies'];

    if (kDebugMode) {
      print('Completed Challenges data: $data');
    }

    return data?.map((challenge) => challenge['name'] as String).toList();
  } 
}
