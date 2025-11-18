// lib/core/errors/failure.dart

abstract class Failure {
  final String? message;

  const Failure({this.message});
}

// Fallo genérico de servidor/API
class ServerFailure extends Failure {
  const ServerFailure({String? message}) : super(message: message);
}

// Fallo de autenticación (e.g., usuario no logueado)
class AuthFailure extends Failure {
  const AuthFailure({String? message}) : super(message: message);
}

// Fallo de conexión (e.g., sin internet)
class ConnectionFailure extends Failure {
  const ConnectionFailure({String? message = 'Sin conexión a internet'}) : super(message: message);
}

// Fallo genérico para casos inesperados
class UnknownFailure extends Failure {
  const UnknownFailure({String? message = 'Error desconocido'}) : super(message: message);
}