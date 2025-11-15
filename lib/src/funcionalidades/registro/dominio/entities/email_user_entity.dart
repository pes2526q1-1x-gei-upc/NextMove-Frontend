import 'package:equatable/equatable.dart';

class EmailUserEntity extends Equatable {
  final String email;
  final String password;

  const EmailUserEntity({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}