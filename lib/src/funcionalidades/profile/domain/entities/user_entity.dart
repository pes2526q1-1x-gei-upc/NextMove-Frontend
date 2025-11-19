import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String email;
  final String apodo;
  final String nombreCompleto;
  final DateTime fechaNacimiento;
  final DateTime fechaRegistro;
  final int numeroTelefono;
  final String idiomaPreferido;
  final String descripcion;
  final String modoPreferido;

  const UserEntity({
    required this.email,
    required this.apodo,
    required this.nombreCompleto,
    required this.fechaNacimiento,
    required this.fechaRegistro,
    required this.numeroTelefono,
    required this.idiomaPreferido,
    required this.descripcion,
    required this.modoPreferido,
  });

  // Factory: Convierte datos crudos (e.g., de API/GraphQL) a entidad
  factory UserEntity.fromRawData(Map<String, dynamic> data) {
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
    );
  }

  // Método para convertir a mapa (útil para enviar a API)
  Map<String, dynamic> toMap() {
    return {
      'email':email,
      'nickname': apodo,
      'name': nombreCompleto,
      'birthDate': fechaNacimiento.toIso8601String().split('T').first,
      'createdAt': fechaRegistro.toIso8601String(),
      'phoneNumber': numeroTelefono.toString(),
      'preferredLanguage': mapLanguageToAPI(idiomaPreferido),
      'bioDescription': descripcion,
      'preferredMode': mapPreferredModeToAPI(modoPreferido),
    };
  }

  // Mapeo Modo API → Entidad (UI-friendly)
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

  // Mapeo Modo Entidad → API
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

  // Mapeo Idioma API → Entidad (UI-friendly)
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

  // Mapeo Idioma Entidad → API
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
      ];
}