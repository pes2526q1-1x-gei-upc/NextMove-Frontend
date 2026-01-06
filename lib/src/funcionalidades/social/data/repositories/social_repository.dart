import 'package:dartz/dartz.dart';
import 'package:flutter/cupertino.dart';
import 'package:nextmove_app/src/core/errors/failure.dart';
import 'package:nextmove_app/src/core/errors/exceptions.dart';
import 'package:nextmove_app/src/funcionalidades/profile/domain/entities/user_entity.dart';
import 'package:nextmove_app/src/funcionalidades/social/data/dataproviders/social_remote_data_provider.dart';

class SocialRepository {
  final SocialRemoteDataProvider remoteDataProvider;

  SocialRepository({SocialRemoteDataProvider? remoteDataProvider})
      : remoteDataProvider = remoteDataProvider ?? SocialRemoteDataProvider();

  Future<Either<Failure, List<UserEntity>>> getFriends() async {
    try {
      final friends = await remoteDataProvider.getFriends();
      return Right(friends);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.toString()));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, List<UserEntity>>> searchUsers(String query) async {
    try {
      final users = await remoteDataProvider.searchUsers(query);
      return Right(users);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.toString()));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, void>> addFriend(String friendNick) async {
    try {
      await remoteDataProvider.addFriend(friendNick);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.toString()));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, void>> removeFriend(String friendNick) async {
    try {
      await remoteDataProvider.removeFriend(friendNick);
      return const Right(null);
    } on ServerException catch (e) {
      debugPrint("Error en removeFriend: ${e.toString()}");
      return Left(ServerFailure(message: e.toString()));
    } catch (e) {
      debugPrint("Error genérico en removeFriend: ${e.toString()}");
      return Left(ServerFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, void>> blockUser(String userToBlockNick) async {
    try {
      await remoteDataProvider.blockUser(userToBlockNick);
      return const Right(null);
    } on ServerException catch (e) {
      debugPrint("Error en blockUser: ${e.toString()}");
      return Left(ServerFailure(message: e.toString()));
    } catch (e) {
      debugPrint("Error genérico en blockUser: ${e.toString()}");
      return Left(ServerFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, List<UserEntity>>> getBlockedUsers() async {
    try {
      final blockedUsers = await remoteDataProvider.getBlockedUsers();
      return Right(blockedUsers);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.toString()));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, void>> unblockUser(String userToUnblockNick) async {
    try {
      await remoteDataProvider.unblockUser(userToUnblockNick);
      return const Right(null);
    } on ServerException catch (e) {
      debugPrint("Error en unblockUser: ${e.toString()}");
      return Left(ServerFailure(message: e.toString()));
    } catch (e) {
      debugPrint("Error genérico en unblockUser: ${e.toString()}");
      return Left(ServerFailure(message: e.toString()));
    }
  }
}