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

    static const String getAllStationsQuery = r'''
    query getAllStations {
      stations {
        stations{
          id
          name
          city
          coordinates{
            latitude
            longitude
          }
          connectors{
            type
            powerKw
            status
          }
          isSuperfast
          }
          total
      }
    }

  ''';

}
