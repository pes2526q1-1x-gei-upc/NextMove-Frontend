class GraphQLMutations {
  // === Perfil ===
  static const String createUserMutation = r'''
  mutation CreateUser($input: CreateUserInput!) {
        createUser(createInfo: $input) {
          email
          name
          photo
          nickname
          phoneNumber
          preferredMode
          preferredLanguage
          birthDate
          bioDescription
          regWithGoogle
        }
      }
  ''';

  static const String deleteUserMutation = r'''
    mutation deleteUser($email: String!) {
      deleteUser(email: $email)
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

  // === Social ===
  static const String newFriendship = r'''
  mutation newFriendship ($nickname: String!) {
    AddFriendship(nickname: $nickname){
      
    }
  }''';

  static const String deleteFriendship = r'''
  mutation deleteFriendship ($nickname: String!) {
    RemoveFriendship(nickname: $nickname)
  }''';

  static const String blockUser = r'''
  mutation blockUser($nickname: String!) {
    BlockUser(nickname: $nickname)
  }
  ''';

  static const String unBlockUser = r'''
  mutation unBlockUser($nickname: String!) {
    UnBlockUser(nickname: $nickname)
  }
  ''';

  // === Recorridos ===
  static const String createTrackMutation = r'''
    mutation createTrackMutation($user_email: String!, $distancia: Float!, $velocidad_media: Float!, $velocidad_maxima: Float!, $co2: Float!, $kcal: Float!, $elevacion_positiva: Float!, $elevacion_negativa: Float!, $origen: CoordinatesInput!, $destino: CoordinatesInput!, $tiempo_inicio: String!, $tiempo_fin: String!, $fecha_recorrido: String!) {
    createRecorrido(input: {
      user_email: $user_email,
      distancia: $distancia,
      velocidad_media: $velocidad_media,
      velocidad_maxima: $velocidad_maxima,
      co2: $co2,
      kcal: $kcal,
      elevacion_positiva: $elevacion_positiva,
      elevacion_negativa: $elevacion_negativa,
      origen: $origen,
      destino: $destino,
      tiempo_inicio: $tiempo_inicio,
      tiempo_fin: $tiempo_fin,
      fecha_recorrido: $fecha_recorrido
    }) {
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
  }''';

  // === Valoraciones ===
  static const String createAssessmentQuery = r'''
    mutation CreateAssessment($station_id: String!, $score: Int!, $comments: String) {
      createAssessment(station_id: $station_id, score: $score, comments: $comments)
    }
  ''';

  static const String deleteAssessmentQuery = r'''
    mutation DeleteAssessment($station_id: String!) {
      deleteAssessment(station_id: $station_id)
    }
  ''';

  static const String editAssessmentQuery = r'''
    mutation EditAssessment($station_id: String!, $score: Int!, $comments: String) {
      editAssessment(station_id: $station_id, score: $score, comments: $comments)
    }
  ''';
}
