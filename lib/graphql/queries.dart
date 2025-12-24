class GraphQLQueries {
  // === Perfil ===
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

  static const String existsUserQuery = r'''
    query ExistsUser ($email: String!) {
      ExistsUser (email: $email) {
        exists
        isRegWithGoogle
      }
    }''';

  // === Estaciones Bicing ===
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

  static const String getBicingStationsBySearchQuery = r'''
      query SearchBicingStations($address: String!) {
        getEstacionesDeBicingPorDireccion(address: $address) {
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

  // === Estaciones EV ===
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

  // === Social ===
  static const String getFriends = r'''
  query getFriends () {
    ListFriends(){
      name
      photo
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

  static const String getBlockList = r'''
  query getBlockList {
    BlockList {
      blocked
      photo
    }
  }
  ''';

  // === Recorridos ===
  static const String getRecorridosByUserQuery = r'''
  query GetRecorridosByUser($userEmail: String!) {
    recorridosByUser(user_email: $userEmail) {
      id
      user_email
      distancia
      velocidad_media
      velocidad_maxima
      co2
      kcal
      elevacion_positiva
      elevacion_negativa
      origen {
        latitude
        longitude
      }
      destino {
        latitude
        longitude
      }
      tiempo_inicio
      tiempo_fin
      fecha_recorrido
    }
  }
''';

  // === Valoraciones ===
  static const String getAssessmentsByStationIdQuery = r'''
    query getAssessmentsByStationIdQuery ($id: String!){
      getAssessmentsByStationId(id: $id){
        nickname
        score
        comments
        created_at
      }
    }''';

  static const String getStationAssessmentInfoQuery = r'''
    query getStationAssessmentInfoQuery ($id: String!){
      getStationAssessmentInfo(id: $id){
        averageScore
        totalAssessments
      }
    }''';

  static const String checkAssessed = r'''
    query checkAssessed($station_id: String!){
      checkAssessed(station_id: $station_id)
    } 
  ''';
}

const String getOrCreateDirectChatQuery = r'''
  query GetOrCreateDirectChat($userEmail: String!) {
    getOrCreateDirectChat(userEmail: $userEmail) {
      id
      type
      name
    }
  }
''';

const String myChatsQuery = r'''
  query MyChats {
    myChats {
      id
      type
      name
      description
      participants {
        userEmail
        nickname
        photoUrl
        joinedAt
      }
      lastMessage {
        content
        sender
        timestamp
      }
      createdAt
      updatedAt
    }
  }
''';

const String chatMessagesQuery = r'''
  query ChatMessages($chatId: ID!, $limit: Int, $offset: Int) {
    chatMessages(chatId: $chatId, limit: $limit, offset: $offset) {
      id
      chatId
      senderEmail
      senderNickname
      senderPhoto
      content
      type
      createdAt
      deleted
      deletedAt
      edited
      editedAt
    }
  }
''';

const String getChatDetailsQuery = r'''
  query GetChatDetails($chatId: ID!) {
    myChats {
      id
      type
      name
      description
      participants {
        userEmail
        nickname
        photoUrl
        joinedAt
      }
      createdAt
      updatedAt
    }
  }
''';

const String createGroupChatMutation = r'''
  mutation CreateGroupChat($name: String!, $description: String, $participantEmails: [String!]!) {
    createGroupChat(name: $name, description: $description, participantEmails: $participantEmails) {
      id
      name
      description
      type
      participants {
        userEmail
        nickname
        photoUrl
      }
    }
  }
''';
