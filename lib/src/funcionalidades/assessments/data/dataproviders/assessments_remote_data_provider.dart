import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:graphql_flutter/graphql_flutter.dart' hide ServerException;
import 'package:nextmove_app/config/graphql_config.dart';
import 'package:nextmove_app/graphql/queries.dart';
import 'package:nextmove_app/graphql/mutations.dart';
import 'package:nextmove_app/src/core/errors/exceptions.dart';
import 'package:nextmove_app/src/funcionalidades/assessments/domain/assessment_entity.dart';
import 'package:nextmove_app/src/funcionalidades/assessments/domain/assessment_info_entity.dart';


class AssessmentRemoteDataProvider {
  GraphQLClient get client => GraphQLConfig.client.value;

  Future<String?> get _authHeader async {
    final fireBaseUser = FirebaseAuth.instance.currentUser;
    if (fireBaseUser != null) {
      final token = await fireBaseUser.getIdToken();
      return 'Bearer $token';
    }
    return null;
  }

  Future<void> createAssessment(String stationId, int score, String description) async {
    try {
      final authHeader = await _authHeader;

      final MutationOptions options = MutationOptions(
        document: gql(GraphQLMutations.createAssessmentQuery), 
        variables: {
          'station_id': stationId,
          'score': score,
          'comments': description,
        },
        context: Context().withEntry(
          HttpLinkHeaders(headers: {
            'Authorization': authHeader ?? '',
          }),
        ),
      );

      debugPrint("Enviando valoración al servidor...");
      final QueryResult result = await client.mutate(options);

      if (result.hasException) {
        final exception = result.exception;
        debugPrint('Excepción devuelta por GraphQL: ${exception.toString()}');
        String errorMessage = 'Error al crear valoración';
        if (exception != null && exception.graphqlErrors.isNotEmpty) {
          errorMessage = exception.graphqlErrors.first.message;
          debugPrint('Mensaje de error extraído: $errorMessage');
        } else if (exception?.linkException != null) {
          errorMessage = exception!.linkException.toString();
        } else {
          errorMessage = exception.toString();
        }
        debugPrint('Lanzando ServerException con mensaje: $errorMessage');
        throw ServerException(errorMessage);
      }
      
      debugPrint("Valoración creada con éxito");

    } on ServerException {
      rethrow;
    } catch (e, stackTrace) {
      debugPrint("Error antes de enviar: $e");
      debugPrint("Stack trace: $stackTrace");
      throw ServerException('Error interno al preparar la petición: $e');
    }
  }

  Future<List<AssessmentEntity>> getAssessmentsByStation(String stationId) async {
    try {
      final authHeader = await _authHeader;

      final QueryOptions options = QueryOptions(
        document: gql(GraphQLQueries.getAssessmentsByStationIdQuery), 
        variables: {
          'id': stationId, 
        },
        fetchPolicy: FetchPolicy.networkOnly, 
        context: Context().withEntry(
          HttpLinkHeaders(headers: {
            'Authorization': authHeader ?? '',
          }),
        ),
      );

      debugPrint("Obteniendo valoraciones del servidor...");
      
      final QueryResult result = await client.query(options);

      if (result.hasException) {
        debugPrint('Excepción GraphQL: ${result.exception.toString()}');
        throw ServerException('Error al obtener valoraciones: ${result.exception.toString()}');
      }

      final List<dynamic> rawList = result.data?['getAssessmentsByStationId'] ?? [];
      
      debugPrint("Valoraciones encontradas: ${rawList.length}");

      return rawList.map((item) {
        return AssessmentEntity(
          nickname: item['nickname'] ?? 'Anónimo',
          stationId: stationId, 
          score: (item['score'] as num).toInt(),
          description: item['comments'] ?? '', 
          createdAt: DateTime.tryParse(item['created_at'].toString()) ?? DateTime.now(),
        );
      }).toList();

    } catch (e, stackTrace) {
      debugPrint("Error crítico al obtener valoraciones: $e");
      debugPrint("Stack trace: $stackTrace");
      throw ServerException('Error interno: $e');
    }    
  }
  
  Future<AssessmentInfoEntity> getStationAssessmentInfo(String stationId) async {
    try {
      final authHeader = await _authHeader;

      final QueryOptions options = QueryOptions(
        document: gql(GraphQLQueries.getStationAssessmentInfoQuery), 
        variables: {
          'id': stationId,
        },
        fetchPolicy: FetchPolicy.networkOnly, 
        context: Context().withEntry(
          HttpLinkHeaders(headers: {
            'Authorization': authHeader ?? '',
          }),
        ),
      );

      debugPrint("Obteniendo info agregada de la estación...");
      final QueryResult result = await client.query(options);

      if (result.hasException) {
        debugPrint('Excepción GraphQL: ${result.exception.toString()}');
        throw ServerException('Error al obtener info: ${result.exception.toString()}');
      }
      
      final data = result.data?['getStationAssessmentInfo'];
      
      if (data == null) {
        return const AssessmentInfoEntity(averageScore: 0.0, totalAssessments: 0);
      }

      return AssessmentInfoEntity(
        averageScore: (data['averageScore'] as num?)?.toDouble() ?? 0.0,
        totalAssessments: (data['totalAssessments'] as num?)?.toInt() ?? 0,
      );

    } catch (e) {
      debugPrint("Error crítico al obtener info: $e");
      throw ServerException('Error interno: $e');
    }    
  }

  // --- ACTUALIZAR VALORACIÓN ---
  Future<void> updateAssessment(String stationId, int score, String description) async {
    try {
      final authHeader = await _authHeader;
      
      final MutationOptions options = MutationOptions(
        document: gql(GraphQLMutations.editAssessmentQuery),
        variables: {
          'station_id': stationId,
          'score': score,
          'comments': description, 
        },
        context: Context().withEntry(
          HttpLinkHeaders(headers: {
            'Authorization': authHeader ?? '',
          }),
        ),
      );

      debugPrint("Editando valoración...");
      final QueryResult result = await client.mutate(options);

      if (result.hasException) {
        final exception = result.exception;
        debugPrint('Excepción GraphQL al editar: ${exception.toString()}');
        // Extraer el mensaje de error de GraphQL
        String errorMessage = 'Error al editar valoración';
        if (exception != null && exception.graphqlErrors.isNotEmpty) {
          errorMessage = exception.graphqlErrors.first.message;
          debugPrint('Mensaje de error extraído: $errorMessage');
        } else if (exception?.linkException != null) {
          errorMessage = exception!.linkException.toString();
        } else {
          errorMessage = exception.toString();
        }
        debugPrint('Lanzando ServerException con mensaje: $errorMessage');
        throw ServerException(errorMessage);
      }
      
      debugPrint("Valoración editada con éxito. Nuevo promedio: ${result.data?['editAssessment']}");

    } on ServerException {
      rethrow;
    } catch (e) {
      debugPrint("Error crítico al editar: $e");
      throw ServerException('Error interno: $e');
    }
  }

  // --- ELIMINAR VALORACIÓN ---
  Future<void> deleteAssessment(String stationId) async {
    try {
      final authHeader = await _authHeader;
      
      final MutationOptions options = MutationOptions(
        document: gql(GraphQLMutations.deleteAssessmentQuery),
        variables: {
          'station_id': stationId,
        },
        context: Context().withEntry(
          HttpLinkHeaders(headers: {
            'Authorization': authHeader ?? '',
          }),
        ),
      );

      debugPrint("Eliminando valoración...");
      final QueryResult result = await client.mutate(options);

      if (result.hasException) {
        debugPrint('Excepción GraphQL al eliminar: ${result.exception.toString()}');
        throw ServerException('Error al eliminar valoración: ${result.exception.toString()}');
      }

       debugPrint("Valoración eliminada con éxito. Nuevo promedio: ${result.data?['deleteAssessment']}");

    } catch (e) {
      debugPrint("Error crítico al eliminar: $e");
      throw ServerException('Error interno: $e');
    }
  }

  // --- VERIFICAR SI EL USUARIO HA VALORADO ---
  Future<bool> checkAssessed(String stationId) async {
    try {
      final authHeader = await _authHeader;
      
      final QueryOptions options = QueryOptions(
        document: gql(GraphQLQueries.checkAssessed),
        variables: {
          'station_id': stationId,
        },
        fetchPolicy: FetchPolicy.networkOnly,
        context: Context().withEntry(
          HttpLinkHeaders(headers: {
            'Authorization': authHeader ?? '',
          }),
        ),
      );

      debugPrint("Verificando si el usuario ha valorado...");
      final QueryResult result = await client.query(options);

      if (result.hasException) {
        debugPrint('Excepción GraphQL al verificar: ${result.exception.toString()}');
        throw ServerException('Error al verificar valoración: ${result.exception.toString()}');
      }

      final bool hasAssessed = result.data?['checkAssessed'] ?? false;
      debugPrint("Usuario ha valorado: $hasAssessed");
      
      return hasAssessed;
    } catch (e) {
      debugPrint("Error crítico al verificar: $e");
      throw ServerException('Error interno: $e');
    }
  }
}