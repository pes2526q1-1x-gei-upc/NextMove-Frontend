import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nextmove_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:nextmove_app/src/funcionalidades/estaciones/dominio/station_model.dart';
import 'package:nextmove_app/src/funcionalidades/estaciones/datos/repositories/station_repository.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/data/repositories/track_repository.dart';

// Imports del BLoC
import 'package:nextmove_app/src/funcionalidades/mapa/presentacion/bloc/map_bloc.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/presentacion/bloc/map_events.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/presentacion/bloc/map_state.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/presentacion/widgets/search_results_list.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/presentacion/widgets/station_bottom_sheet_widget.dart';

//imports widgets
import 'widgets/google_map_widget.dart';
import 'widgets/toggle_map_mode_widget.dart';
import 'widgets/station_list_widget.dart';
import 'widgets/center_user_widget.dart';
import 'widgets/search_bar_widget.dart';
import 'widgets/toggle_map_type_widget.dart';
import 'widgets/record_track_widget.dart';


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
  //final LatLng _catCenter = const LatLng(41.8205, 1.8677);
  final LatLng _bcnCenter = const LatLng(41.3851, 2.1734);

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
    _setMapStyle();
  }

  void _setMapStyle() async {
    const style = '''
    [
      {
        "featureType": "poi",
        "stylers": [{"visibility": "off"}]
      }
    ]
    ''';
    _mapController?.setMapStyle(style);
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
      onMarkerTapped: _showStationBottomSheet, 
    )..add(const LoadMapDataEvent()), 
    child: _buildUI(context),
  );
}

  Widget _buildUI(BuildContext context) {

    // Main UI
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.translucent,
      child: Scaffold(
        body: BlocBuilder<MapBloc, MapState>(
          builder: (context, state) {
            if (state is MapLoadingState) {
              return const Center(child: CircularProgressIndicator());
            }
            if(state is MapErrorState){
              return Center(child: Text('Error: ${state.message}'));
            }
            
            if (state is MapLoadedState) {
              final markersToShow = state.currentMode == StationType.bicycle
                  ? state.bikeMarkers
                  : state.carMarkers;
              
              return  Stack(
              children: [
                // Widget del mapa (fondo)
                MapWidget(
                  initialCameraPosition: CameraPosition(
                    target: _bcnCenter,
                    zoom: 12,
                  ),
                  markers: markersToShow,
                  polyline: state.routePolyline,
                  mapType: state.currentMapType,
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
                ),

                if (state.isSearching)
                  Positioned(
                    top: 130,
                    left: 16,
                    right: 16, 
                    child: SearchResultsList(),
                ),

                // Avatar de perfil
                //ProfileAvatarWidget(context: context),

                // Botón de lista de estaciones
                StationListButtonWidget(
                  currentMode: state.currentMode,
                  userLocation: state.userLocation,
                ),

                // Botón centrar en usuario
                CenterOnUserButtonWidget(
                  userLocation: state.userLocation,
                  mapController: _mapController,
                ),

                // Botón cambiar tipo de mapa
                MapTypeToggleWidget(
                  currentMapType: state.currentMapType,
                ),

                // Selector de modo (bici/coche)
                ToggleMapModeWidget(
                  currentMode: state.currentMode,
                ),

                // Botón de grabación de ruta en bici
                if (state.currentMode == StationType.bicycle) const RecordTrackWidget(),
              ],
            );
          }
            return const Center(child: Text('Estado desconocido'));
        }   
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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => StationBottomSheet(context: context, station: station, state: state),
    );
  }
}