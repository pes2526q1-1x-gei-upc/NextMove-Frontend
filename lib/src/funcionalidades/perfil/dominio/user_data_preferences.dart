import 'package:nextmove_app/src/funcionalidades/perfil/datos/user_data_preferences.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nextmove_app/src/funcionalidades/auth/dominio/providers/user_provider.dart';

class UserData {
  final String apodo;
  final String nombreCompleto;
  final DateTime fechaNacimiento;
  final DateTime fechaRegistro;
  final int numeroTelefono;
  final String idiomaPreferido;
  final String descripcion;
  final String modoPreferido;
  final bool needsToRegister;

  UserData({
    required this.apodo,
    required this.nombreCompleto,
    required this.fechaNacimiento,
    required this.fechaRegistro,
    required this.numeroTelefono,
    required this.idiomaPreferido,
    required this.descripcion,
    required this.modoPreferido,
    required this.needsToRegister,
  });

  // === FACTORY: CONVIERTE DATOS DE GRAPHQL A UI ===
  factory UserData.fromGraphQL(Map<String, dynamic> data, String firebaseUserId) {
    return UserData(
      apodo: data['nickname'] ?? 'Usuario',
      nombreCompleto: data['name'] ?? 'Nombre no disponible',
      fechaNacimiento: data['birthDate'] != null
          ? DateTime.parse(data['birthDate'])
          : DateTime.now(),
      fechaRegistro: data['createdAt'] != null
          ? DateTime.parse(data['createdAt'])
          : DateTime.now(),
      numeroTelefono: data['phoneNumber'] != null
          ? int.tryParse(data['phoneNumber'].toString()) ?? 0
          : 0,
      idiomaPreferido: mapLanguageFromAPI(data['preferredLanguage']), 
      descripcion: data['bioDescription'] ?? '',
      modoPreferido: mapPreferredModeFromAPI(data['preferredMode']),
      needsToRegister: data['needsToRegister'] ?? false,
    );
  }

  // === Mapeo Modo API → UI ===
  static String mapPreferredModeFromAPI(String? apiMode) {
    switch (apiMode?.toUpperCase()) {
      case 'BIKE':
        return 'Bicicleta';
      case 'CAR':
        return 'Coche';
      default:
        return 'Coche';
    }
  }

  // === Mapeo Modo UI → API ===
  static String mapPreferredModeToAPI(String localMode) {
    switch (localMode) {
      case 'Bicicleta':
        return 'BIKE';
      case 'Coche':
        return 'CAR';
      default:
        return 'CAR';
    }
  }

  // === MAPEAMIENTO DE IDIOMA AÑADIDO ===

  // === Mapeo Idioma API → UI ===
  static String mapLanguageFromAPI(String? apiLang) {
    switch (apiLang?.toLowerCase()) {
      case 'es':
        return 'Español';
      case 'en':
        return 'English';
      case 'ca':
        return 'Català';
      default:
        return 'Español'; // Idioma por defecto de la UI
    }
  }

  // === Mapeo Idioma UI → API ===
  static String mapLanguageToAPI(String uiLang) {
    switch (uiLang) {
      case 'Español':
        return 'es';
      case 'English':
        return 'en';
      case 'Català':
        return 'ca';
      default:
        return 'es';
    }
  }
}

// === LEER DESDE UserProvider ===
UserData? fetchUserDataPreferencesFromProvider(BuildContext context) {
  final userProvider = Provider.of<UserProvider>(context, listen: false);
  final userData = userProvider.user;
  final firebaseUserId = userProvider.firebaseUserId;

  if (userData == null || firebaseUserId == null) return null;

  return UserData.fromGraphQL(userData, firebaseUserId);
}

// === ENVIAR A CAPA DE DATOS ===
void sendUserDataPreferences(UserData preferences, BuildContext context) {
  pushUserDataPreferences(preferences, context);
}

// === OBTENER FALLBACK ===
UserData fetchUserDataPreferences() {
  return DBfetchUserDataPreferences();
}

// === ACTUALIZAR + SINCRONIZAR CON PROVIDER ===
Future<void> updateUserDataPreferences(UserData preferences, BuildContext context) async {
  debugPrint("Dominio: Actualizando preferencias del usuario");

  await pushUserDataPreferences(preferences, context);

  final userProvider = Provider.of<UserProvider>(context, listen: false);
  final currentUser = userProvider.user;

  if (currentUser != null) {
    final updatedUser = Map<String, dynamic>.from(currentUser);
    updatedUser['name'] = preferences.nombreCompleto;
    updatedUser['nickname'] = preferences.apodo;
    updatedUser['phoneNumber'] = preferences.numeroTelefono.toString();
    updatedUser['bioDescription'] = preferences.descripcion;
    updatedUser['preferredMode'] = UserData.mapPreferredModeToAPI(preferences.modoPreferido);
    updatedUser['preferredLanguage'] = UserData.mapLanguageToAPI(preferences.idiomaPreferido);
    
    
    updatedUser['birthDate'] = preferences.fechaNacimiento.toIso8601String().split('T').first;

    userProvider.setUser(
      updatedUser,
      firebaseUserId: userProvider.firebaseUserId,
      firebaseToken: userProvider.firebaseToken,
    );

    debugPrint("Provider actualizado correctamente");
  }
}