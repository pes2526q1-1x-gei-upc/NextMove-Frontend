import '../../domain/entities/user_entity.dart';

class UserLocalDataProvider {
  // Fallback estático (como en tu código)
  UserEntity getFallbackUserProfile() {
    return UserEntity(
      email: "Correo",
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

  // Si necesitas update local, agrégalo (e.g., para cache), pero por ahora no aplica.
}