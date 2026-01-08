import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nextmove_app/src/funcionalidades/estaciones/dominio/station_model.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/presentacion/bloc/map_bloc.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/presentacion/bloc/map_events.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/presentacion/bloc/map_state.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/presentacion/widgets/toggle_map_mode_widget.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/presentacion/widgets/toggle_map_type_widget.dart';

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

  Widget buildIntegrationHarness() {
    return MaterialApp(
      home: Scaffold(
        body: BlocProvider<MapBloc>.value(
          value: mockBloc,
          child: Stack(
            children: const [
              ToggleMapModeWidget(currentMode: StationType.bicycle),
              MapTypeToggleWidget(currentMapType: MapType.normal),
            ],
          ),
        ),
      ),
    );
  }

  testWidgets('integration: both toggles dispatch events', (tester) async {
    await tester.pumpWidget(buildIntegrationHarness());

    await tester.tap(find.byIcon(Icons.electric_car));
    await tester.pump();

    await tester.tap(find.byIcon(Icons.satellite));
    await tester.pump();

    verify(
      () => mockBloc.add(const ChangeModeEvent(StationType.electricVehicle)),
    ).called(1);
    verify(() => mockBloc.add(const ToggleMapTypeEvent())).called(1);
  });
}
