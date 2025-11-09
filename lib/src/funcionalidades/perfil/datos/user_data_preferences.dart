import 'package:firebase_auth/firebase_auth.dart';
import 'package:nextmove_app/src/funcionalidades/perfil/dominio/user_data_preferences.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:flutter/material.dart';

// Enviar datos del usuario a la API
Future<UserData> pushUserDataPreferences(
  UserData preferences,
  BuildContext context,
) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) throw Exception("Usuario no autenticado");

  final email = user.email;
  if (email == null) throw Exception("Email no disponible");

  debugPrint("========================");
  debugPrint("Actualizando usuario con email: $email");
  debugPrint("Nombre: ${preferences.nombreCompleto}");
  debugPrint("Apodo: ${preferences.apodo}");
  debugPrint("Teléfono: ${preferences.numeroTelefono}");
  debugPrint("Fecha nacimiento: ${preferences.fechaNacimiento}");

  final GraphQLClient client = GraphQLProvider.of(context).value;
  
  const String updateUserMutation = r'''
    mutation UpdateMe(
      $email: String!
      $name: String
      $nickname: String
      $phoneNumber: String
      $bioDescription: String
      $preferredMode: Mode
      $preferredLanguage: String
      $birthDate: String
    ) {
      updateMe(
        email: $email
        name: $name
        nickname: $nickname
        phoneNumber: $phoneNumber
        bioDescription: $bioDescription
        preferredMode: $preferredMode
        preferredLanguage: $preferredLanguage
        birthDate: $birthDate
      ) {
        email
        name
        nickname
        phoneNumber
        bioDescription
        preferredMode
        preferredLanguage
        birthDate
      }
    }
  ''';

  // FORMATEO DE FECHA: "YYYY-MM-DD"
  String? formatBirthDate(DateTime? date) {
    if (date == null) return null;
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  // TELÉFONO: solo si no es 0 o vacío
  String? formatPhone(int? phone) {
    if (phone == null || phone == 0) return null;
    return phone.toString();
  }

  final MutationOptions options = MutationOptions(
    document: gql(updateUserMutation),
    variables: {
      'email': email,
      'name': preferences.nombreCompleto?.trim().isEmpty == true ? null : preferences.nombreCompleto?.trim(),
      'nickname': preferences.apodo?.trim().isEmpty == true ? null : preferences.apodo?.trim(),
      'phoneNumber': formatPhone(preferences.numeroTelefono),
      'bioDescription': preferences.descripcion.trim().isEmpty ? null : preferences.descripcion.trim(),
      'preferredMode': UserData.mapPreferredModeToAPI(preferences.modoPreferido),
      'preferredLanguage': UserData.mapLanguageToAPI(preferences.idiomaPreferido),
      'birthDate': formatBirthDate(preferences.fechaNacimiento),
    },
  );

  final QueryResult result = await client.mutate(options);

  if (result.hasException) {
    debugPrint("ERROR GraphQL: ${result.exception}");
    for (var err in result.exception?.graphqlErrors ?? []) {
      debugPrint("GraphQL Error: ${err.message}");
    }
    throw Exception('Error al actualizar: ${result.exception}');
  }

  final data = result.data?['updateMe'];
  if (data == null) {
    throw Exception("No se actualizó el usuario con email: $email");
  }

  debugPrint("Usuario actualizado correctamente: $data");
  return preferences;
}

// Obtener datos del usuario desde la base de datos
UserData DBfetchUserDataPreferences() {
  debugPrint("========================");
  debugPrint(
    "Capa de Datos: Obteniendo datos estáticos del usuario (fallback)",
  );
  debugPrint("========================");

  return UserData(
    apodo: "Usuario",
    nombreCompleto: "Nombre no disponible",
    fechaNacimiento: DateTime.now(),
    fechaRegistro: DateTime.now(),
    numeroTelefono: 0,
    idiomaPreferido: "Español", // Valor de UI por defecto
    descripcion: "",
    modoPreferido: "Coche", // Valor de UI por defecto
  );
}