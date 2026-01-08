import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

class UserEntity extends Equatable {
  final String email;
  final String apodo;
  final String photo;
  final String nombreCompleto;
  final DateTime fechaNacimiento;
  final DateTime fechaRegistro;
  final int numeroTelefono;
  final String idiomaPreferido;
  final String descripcion;
  final String modoPreferido;
  final bool? regWithGoogle;
  final UserStatistics? statistics;

  const UserEntity({
    required this.email,
    required this.apodo,
    required this.photo,
    required this.nombreCompleto,
    required this.fechaNacimiento,
    required this.fechaRegistro,
    required this.numeroTelefono,
    required this.idiomaPreferido,
    required this.descripcion,
    required this.modoPreferido,
    this.regWithGoogle,
    this.statistics,
  });

  factory UserEntity.fromRawData(Map<String, dynamic> data) {
    if (kDebugMode) {
      print('UserEntity.fromRawData: $data');
    }
    return UserEntity(
      email: data['email'],
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
      photo: data['photo'] ?? '',
      regWithGoogle: data['regWithGoogle'] ?? false,
      statistics: data['statistics'] != null
          ? UserStatistics(
              totalRoutes: data['statistics']['num_rutas'] ?? 0,
              distance: (data['statistics']['km_recorridos'] ?? 0).toDouble(),
              elevationGain: (data['statistics']['elevacion_positiva'] ?? 0)
                  .toDouble(),
              caloriesBurned: (data['statistics']['calorias_quemadas'] ?? 0)
                  .toDouble(),
              co2Saved: (data['statistics']['co2_ahorrado'] ?? 0).toDouble(),
              challengesParticipated:
                  (data['statistics']['num_retos_participados'] ?? 0).toDouble(),
              challengesCompleted:
                  (data['statistics']['num_retos_completados'] ?? 0).toDouble(),
              points: (data['statistics']['puntos_totales'] ?? 0).toInt(),
            )
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'nickname': apodo,
      'name': nombreCompleto,
      'birthDate': fechaNacimiento.toIso8601String().split('T').first,
      'createdAt': fechaRegistro.toIso8601String(),
      'phoneNumber': numeroTelefono.toString(),
      'preferredLanguage': mapLanguageToAPI(idiomaPreferido),
      'bioDescription': descripcion,
      'preferredMode': mapPreferredModeToAPI(modoPreferido),
      'photo': photo,
      'regWithGoogle': regWithGoogle,
    };
  }

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

  static String mapPreferredModeToAPI(String localMode) {
    switch (localMode) {
      case 'Bicicleta':
      case 'BIKE':
        return 'BIKE';
      case 'Coche':
      case 'CAR':
        return 'CAR';
      default:
        return 'CAR';
    }
  }

  static String mapLanguageFromAPI(String? apiLang) {
    switch (apiLang?.toLowerCase()) {
      case 'es':
      case 'esp':
        return 'Español';
      case 'en':
      case 'eng':
        return 'English';
      case 'ca':
      case 'cat':
        return 'Català';
      default:
        return 'Español';
    }
  }

  static String mapLanguageToAPI(String uiLang) {
    switch (uiLang) {
      case 'Español':
        return 'ESP';
      case 'English':
        return 'ENG';
      case 'Català':
        return 'CAT';
      default:
        return 'ESP';
    }
  }

  UserEntity copyWith({
    String? email,
    String? apodo,
    String? nombreCompleto,
    DateTime? fechaNacimiento,
    DateTime? fechaRegistro,
    int? numeroTelefono,
    String? idiomaPreferido,
    String? descripcion,
    String? modoPreferido,
    String? photo,
  }) {
    return UserEntity(
      email: email ?? this.email,
      apodo: apodo ?? this.apodo,
      nombreCompleto: nombreCompleto ?? this.nombreCompleto,
      fechaNacimiento: fechaNacimiento ?? this.fechaNacimiento,
      fechaRegistro: fechaRegistro ?? this.fechaRegistro,
      numeroTelefono: numeroTelefono ?? this.numeroTelefono,
      idiomaPreferido: idiomaPreferido ?? this.idiomaPreferido,
      descripcion: descripcion ?? this.descripcion,
      modoPreferido: modoPreferido ?? this.modoPreferido,
      photo: photo ?? this.photo,
      regWithGoogle: regWithGoogle,
    );
  }

  @override
  List<Object?> get props => [
    email,
    apodo,
    nombreCompleto,
    fechaNacimiento,
    fechaRegistro,
    numeroTelefono,
    idiomaPreferido,
    descripcion,
    modoPreferido,
    photo,
    regWithGoogle,
  ];
}

class UserStatistics {
  final int totalRoutes;
  final double distance;
  final double co2Saved;
  final double caloriesBurned;
  final double elevationGain;
  final double challengesParticipated;
  final double challengesCompleted;
  final int points;

  UserStatistics({
    required this.totalRoutes,
    required this.distance,
    required this.elevationGain,
    required this.caloriesBurned,
    required this.co2Saved,
    required this.challengesParticipated,
    required this.challengesCompleted,
    required this.points,
  });
}
