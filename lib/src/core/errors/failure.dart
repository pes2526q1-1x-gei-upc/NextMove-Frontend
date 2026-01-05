// lib/core/errors/failure.dart

abstract class Failure {
  final String? message;

  const Failure({this.message});
}

// Fallo genérico de servidor/API
class ServerFailure extends Failure {
  const ServerFailure({super.message});
}

// Fallo de autenticación (e.g., usuario no logueado)
class AuthFailure extends Failure {
  const AuthFailure({super.message});
}

// Fallo de conexión (e.g., sin internet)
class ConnectionFailure extends Failure {
  const ConnectionFailure({super.message = 'Sin conexión a internet'});
}

// Fallo genérico para casos inesperados
class UnknownFailure extends Failure {
  const UnknownFailure({super.message = 'Error desconocido'});
}

class ValidationFailure extends Failure {
  ValidationFailure({String? message}) : super(message: message ?? 'Validation failed');
}