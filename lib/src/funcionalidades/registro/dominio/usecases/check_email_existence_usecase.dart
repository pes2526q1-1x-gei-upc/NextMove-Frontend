

import 'package:dartz/dartz.dart';
import 'package:nextmove_app/src/core/errors/failure.dart';
import 'package:nextmove_app/src/funcionalidades/registro/dominio/repositories/auth_repository.dart';

class CheckEmailExistenceUseCase {
  final AuthRepository repository;

  CheckEmailExistenceUseCase({required this.repository});

  Future<Either<Failure, bool>> call(String email) async {
    return await repository.isEmailRegistered(email);
  }
}