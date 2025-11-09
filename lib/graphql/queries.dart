class GraphQLQueries {
  // === USUARIO ACTUAL (me) ===
  static const String getMeQuery = r'''
    query Me {
      me {
        email
        name
        nickname
        photo
        birthDate
        phoneNumber
        preferredMode
        preferredLanguage
        bioDescription
        createdAt
      }
    }
  ''';

  // === USUARIO POR EMAIL ===
  static const String getUserQuery = r'''
    query GetUser($email: String!) {
      User(email: $email) {
        email
        name
        nickname
        photo
        birthDate
        phoneNumber
        preferredMode
        preferredLanguage
        bioDescription
        createdAt
      }
    }
  ''';

  // === DETALLE ESTACIÓN BICING ===
  static const String getBicycleStationDetailsQuery = r'''
    query GetBicingStationDetails($stationID: ID!) {
      getEstacionDeBicing(id: $stationID) {
        nombre
        direccion
        plazasTotales
        estacionCargaElectrica
        sePuedenAlquilarBicis
        sePuedeAnclarBicis
        plazasOcupadas
        anclajesDisponibles
        estado
        bicisMecanicasDisponibles
        bicisElectricasDisponibles
      }
    }
  ''';

  // === TODAS LAS ESTACIONES BICING ===
  static const String getAllBicycleStationsQuery = r'''
    query GetAllBicingStations {
      getEstacionesDeBicing {
        id
        nombre
        direccion
        coordenadas {
          latitude
          longitude
        }
        plazasTotales
        estacionCargaElectrica
        sePuedenAlquilarBicis
        sePuedeAnclarBicis
        plazasOcupadas
        anclajesDisponibles
        estado
        bicisMecanicasDisponibles
        bicisElectricasDisponibles
      }
    }
  ''';

  // === ESTACIONES BICING CERCANAS ===
  static const String getAllNearbyBicycleStationsQuery = r'''
    query GetAllNearbyBicycleStations($location: LocationInput!) {
      getEstacionesDeBicingCercanas(location: $location) {
        id
        estado
        direccion
        nombre
        plazasTotales
        plazasOcupadas
        sePuedenAlquilarBicis
        sePuedeAnclarBicis
        bicisMecanicasDisponibles
        bicisElectricasDisponibles
        anclajesDisponibles
        estacionCargaElectrica
        coordenadas {
          latitude
          longitude
        }
        distanciaKm
      }
    }
  ''';

  // === DETALLE ESTACIÓN ELÉCTRICA ===
  static const String getEVStationDetailsQuery = r'''
    query GetEVStationDetails($stationID: ID!) {
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

  // === TODAS LAS ESTACIONES ELÉCTRICAS ===
  static const String getAllEVStationsQuery = r'''
    query GetEVStations {
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
    }
  ''';

  // === ESTACIONES ELÉCTRICAS CERCANAS ===
  static const String getAllNearbyEVStationsQuery = r'''
    query GetAllNearbyEVStations($location: LocationInput!) {
      nearbyStations(location: $location) {
        id
        name
        address
        city
        coordinates {
          latitude
          longitude
        }
        distance
        connectors {
          type
          powerKw
          status
        }
        isSuperFast
      }
    }
  ''';
}