import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nextmove_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:nextmove_app/src/funcionalidades/estaciones/dominio/station_model.dart';
import 'package:nextmove_app/src/funcionalidades/estaciones/dominio/stations_cache.dart';
import 'package:nextmove_app/src/funcionalidades/estaciones/datos/repositories/station_repository.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/data/repositories/track_repository.dart';
import 'package:nextmove_app/src/funcionalidades/recorridos/data/repositories/recorded_routes_repository.dart';

// Imports del BLoC
import 'package:nextmove_app/src/funcionalidades/mapa/presentacion/bloc/map_bloc.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/presentacion/bloc/map_events.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/presentacion/bloc/map_state.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/data/services/search_history_service.dart';

import 'package:nextmove_app/src/funcionalidades/mapa/presentacion/widgets/route_history_button_widget.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/presentacion/widgets/search_results_list.dart';

import 'package:nextmove_app/src/funcionalidades/estaciones/presentacion/widgets/station_bottom_sheet_widget.dart';

import 'widgets/google_map_widget.dart';
import 'widgets/toggle_map_mode_widget.dart';

import 'widgets/search_bar_widget.dart';
import 'package:nextmove_app/src/funcionalidades/estaciones/presentacion/widgets/station_list_widget.dart';
import 'widgets/map_controls_column_widget.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});
  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  // -----------------------------------------------------------------------
  // Controllers & state
  // -----------------------------------------------------------------------
  GoogleMapController? _mapController;
  List<StationDetails> stations = [];
  List<StationDetails> bikeStations = [];
  StationRepository stationRepository = StationRepository();
  TrackRepository trackRepository = TrackRepository();
  RecordedRoutesRepository recordedRoutesRepository = RecordedRoutesRepository();
  //final LatLng _catCenter = const LatLng(41.8205, 1.8677);
  final LatLng _bcnCenter = const LatLng(41.3851, 2.1734);
  final searchHistoryService = SearchHistoryService();
  bool _isSearchBarFocused = false;

  
  StreamSubscription<Position>? _positionStream;

  @override
  void dispose() {
    _mapController?.dispose();
    _positionStream?.cancel();
    super.dispose();
  }

  // -----------------------------------------------------------------------
  // Map callbacks
  // -----------------------------------------------------------------------
  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  // -----------------------------------------------------------------------
  // UI helpers
  // -----------------------------------------------------------------------

  // -----------------------------------------------------------------------
  // Build
  // -----------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MapBloc(
        stationRepository: stationRepository,
        trackRepository: trackRepository,
        recordedRoutesRepository: recordedRoutesRepository,
        searchHistoryService: searchHistoryService,
        stationsCache: context.read<StationsCache>(),
        onMarkerTapped: _showStationBottomSheet,
      )..add(const LoadMapDataEvent()),
      child: _buildUI(context),
    );
  }

  Widget _buildUI(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    // Main UI
    return GestureDetector(
      onTap: () {   
        FocusScope.of(context).unfocus(); // Esto debe quitar el teclado
        setState(() {
          _isSearchBarFocused = false; // Esto debe cerrar las búsquedas recientes
        });
      },
      behavior: HitTestBehavior.translucent,
      child: Scaffold(
        body: BlocListener<MapBloc, MapState>(
          listener: (context, state) {
            if (state is MapLoadedState && state.snackbarError != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: state.snackbarError == "not-enough-points"
                      ? Text(l10n.notEnoughPointsToRecordTrack)
                      : Text("${l10n.errorSavingRoute}: ${state.snackbarError}"),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: BlocBuilder<MapBloc, MapState>(
            builder: (context, state) {
              if (state is MapLoadingState) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is MapErrorState) {
                return Center(child: Text('Error: ${state.message}'));
              }

              if (state is MapLoadedState) {
                final markersToShow = state.currentMode == StationType.bicycle
                    ? state.bikeMarkers
                    : state.carMarkers;

                return Stack(
                  children: [
                    // Widget del mapa 
                    MapWidget(
                      initialCameraPosition: CameraPosition(
                        target: _bcnCenter,
                        zoom: 12,
                      ),
                      markers: markersToShow,
                      polyline: state.routePolyline,
                      mapType: state.currentMapType,
                      darkMode: Theme.of(context).brightness == Brightness.dark,
                      onMapCreated: _onMapCreated,
                    ),

                    // Barra de búsqueda
                    SearchBarWidget(
                      hintText: AppLocalizations.of(context)!.searchStation,
                      onChanged: (query) {
                        if (kDebugMode) {
                          print('Searching: $query');
                        }
                      },
                      onFocusChanged: (isFocused) {
                        if (kDebugMode) {
                          print('📍 MapPage received focus change: $isFocused');
                        }
                        setState(() {
                          _isSearchBarFocused = isFocused;
                        });
                      },
                    ),

                    // Botón de lista de estaciones
                    StationListButtonWidget(
                      currentMode: state.currentMode,
                      userLocation: state.userLocation,
                    ),

                    // Avatar de perfil
                    //ProfileAvatarWidget(context: context),
                    // Route history button
                    RouteHistoryButtonWidget(),

                    // Columna de controles del mapa (botones combinados)
                    MapControlsColumnWidget(
                      userLocation: state.userLocation,
                      mapController: _mapController,
                      currentMapType: state.currentMapType,
                    ),

                    // Selector de modo (bici/coche)
                    ToggleMapModeWidget(currentMode: state.currentMode),

                    Positioned(
                      top: 130,
                      left: 16,
                      right: 16,
                      child: SearchResultsList(
                        isSearchBarFocused: _isSearchBarFocused,
                      ),
                    ),
                  ],
                );
              }
              return const Center(child: Text('Estado desconocido'));
            },
          ),
        ),
      ),
    );
  }

  // -----------------------------------------------------------------------
  // Markers
  // -----------------------------------------------------------------------

  void _showStationBottomSheet(StationDetails station, MapLoadedState state) {
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(station.latitude!, station.longitude!),
          zoom: 16,
        ),
      ),
    );

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) =>
          StationBottomSheet(context: context, stationId: station.id, state: state),
    );
  }
}
