import 'package:flutter/foundation.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:nextmove_app/config/graphql_config.dart';
import 'package:nextmove_app/src/core/errors/exceptions.dart' as custom_exceptions;
import 'package:nextmove_app/src/funcionalidades/mapa/domain/navigation_route.dart';
import 'package:nextmove_app/src/shared/domain/route_input.dart';
import 'package:nextmove_app/graphql/queries.dart';

class NavigationRouteDataProvider {
  GraphQLClient get client => GraphQLConfig.client.value;

  Future<NavigationRoute> computeRoute(RouteInput routeInput) async {
    try{
    final QueryOptions options = QueryOptions(
      document: gql(GraphQLQueries.getNavigationRouteQuery),
      variables: routeInput.toVariables(),
    );
    
        final QueryResult result = await client.query(options);
          debugPrint('🔍 Result hasException: ${result.hasException}');
          debugPrint('🔍 Result exception: ${result.exception}');
          debugPrint('📦 Result data completo: ${result.data}');
          
        if (result.hasException) {
          debugPrint('🔍 Exception completa: ${result.exception}');
          debugPrint('🔍 Datos recibidos: ${result.data}');
      
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
            'Error al calcular la ruta: ${result.exception}',
          );
        }

        final routeData = result.data?['computeRoute']?['recommendedRoute'];
        
        if (routeData == null) {
          throw custom_exceptions.ServerException(
            'No se recibió ninguna ruta del servidor',
          );
        }

        return NavigationRoute.fromJson(routeData as Map<String, dynamic>);
      }  on PartialDataException catch (e, stackTrace) {
            debugPrint('🔴 PartialDataException CAPTURADA!');
            debugPrint('🔍 Exception: $e');
            debugPrint('🔍 Path: ${e.path}');
            debugPrint('🔍 StackTrace: $stackTrace');
            
            // Intentar continuar de todas formas
            rethrow;
      } catch (e, stackTrace) {
          debugPrint('🔴 OTRA EXCEPCIÓN CAPTURADA!');
          debugPrint('🔍 Tipo: ${e.runtimeType}');
          debugPrint('🔍 Mensaje: $e');
          debugPrint('🔍 StackTrace: $stackTrace');
          
          throw custom_exceptions.ServerException(
            'Error inesperado: $e',
          );
        }
  }
}
