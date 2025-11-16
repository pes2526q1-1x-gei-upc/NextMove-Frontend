import 'package:dartz/dartz.dart';
import '../entities/user_entity.dart';
import '../repositories/user_repository.dart';
import 'package:nextmove_app/src/core/errors/failure.dart';

class GetUserProfileUseCase {
  final UserRepository repository;

  GetUserProfileUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call(String userId) {
    return repository.getUserProfile(userId);
  }
}