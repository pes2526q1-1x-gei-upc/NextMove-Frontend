import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:nextmove_app/src/funcionalidades/estaciones/dominio/station_model.dart';

part 'station_details_event.dart';
part 'station_details_state.dart';

class StationDetailsBloc extends Bloc<StationDetailsEvent, StationDetailsState> {
  StationDetailsBloc() : super(StationDetailsInitial()) {
    on<StationDetailsEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
