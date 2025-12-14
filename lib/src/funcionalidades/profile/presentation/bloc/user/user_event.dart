import 'package:equatable/equatable.dart';
import '../../../domain/entities/user_entity.dart';

import 'dart:io';

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
  final File? profilePhoto;

  const UpdateUserProfile(this.updatedUser, {this.profilePhoto});

  @override
  List<Object?> get props => [updatedUser, profilePhoto];
}

class CreateUserProfile extends UserEvent {
  final UserEntity newUser;
  const CreateUserProfile(this.newUser);

  @override
  List<Object?> get props => [newUser];
}

class LogoutUser extends UserEvent {
  @override
  List<Object?> get props => [];
}
