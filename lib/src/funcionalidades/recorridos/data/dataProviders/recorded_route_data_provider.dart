import 'package:flutter/foundation.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:nextmove_app/config/graphql_config.dart';
import 'package:nextmove_app/src/core/errors/exceptions.dart'
    as custom_exceptions;
import 'package:nextmove_app/src/funcionalidades/recorridos/domain/recorded_route.dart';
import 'package:nextmove_app/graphql/queries.dart';

class RecordedRouteDataProvider {
  //i want to get the info of pasts routes of the back
  GraphQLClient get client => GraphQLConfig.client.value;
  Future<List<RecordedRoute>> getRecordedRoutes(String userEmail) async {
    final QueryOptions options = QueryOptions(
      document: gql(GraphQLQueries.getRecorridosByUserQuery),
      variables: {
        'userEmail': userEmail,
      },
    );

    final QueryResult result = await client.query(options);

    // Si hay excepción pero también hay datos, intentar procesar los datos primero
    // Una lista vacía no debería ser una excepción
    final List<dynamic> recordedRoutes = result.data?['recorridosByUser'] ?? [];
    
    // Si tenemos datos (incluso si es una lista vacía), devolverlos
    // Solo lanzar excepción si realmente no hay datos Y hay una excepción
    if (result.hasException) {
      // Verificar si la excepción es porque no hay recorridos (esto es válido)
      final exceptionMessage = result.exception?.graphqlErrors.isNotEmpty == true
          ? result.exception!.graphqlErrors.first.message.toLowerCase()
          : result.exception.toString().toLowerCase();
      
      // Si el mensaje indica que no hay recorridos, devolver lista vacía en lugar de excepción
      if (exceptionMessage.contains('no hay') || 
          exceptionMessage.contains('no encontrado') ||
          exceptionMessage.contains('not found') ||
          exceptionMessage.contains('empty') ||
          exceptionMessage.contains('ningún') ||
          exceptionMessage.contains('ningun')) {
        if (kDebugMode) {
          print('Backend indica que no hay recorridos, devolviendo lista vacía');
        }
        return [];
      }
      
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

    // Si no hay excepción, devolver los datos (puede ser lista vacía)
    return recordedRoutes
        .map((routeJson) => RecordedRoute.fromJson(routeJson))
        .toList();
  }
}


