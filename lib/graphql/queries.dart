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
    query getBicycleStationDetails($stationID: ID!) {
      station(id: $stationID) {
        name
        address
      }
    }
  '''; //TODO: afegir altres camps
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
}
