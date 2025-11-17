import 'package:dartz/dartz.dart';
import 'package:nextmove_app/src/funcionalidades/profile/data/repositories/user_repository.dart';
import '../entities/user_entity.dart';
import '../../../../core/errors/failure.dart';

class UpdateUserProfileUseCase {
  final UserRepository repository;

  UpdateUserProfileUseCase(this.repository);

  Future<Either<Failure, bool>> call(UserEntity userEntity, String userId) {
    return repository.updateUserProfile(userEntity, userId);
  }
}