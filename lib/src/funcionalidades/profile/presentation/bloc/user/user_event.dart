import 'package:equatable/equatable.dart';
import '../../../domain/entities/user_entity.dart';

abstract class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object?> get props => [];
}

class LoadUserProfile extends UserEvent {
  final String userId;  
  const LoadUserProfile(this.userId);

  @override
  List<Object?> get props => [userId];
}

class UpdateUserProfile extends UserEvent {
  final UserEntity updatedUser;
  const UpdateUserProfile(this.updatedUser);

  @override
  List<Object?> get props => [updatedUser];
}

class CreateUserProfile extends UserEvent {
  final UserEntity newUser;
  const CreateUserProfile(this.newUser);

  @override
  List<Object?> get props => [newUser];
}