import '../../domain/entities/user_entity.dart';

class UserLocalDataProvider {
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
      photo: "",
    );
  }
}