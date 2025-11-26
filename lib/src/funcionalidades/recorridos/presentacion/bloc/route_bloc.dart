import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:nextmove_app/src/funcionalidades/recorridos/data/repositories/recorded_routes_repository.dart';
import 'route_events.dart';
import 'route_state.dart';

class RouteBloc extends Bloc<RouteEvent, RouteState> {
  final RecordedRoutesRepository recordedRoutesRepository;

  RouteBloc() : recordedRoutesRepository = RecordedRoutesRepository(),
      super(const RouteInitialState()) {
    on<LoadRecordedRoutesEvent>(_onLoadRecordedRoutes);
  }

  Future<void> _onLoadRecordedRoutes(
      LoadRecordedRoutesEvent event, 
      Emitter<RouteState> emit
    ) async {
        emit(const RouteLoadingState());
        final result =
            await recordedRoutesRepository.getRecordedRoutesByUser(event.userEmail);

        result.fold(
          (failure) {
            emit(RouteErrorState(failure.message));
          },
          (recordedRoutes) {
            emit(RouteLoadedState(recordedRoutes: recordedRoutes));
          },
        );
    }
}