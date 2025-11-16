import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'station_list_event.dart';
part 'station_list_state.dart';

class StationListBloc extends Bloc<StationListEvent, StationListState> {
  StationListBloc() : super(StationListInitial()) {
    on<StationListEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
