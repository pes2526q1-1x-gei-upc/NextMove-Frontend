import 'package:flutter/foundation.dart';
import 'package:graphql_flutter/graphql_flutter.dart' hide ServerException;
import 'package:nextmove_app/config/graphql_config.dart';
import 'package:nextmove_app/graphql/queries.dart';
import 'package:nextmove_app/src/core/errors/exceptions.dart';
import 'package:nextmove_app/src/funcionalidades/alertas/dominio/alert_entity.dart';

Future<QueryResult> getGraphQLQuery(String query, QueryOptions options) async {
  GraphQLClient client = GraphQLConfig.initializeClient().value;
  final QueryResult result = await client.query(options);

  if (result.hasException) {
    throw Exception('Error en query: ${result.exception.toString()}');
  }

  return result;
}

Future<QueryResult> getGraphQLMutation(String mutation, MutationOptions options) async {
  GraphQLClient client = GraphQLConfig.initializeClient().value;
  final QueryResult result = await client.mutate(options);

  if (result.hasException) {
    throw Exception('Error en mutation: ${result.exception.toString()}');
  }

  return result;
}

class AlertRemoteDataProvider {
  GraphQLClient get client => GraphQLConfig.client.value;

  Future<List<StationAlert>> getStationAlerts() async {
    final QueryOptions options = QueryOptions(
      document: gql(GraphQLQueries.getStationAlerts),
      fetchPolicy: FetchPolicy.networkOnly,
    );

    final QueryResult result = await getGraphQLQuery(
      GraphQLQueries.getStationAlerts,
      options,
    );

    if (result.hasException) {
      throw ServerException('Error en query: ${result.exception.toString()}');
    }

    if (kDebugMode) {
      print('getStationAlerts result.data: ${result.data}');
    }

    final data = result.data?['getStationAlerts'];
    if (data != null) {
      return (data as List)
          .map((item) => StationAlert.fromJson(item))
          .toList();
    }

    return [];
  }

  Future<StationAlert?> getStationAlert(String id) async {
    final QueryOptions options = QueryOptions(
      document: gql(GraphQLQueries.getStationAlert),
      variables: {'id': id},
      fetchPolicy: FetchPolicy.networkOnly,
    );

    final QueryResult result = await getGraphQLQuery(
      GraphQLQueries.getStationAlert,
      options,
    );

    if (result.hasException) {
      throw ServerException('Error en query: ${result.exception.toString()}');
    }

    if (kDebugMode) {
      print('getStationAlert result.data: ${result.data}');
    }

    final data = result.data?['getStationAlert'];
    if (data != null) {
      return StationAlert.fromJson(data);
    }

    return null;
  }

  Future<StationAlert> createStationAlert({
    required String stationId,
    required List<String> horas,
    required List<int> diasSemana,
  }) async {
    final MutationOptions options = MutationOptions(
      document: gql(GraphQLQueries.createStationAlert),
      variables: {
        'input': {
          'stationId': stationId,
          'horas': horas,
          'diasSemana': diasSemana,
        },
      },
    );

    final QueryResult result = await getGraphQLMutation(
      GraphQLQueries.createStationAlert,
      options,
    );

    if (result.hasException) {
      throw ServerException('Error en mutation: ${result.exception.toString()}');
    }

    if (kDebugMode) {
      print('createStationAlert result.data: ${result.data}');
    }

    final data = result.data?['createStationAlert'];
    if (data != null) {
      return StationAlert.fromJson(data);
    }

    throw ServerException('No se pudo crear la alerta');
  }

  Future<StationAlert> updateStationAlert({
    required String id,
    required List<String> horas,
    required List<int> diasSemana,
    bool? activa,
  }) async {
    final MutationOptions options = MutationOptions(
      document: gql(GraphQLQueries.updateStationAlert),
      variables: {
        'input': {
          'id': id,
          'horas': horas,
          'diasSemana': diasSemana,
          if (activa != null) 'activa': activa,
        },
      },
    );

    final QueryResult result = await getGraphQLMutation(
      GraphQLQueries.updateStationAlert,
      options,
    );

    if (result.hasException) {
      throw ServerException('Error en mutation: ${result.exception.toString()}');
    }

    if (kDebugMode) {
      print('updateStationAlert result.data: ${result.data}');
    }

    final data = result.data?['updateStationAlert'];
    if (data != null) {
      return StationAlert.fromJson(data);
    }

    throw ServerException('No se pudo actualizar la alerta');
  }

  Future<bool> deleteStationAlert(String id) async {
    final MutationOptions options = MutationOptions(
      document: gql(GraphQLQueries.deleteStationAlert),
      variables: {'id': id},
    );

    final QueryResult result = await getGraphQLMutation(
      GraphQLQueries.deleteStationAlert,
      options,
    );

    if (result.hasException) {
      throw ServerException('Error en mutation: ${result.exception.toString()}');
    }

    if (kDebugMode) {
      print('deleteStationAlert result.data: ${result.data}');
    }

    return result.data?['deleteStationAlert'] as bool? ?? false;
  }

  Future<StationAlert> toggleStationAlert(String id, bool activa) async {
    final MutationOptions options = MutationOptions(
      document: gql(GraphQLQueries.toggleStationAlert),
      variables: {
        'id': id,
        'activa': activa,
      },
    );

    final QueryResult result = await getGraphQLMutation(
      GraphQLQueries.toggleStationAlert,
      options,
    );

    if (result.hasException) {
      throw ServerException('Error en mutation: ${result.exception.toString()}');
    }

    if (kDebugMode) {
      print('toggleStationAlert result.data: ${result.data}');
    }

    final data = result.data?['toggleStationAlert'];
    if (data != null) {
      return StationAlert.fromJson(data);
    }

    throw ServerException('No se pudo cambiar el estado de la alerta');
  }
}

