import 'package:flutter/foundation.dart';
import 'package:graphql_flutter/graphql_flutter.dart' hide ServerException;
import 'package:nextmove_app/config/graphql_config.dart';
import 'package:nextmove_app/graphql/queries.dart';
import 'package:nextmove_app/src/core/errors/exceptions.dart';
import 'package:nextmove_app/src/funcionalidades/registro/datos/dataproviders/auth_remote_data_provider.dart';

class PromotedCompaniesProvider {
  GraphQLClient get client => GraphQLConfig.client.value;

  Future<List<Map<String, dynamic>>?> getPromotedCompanies() async {
    final authHeader = await AuthRemoteDataProvider().authHeader;

    final QueryOptions options = QueryOptions(
      document: gql(GraphQLQueries.getPromotedCompanies),
      context: Context().withEntry(
        HttpLinkHeaders(headers: {'Authorization': authHeader ?? ''}),
      ),
      fetchPolicy: FetchPolicy.networkOnly,
    );

    final QueryResult result = await client.query(options);

    if (result.hasException) {
      throw ServerException('Error en query: ${result.exception.toString()}');
    }

    final data = result.data?['getFirms'];

    if (kDebugMode) {
      print('Promoted companies data: $data');
    }

    return data != null ? List<Map<String, dynamic>>.from(data) : null;
  }
}
