import 'package:flutter/foundation.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:nextmove_app/config/graphql_config.dart';
import 'package:nextmove_app/graphql/queries.dart';
import 'package:nextmove_app/src/funcionalidades/registro/datos/dataproviders/auth_remote_data_provider.dart';

/// Servicio para validar si un texto contiene palabras ofensivas
class BadWordsService {
  GraphQLClient get client => GraphQLConfig.client.value;

  /// Valida si un texto contiene palabras ofensivas
  /// Retorna true si el texto es ofensivo, false en caso contrario
  Future<bool> checkOffensiveText(String text) async {
    if (text.trim().isEmpty) {
      return false;
    }

    try {
      final authHeader = await AuthRemoteDataProvider().authHeader;
      
      final QueryOptions options = QueryOptions(
        document: gql(GraphQLQueries.checkOffensiveText),
        variables: {'text': text},
        context: Context().withEntry(
          HttpLinkHeaders(headers: {
            'Authorization': authHeader ?? '',
          }),
        ),
        fetchPolicy: FetchPolicy.networkOnly,
      );

      final QueryResult result = await client.query(options);

      if (result.hasException) {
        if (kDebugMode) {
          debugPrint('Error validando texto ofensivo: ${result.exception}');
        }
        return true;
      }

      final bool? isOffensive = result.data?['checkOffensiveText'] as bool?;
      return isOffensive ?? false;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Excepción validando texto ofensivo: $e');
      }
      return true;
    }
  }
}

