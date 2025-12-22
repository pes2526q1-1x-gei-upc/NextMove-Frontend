import 'package:flutter/foundation.dart';
import 'package:graphql_flutter/graphql_flutter.dart' hide ServerException;
import 'package:nextmove_app/config/graphql_config.dart';
import 'package:nextmove_app/graphql/queries.dart';
import 'package:nextmove_app/src/core/errors/exceptions.dart';
import 'package:nextmove_app/src/funcionalidades/registro/datos/dataproviders/auth_remote_data_provider.dart';

class RankingRemoteDataProvider {
  GraphQLClient get client => GraphQLConfig.client.value;

  Future<List<Map<String, dynamic>>?> getRanking(String metric) async {
    final authHeader = await AuthRemoteDataProvider().authHeader;

    final QueryOptions options = QueryOptions(
      document: gql(GraphQLQueries.getRanking),
      variables: {'metric': metric},
      context: Context().withEntry(
        HttpLinkHeaders(headers: {'Authorization': authHeader ?? ''}),
      ),
      fetchPolicy: FetchPolicy.networkOnly,
    );

    final QueryResult result = await client.query(options);

    if (result.hasException) {
      throw ServerException('Error en query: ${result.exception.toString()}');
    }

    final data = result.data?['ranking'];

    if (kDebugMode) {
      print('Ranking data: $data');
    }

    return data != null
        ? List<Map<String, dynamic>>.from(data)
        : null;
  }
}
