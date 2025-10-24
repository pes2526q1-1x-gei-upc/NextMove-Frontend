// Define your GraphQL queries here
// Go to /api/gql/playground to test your queries before using them :)

class GraphQLQueries {
  static const String getUserQuery = r'''
    query getUser($id: ID!) {
      User(id: $id) {
        id
        nombre
        email
      }
    }
  ''';
  static const String getBicycleStationDetailsQuery = r'''
    query getBicingStationDetails($stationID: ID!) {
      getEstacionDeBicing(id: $stationID) {
        nombre,
        direccion,
        plazasTotales,
        estacionCargaElectrica,
        sePuedenAlquilarBicis,
        sePuedeAnclarBicis,
        plazasOcupadas,
        anclajesDisponibles,
        estado,
        bicisMecanicasDisponibles,
        bicisElectricasDisponibles
      }
   }
  '''; //TODO: afegir altres camps

  static const String getAllBicycleStationsQuery = r'''
    query getAllBicingStations {
      getEstacionesDeBicing {
        id,
        nombre,
        direccion,
        coordenadas {
          lat,
          lon
        },
        plazasTotales,
        estacionCargaElectrica,
        sePuedenAlquilarBicis,
        sePuedeAnclarBicis,
        plazasOcupadas,
        anclajesDisponibles,
        estado,
        bicisMecanicasDisponibles,
        bicisElectricasDisponibles
      }
    }''';

  static const String getEVStationDetailsQuery = r'''
    query getEVStationDetails($stationID: ID!) {
      station(id: $stationID) {
        name
        address
        connectors {
          type
          powerKw
          status
        }
        accessType
        isSuperFast
      }
    }
  ''';

  static const String getAllEVStationsQuery = r'''
    query getEVStations {
      stations {
        stations {
          id
          name
          address
          city
          coordinates {
            latitude
            longitude
          }
          connectors {
            type
            powerKw
            status
            statusCode
          }
          accessType
          isSuperFast
          lastUpdated
          distance
        }
      }
    }''';
}

