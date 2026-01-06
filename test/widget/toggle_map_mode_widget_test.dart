import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nextmove_app/src/funcionalidades/estaciones/dominio/station_model.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/presentacion/bloc/map_bloc.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/presentacion/bloc/map_events.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/presentacion/bloc/map_state.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/presentacion/widgets/toggle_map_mode_widget.dart';

class MockMapBloc extends MockBloc<MapEvent, MapState> implements MapBloc {}

void main() {
  late MockMapBloc mockBloc;

  setUp(() {
    mockBloc = MockMapBloc();
    when(() => mockBloc.state).thenReturn(const MapInitialState());
  });

  tearDown(() {
    reset(mockBloc);
  });

  Widget buildHarness(StationType mode) {
    return MaterialApp(
      home: Scaffold(
        body: BlocProvider<MapBloc>.value(
          value: mockBloc,
          child: Stack(
            children: [
              ToggleMapModeWidget(currentMode: mode),
            ],
          ),
        ),
      ),
    );
  }

  testWidgets('taps send ChangeModeEvent for bicycle', (tester) async {
    await tester.pumpWidget(buildHarness(StationType.electricVehicle));

    await tester.tap(find.byIcon(Icons.directions_bike));
    await tester.pump();

    verify(() => mockBloc.add(const ChangeModeEvent(StationType.bicycle)))
        .called(1);
  });

  testWidgets('taps send ChangeModeEvent for electric vehicle', (tester) async {
    await tester.pumpWidget(buildHarness(StationType.bicycle));

    await tester.tap(find.byIcon(Icons.electric_car));
    await tester.pump();

    verify(
      () => mockBloc.add(const ChangeModeEvent(StationType.electricVehicle)),
    ).called(1);
  });
}
