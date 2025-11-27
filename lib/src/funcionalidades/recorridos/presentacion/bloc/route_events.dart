import 'package:equatable/equatable.dart';

abstract class RouteEvent extends Equatable {
  const RouteEvent();

  @override
  List<Object?> get props => [];

}

class LoadRecordedRoutesEvent extends RouteEvent {
  final String userEmail;
  const LoadRecordedRoutesEvent(this.userEmail);

  @override
  List<Object?> get props => [userEmail];
}