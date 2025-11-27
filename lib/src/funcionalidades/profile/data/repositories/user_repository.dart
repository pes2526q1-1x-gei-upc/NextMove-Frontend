import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
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
    } on custom_exceptions.ServerException catch (e) {
      return Left(ServerFailure(message: e.toString()));
    } on custom_exceptions.AuthException catch (e) {
      return Left(AuthFailure(message: e.toString()));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, UserEntity>> updateUserProfile(UserEntity userEntity) async {
    try {
      final updatedUser = await remoteDataProvider.updateUserProfile(userEntity);
      return Right(updatedUser);
    } on custom_exceptions.ServerException catch (e) {
      return Left(ServerFailure(message: e.toString()));
    } on custom_exceptions.AuthException catch (e) {
      return Left(AuthFailure(message: e.toString()));
    } catch (e) {
      if (kDebugMode) {
        print('Error desconocido al actualizar perfil: $e');
      }
      return Left(ServerFailure());
    }
  }

  Future<Either<Failure, UserEntity>> createUserProfile(UserEntity userEntity) async {
    try {
      final createdUser = await remoteDataProvider.createUserProfile(userEntity);
      return Right(createdUser);
    } on custom_exceptions.ServerException catch (e) {
      return Left(ServerFailure(message: e.toString()));
    } on custom_exceptions.AuthException catch (e) {
      return Left(AuthFailure(message: e.toString()));
    } catch (e) {
      return Left(ServerFailure());
    }
    
  }


  Future<Either<Failure, void>> logoutUser() async {
    try {
      await remoteDataProvider.logout();
      return const Right(null); // Void return
    } catch (e) {
      return Left(AuthFailure(message: e.toString()));
    }
  }


}