import 'package:dartz/dartz.dart';
import 'package:nextmove_app/src/core/errors/failure.dart';
import 'package:nextmove_app/src/core/errors/exceptions.dart';
import 'package:nextmove_app/src/funcionalidades/profile/domain/entities/user_entity.dart';
import 'package:nextmove_app/src/funcionalidades/social/data/dataproviders/social_remote_data_provider.dart';

class SocialRepository {
  final SocialRemoteDataProvider remoteDataProvider;

  SocialRepository() : remoteDataProvider = SocialRemoteDataProvider();

  Future<Either<Failure, List<UserEntity>>> getFriends(String nickname) async {
    try {
      final friends = await remoteDataProvider.getFriends(nickname);
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

  Future<Either<Failure, void>> addFriend(String myNick, String friendNick) async {
    try {
      await remoteDataProvider.addFriend(myNick, friendNick);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.toString()));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, void>> removeFriend(String myNick, String friendNick) async {
    try {
      await remoteDataProvider.removeFriend(myNick, friendNick);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.toString()));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}