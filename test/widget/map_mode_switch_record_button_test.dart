import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/presentacion/widgets/map_controls_column_widget.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/presentacion/bloc/map_bloc.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/presentacion/bloc/map_events.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/presentacion/bloc/map_state.dart';
import 'package:nextmove_app/src/funcionalidades/estaciones/dominio/station_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MockMapBloc extends MockBloc<MapEvent, MapState> implements MapBloc {}

void main() {
  late MockMapBloc mockBloc;

  setUp(() {
    mockBloc = MockMapBloc();
  });

  tearDown(() {
    reset(mockBloc);
  });

  Widget buildWidget(MapLoadedState state) {
    when(() => mockBloc.state).thenReturn(state);
    return MaterialApp(
      home: Stack(
        children: [
          BlocProvider<MapBloc>.value(
            value: mockBloc,
            child: MapControlsColumnWidget(
              userLocation: const LatLng(41.3851, 2.1734),
              mapController: null,
              currentMapType: MapType.normal,
            ),
          ),
          if (state.currentMode == StationType.bicycle)
            Positioned(
              bottom: 30,
              right: 16,
              child: Container(
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: state.isRecordingRoute ? Colors.red : Colors.green,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      state.isRecordingRoute ? Icons.stop : Icons.play_arrow,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      state.isRecordingRoute ? 'Stop' : 'Start',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  testWidgets('shows record buttons in bicycle mode', (WidgetTester tester) async {
    final state = MapLoadedState(
      bikeStations: [],
      evStations: [],
      promotedCompanies: [],
      currentMode: StationType.bicycle,
      currentMapType: MapType.normal,
      bikeMarkers: {},
      carMarkers: {},
      companyMarkers: {},
      centerPosition: const LatLng(41.3851, 2.1734),
      isSearching: false,
      routePolyline: const Polyline(polylineId: PolylineId(''), points: []),
      isRecordingRoute: false,
      companyClusterManager: null,
    );

    await tester.pumpWidget(buildWidget(state));

    expect(find.byIcon(Icons.play_arrow), findsOneWidget);
    expect(find.byIcon(Icons.bar_chart), findsNothing);
  });

  testWidgets('hides record buttons in car mode', (WidgetTester tester) async {
    final state = MapLoadedState(
      bikeStations: [],
      evStations: [],
      promotedCompanies: [],
      currentMode: StationType.electricVehicle,
      currentMapType: MapType.normal,
      bikeMarkers: {},
      carMarkers: {},
      companyMarkers: {},
      centerPosition: const LatLng(41.3851, 2.1734),
      isSearching: false,
      routePolyline: const Polyline(polylineId: PolylineId(''), points: []),
      isRecordingRoute: false,
      companyClusterManager: null,
    );

    await tester.pumpWidget(buildWidget(state));

    expect(find.byIcon(Icons.play_arrow), findsNothing);
    expect(find.byIcon(Icons.bar_chart), findsNothing);
  });

  testWidgets('shows statistics button when recording in bicycle mode', (WidgetTester tester) async {
    final state = MapLoadedState(
      bikeStations: [],
      evStations: [],
      promotedCompanies: [],
      currentMode: StationType.bicycle,
      currentMapType: MapType.normal,
      bikeMarkers: {},
      carMarkers: {},
      companyMarkers: {},
      centerPosition: const LatLng(41.3851, 2.1734),
      isSearching: false,
      routePolyline: const Polyline(polylineId: PolylineId(''), points: []),
      isRecordingRoute: true,
      companyClusterManager: null,
    );

    await tester.pumpWidget(buildWidget(state));

    expect(find.byIcon(Icons.stop), findsOneWidget);
    expect(find.byIcon(Icons.bar_chart), findsOneWidget);
  });
}