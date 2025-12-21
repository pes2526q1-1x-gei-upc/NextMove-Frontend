import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'ranking_event.dart';
part 'ranking_state.dart';

class RankingBloc extends Bloc<RankingEvent, RankingState> {
  RankingBloc() : super(RankingInitial()) {
    on<RankingEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
