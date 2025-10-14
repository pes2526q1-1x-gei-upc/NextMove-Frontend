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
}
