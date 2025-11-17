import 'package:dartz/dartz.dart';
import '../../domain/entities/user_entity.dart';
import 'package:nextmove_app/src/core/errors/failure.dart';
import 'package:nextmove_app/src/core/errors/exceptions.dart' as custom_exceptions;
import '../dataproviders/user_remote_data_provider.dart';
import '../dataproviders/user_local_data_provider.dart';

class UserRepository {
  final UserRemoteDataProvider remoteDataProvider;
  final UserLocalDataProvider localDataProvider;

  UserRepository() : remoteDataProvider = UserRemoteDataProvider(), localDataProvider = UserLocalDataProvider();

  Future<Either<Failure, UserEntity>> getUserProfile(String userId) async {
    try {
      final user = await remoteDataProvider.getUserProfile(userId);
      return Right(user);
    } on custom_exceptions.ServerException {
      return Left(ServerFailure());
    } on custom_exceptions.AuthException {
      return Left(AuthFailure());
    } catch (e) {
      // Fallback a local si remote falla
      return Right(localDataProvider.getFallbackUserProfile());
    }
  }

  Future<Either<Failure, bool>> updateUserProfile(UserEntity userEntity, String userId) async {
    try {
      await remoteDataProvider.updateUserProfile(userEntity);
      return const Right(true);
    } on custom_exceptions.ServerException {
      return Left(ServerFailure());
    } on custom_exceptions.AuthException {
      return Left(AuthFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  Future<Either<Failure, bool>> createUserProfile(UserEntity userEntity, String pwd) async {
    try {
      //await remoteDataSource.createUserProfile(userEntity, pwd);
      return const Right(true);
    } on custom_exceptions.ServerException {
      return Left(ServerFailure());
    } on custom_exceptions.AuthException {
      return Left(AuthFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
    
  }
}