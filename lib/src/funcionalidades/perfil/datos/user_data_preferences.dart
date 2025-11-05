import 'package:firebase_auth/firebase_auth.dart';
import 'package:nextmove_app/src/funcionalidades/perfil/dominio/user_data_preferences.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:flutter/material.dart';

// Enviar datos del usuario a la API
Future<UserData> pushUserDataPreferences(
  UserData preferences,
  BuildContext context,
) async {
  debugPrint("========================");
  debugPrint("Capa de Datos: Enviando preferencias de usuario a la API");
  debugPrint("Enviando preferredMode: ${UserData.mapPreferredModeToAPI(preferences.modoPreferido)}");
  debugPrint("Apodo: ${preferences.apodo}");
  debugPrint("Nombre Completo: ${preferences.nombreCompleto}");
  debugPrint("Número de Teléfono: ${preferences.numeroTelefono}");
  debugPrint("Descripción: ${preferences.descripcion}");
  debugPrint("Modo Preferido: ${preferences.modoPreferido}");
  debugPrint("========================");

  final GraphQLClient client = GraphQLProvider.of(context).value;

  const String updateUserMutation = r'''
    mutation UpdateMe($name: String, $preferredMode: Mode, $phoneNumber: String, $bioDescription: String) {
      updateMe(
        name: $name,
        preferredMode: $preferredMode,
        phoneNumber: $phoneNumber,
        bioDescription: $bioDescription
      ) {
        email
        name
        photo
        preferredMode
        birthDate
        bioDescription
        phoneNumber
        createdAt
      }
    }
  ''';

  final MutationOptions options = MutationOptions(
    document: gql(updateUserMutation),
    variables: {
      'name': preferences.nombreCompleto,
      'preferredMode': UserData.mapPreferredModeToAPI(
        preferences.modoPreferido,
      ),
      'phoneNumber': preferences.numeroTelefono.toString(),
      'bioDescription': preferences.descripcion.isEmpty
          ? null
          : preferences.descripcion,
    },
  );

  final QueryResult result = await client.mutate(options);

  if (result.hasException) {
    debugPrint("Error al actualizar usuario: ${result.exception.toString()}");
    throw Exception('Error al actualizar usuario: ${result.exception}');
  }

  debugPrint("Usuario actualizado correctamente en la API");

  // Por ahora, solo simula el guardado
  await Future.delayed(Duration(seconds: 1));
  
  return preferences;
}


// Obtener datos del usuario desde la base de datos
UserData DBfetchUserDataPreferences() {
  debugPrint("========================");
  debugPrint(
    "Capa de Datos: Obteniendo datos estáticos del usuario (fallback)",
  );
  debugPrint("========================");

  // Datos por defecto (fallback cuando no hay datos en Provider)
  return UserData(
    apodo: "Usuario",
    nombreCompleto: "Nombre no disponible",
    fechaNacimiento: DateTime.now(),
    fechaRegistro: DateTime.now(),
    numeroTelefono: 0,
    idiomaPreferido: "Español",
    descripcion: "",
    modoPreferido: "Coche",
  );
}

// TODO: Implementar función para obtener usuario desde GraphQL
/*
ESTA WEA PORQUE NO FUNCIONAA DOLASNDAWSDASD
Future<UserData?> fetchUserDataFromAPI(BuildContext context, String userId) async {
  final GraphQLClient client = GraphQLProvider.of(context).value;
  
  const String getUserQuery = r'''
    query GetUser($userId: ID!) {
      user(id: $userId) {
        id
        username
        name
        email
        phone
        bio
        birthDate
        createdAt
        preferredLanguage
        preferredMode
      }
    }
  ''';
  
  final QueryOptions options = QueryOptions(
    document: gql(getUserQuery),
    variables: {'userId': userId},
  );
  
  final QueryResult result = await client.query(options);
  
  if (result.hasException) {
    debugPrint("Error al obtener usuario: ${result.exception.toString()}");
    return null;
  }
  
  final data = result.data?['user'];
  if (data == null) return null;
  
  return UserData.fromGraphQL(data, userId);
}
*/