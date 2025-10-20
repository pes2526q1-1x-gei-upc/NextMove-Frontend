import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:nextmove_app/config/graphql_config.dart';
import 'package:nextmove_app/graphql/queries.dart';
import 'package:nextmove_app/src/funcionalidades/estaciones/dominio/bicycle_station_details.dart';
import 'package:nextmove_app/src/funcionalidades/estaciones/dominio/ev_station_details.dart';

Future<QueryResult> getGraphQLQuery(String query, QueryOptions options) async {
  GraphQLClient client = GraphQLConfig.getClient();
  final QueryResult result = await client.query(options);

  if (result.hasException) {
    throw Exception('Error en query: ${result.exception.toString()}');
  }

  return result;
}

Future<BicycleStationDetails?> DBgetBicycleStationDetails(String stationID) async {
  // final QueryOptions options = QueryOptions(
  //   document: gql(GraphQLQueries.getBicycleStationDetailsQuery),
  //   variables: {'stationID': stationID},
  // );

  // final QueryResult result = await getGraphQLQuery(GraphQLQueries.getBicycleStationDetailsQuery, options);

  // if (result.hasException) {
  //   throw Exception('Error en query: ${result.exception.toString()}');
  // }

  // return BicycleStationDetails.fromJson(result.data?['Station']);
  //   address: '123 Bike Lane',
  //   totalSlots: 10,
  //   availableSlots: 5,
  //   availableBikes: 5,
  //   electricRechargeStation: true,
  //   canAnchorBikes: true,
  //   canRentBikes: true,
  //   state: BicycleStationState.operational,
  //   availableAnchors: 5,
  //   availableMechanicalBikes: 3,
  //   availableElectricBikes: 2,
  //   rating: 6,
  // );
  //TODO: implementar crida a GraphQL
  return BicycleStationDetails(
    address: '123 Bike Lane',
    totalSlots: 10,
    availableSlots: 5,
    availableBikes: 5,
    electricRechargeStation: true,
    canAnchorBikes: true,
    canRentBikes: true,
    state: BicycleStationState.operational,
    availableAnchors: 5,
    availableMechanicalBikes: 3,
    availableElectricBikes: 2,
    rating: 6,
    name: 'Bicycle Station $stationID',
  );
}

Future<EVStationDetails?> DBgetEVStationDetails(String stationID) async {
  final QueryOptions options = QueryOptions(
    document: gql(GraphQLQueries.getEVStationDetailsQuery),
    variables: {'stationID': stationID},
  );

  final QueryResult result = await getGraphQLQuery(GraphQLQueries.getEVStationDetailsQuery, options);
  
  if (result.hasException) {
    throw Exception('Error en query: ${result.exception.toString()}');
  }

  final data = result.data?['station'];
  print(data);
  
  if (data != null) {
    return EVStationDetails.fromJson(data);
  }
  
  return null;

  // return EVStationDetails(
  //   name: 'EV Station $stationID',
  //   address: '456 EV Ave',
  //   availableSlots: 3,
  //   totalSlots: 8,
  //   isSuperFast: true,
  //   connectors: [
  //     Connector(
  //       connectionType: ConnectionType.css2,
  //       powerKw: 50,
  //       status: ConnectorStatus.available,
  //     ),
  //     Connector(
  //       connectionType: ConnectionType.chademo,
  //       powerKw: 100,
  //       status: ConnectorStatus.occupied,
  //     ),
  //     Connector(
  //       connectionType: ConnectionType.mennekes,
  //       powerKw: 22,
  //       status: ConnectorStatus.unavailable,
  //     ),
  //   ],
  //   rating: 8,
  //   accessType: 'Public',
  // );
}
