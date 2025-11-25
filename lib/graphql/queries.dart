class GraphQLQueries {
 
  static const String createUserMutation = r'''
  mutation CreateUser($email: String!, $fullN: String!, $nickN: String!, $phoneNum: String, $mode: Mode!, $preferredLanguage: Language, $birthDate: String, $bioDescription: String) {
    createUser(createInfo: {
      email: $email,
      name: $fullN,
      nickname: $nickN,
      phoneNumber: $phoneNum,
      preferredMode: $mode,
      preferredLanguage: $preferredLanguage,
      birthDate: $birthDate,
      bioDescription: $bioDescription    
    }) {
      email
      name
      nickname
      phoneNumber
      preferredMode
      createdAt
      preferredLanguage
      birthDate
      bioDescription
    }
  }
  ''';

  static const String getUserProfileQuery = r'''
  query Me {
    me {
      email
      name
      nickname
      photo
      preferredMode
      birthDate
      bioDescription
      phoneNumber
      preferredLanguage
      createdAt
    }
  }
  ''';

  static const String updateUserMutation = r'''
  mutation UpdateMe($fullName: String, $nickname: String, $preferredMode: Mode, $phoneNumber: String, $bioDescription: String, $preferredLanguage: Language, $birthDate: String) {
    updateMe(
      nickname: $nickname,
      name: $fullName,
      preferredMode: $preferredMode,
      phoneNumber: $phoneNumber,
      bioDescription: $bioDescription,
      birthDate: $birthDate,
      preferredLanguage: $preferredLanguage
    ) {
      email
      name
      phoneNumber
      birthDate
      
      nickname
      photo
      bioDescription
      
      preferredMode
      preferredLanguage
    
      createdAt
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
  '''; 

  static const String getAllBicycleStationsQuery = r'''
    query getAllBicingStations {
      getEstacionesDeBicing {
        id,
        nombre,
        direccion,
        coordenadas {
          latitude,
          longitude
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

  static const String getAllNearbyBicycleStationsQuery = r'''
  query getAllNearbyBicycleStations($location: LocationInput!) {
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

  static const String getAllNearbyEVStationsQuery = r'''
  query getAllNearbyEVStations ($location: LocationInput!) {
    nearbyStations(location: $location) {
      id
      name
      address
      city
      coordinates {
        longitude
        latitude
      }
      distance
      connectors {
        type
        powerKw
        status
      }
      isSuperFast
    }
  }''';

  static const String getFriends = r'''
  query getFriends ($nickname: String!) {
    ListFriends(nickname: $nickname){
      name
    }
  }''';

  static const String newFriendship = r'''
  mutation newFriendship ($nickname1: String!, $nickname2: String!) {
    AddFriendship(nickname1: $nickname1, nickname2: $nickname2){
      
    }
  }''';

  static const String deleteFriendship = r'''
  mutation deleteFriendship ($nickname1: String!, $nickname2: String!) {
    RemoveFriendship(nickname1: $nickname1, nickname2: $nickname2){
      name
    }
  }''';

  static const String getUsersByNickname = r'''
  query getUsersByNickname ($nickname: String!){
    UsersByNickname(nickname: $nickname){
        email,
        name,
        nickname,
        photo,
        birthDate,
        phoneNumber,
        preferredMode,
        preferredLanguage,
        bioDescription,
        createdAt,
    } 
  }''';

  static const String getStationsBySearchQuery = r'''
    query getStationsBySearchQuery($query: String!) {
      stationsByAddress(address: $query) {
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