import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/presentacion/bloc/map_bloc.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/presentacion/bloc/map_events.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/presentacion/bloc/map_state.dart';
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

  Widget buildHarness(MapType currentType) {
    return MaterialApp(
      home: Scaffold(
        body: BlocProvider<MapBloc>.value(
          value: mockBloc,
          child: Stack(
            children: [
              MapTypeToggleWidget(currentMapType: currentType),
            ],
          ),
        ),
      ),
    );
  }

  testWidgets('tapping toggles map type dispatches event', (tester) async {
    await tester.pumpWidget(buildHarness(MapType.normal));

    await tester.tap(find.byIcon(Icons.satellite));
    await tester.pump();

    verify(() => mockBloc.add(const ToggleMapTypeEvent())).called(1);
  });

  testWidgets('renders icon based on current map type', (tester) async {
    await tester.pumpWidget(buildHarness(MapType.normal));
    expect(find.byIcon(Icons.satellite), findsOneWidget);

    await tester.pumpWidget(buildHarness(MapType.satellite));
    expect(find.byIcon(Icons.map), findsOneWidget);
  });
}
