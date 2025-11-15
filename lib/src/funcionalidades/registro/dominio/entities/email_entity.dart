import 'package:equatable/equatable.dart';

class EmailEntity extends Equatable {
  final String email;

  const EmailEntity({required this.email});

  @override
  List<Object> get props => [email];
}