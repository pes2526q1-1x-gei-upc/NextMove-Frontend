import 'package:dartz/dartz.dart';
import '../entities/user_entity.dart';
import '../repositories/user_repository.dart';
import '../../../../core/errors/failure.dart';

class UpdateUserProfileUseCase {
  final UserRepository repository;

  UpdateUserProfileUseCase(this.repository);

  Future<Either<Failure, bool>> call(UserEntity userEntity, String userId) {
    return repository.updateUserProfile(userEntity, userId);
  }
}