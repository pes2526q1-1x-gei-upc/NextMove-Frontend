import 'package:equatable/equatable.dart';
import 'package:nextmove_app/src/funcionalidades/recorridos/domain/recorded_route.dart';

abstract class RouteState extends Equatable {
  const RouteState();

  @override
  List<Object?> get props => [];
}

class RouteInitialState extends RouteState {
  const RouteInitialState();
}

class RouteLoadingState extends RouteState {
  const RouteLoadingState();
}

class RouteLoadedState extends RouteState {
  final List<RecordedRoute> recordedRoutes;

  const RouteLoadedState({this.recordedRoutes = const []});

  @override
  List<Object?> get props => [recordedRoutes];

  RouteLoadedState copyWith({
    List<RecordedRoute>? recordedRoutes,
  }) {
    return RouteLoadedState(
      recordedRoutes: recordedRoutes ?? this.recordedRoutes,
    );
  }
}

class RouteErrorState extends RouteState {
  final String? message;

  const RouteErrorState(this.message);

  @override
  List<Object?> get props => [message];
}