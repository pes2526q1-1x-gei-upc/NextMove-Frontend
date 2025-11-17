import 'dart:async';
import 'dart:ui';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:nextmove_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:nextmove_app/src/funcionalidades/estaciones/presentacion/station_details_page.dart';
import 'package:nextmove_app/src/funcionalidades/estaciones/dominio/station_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

// ✅ Imports del BLoC
import 'package:nextmove_app/src/funcionalidades/mapa/presentacion/bloc/map_bloc.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/presentacion/bloc/map_events.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/presentacion/bloc/map_state.dart';

//imports widgets
import 'widgets/google_map_widget.dart';
import 'widgets/avatar_profile_widget.dart';
import 'widgets/toggleMapMode_widget.dart';
import 'widgets/station_list_widget.dart';
import 'widgets/center_user_widget.dart';
import 'widgets/search_bar_widget.dart';
import 'widgets/toggleMapType_widget.dart';


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
  //final LatLng _catCenter = const LatLng(41.8205, 1.8677);
  final LatLng _bcnCenter = const LatLng(41.3851, 2.1734);
  LatLng? _userLocation;

  StreamSubscription<Position>? _positionStream;
  MapType _currentMapType = MapType.normal;
  StationType _currentMode = StationType.bicycle; // default

  // Loading / error handling
  bool _isLoading = true;
  String? _errorMessage;

  // -----------------------------------------------------------------------
  // Lifecycle
  // -----------------------------------------------------------------------

  @override
  void dispose() {
    _mapController?.dispose();
    _positionStream?.cancel();
    super.dispose();
  }

  // -----------------------------------------------------------------------
  // Initialization
  // -----------------------------------------------------------------------


  // -----------------------------------------------------------------------
  // Location handling
  // -----------------------------------------------------------------------
  
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
      //stationRepository: stationRepository,
      onMarkerTapped: _showStationBottomSheet, // Asegúrate de tener la instancia correcta
    )..add(const LoadMapDataEvent()), // dispara evento inicial
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
              // Actualizar variables locales con el estado del BLoC
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
                  mapType: state.currentMapType,
                  onMapCreated: _onMapCreated,
                ),

                // Barra de búsqueda
                SearchBarWidget(
                  hintText: AppLocalizations.of(context)!.searchStation,
                  onChanged: (query) {
                    // TODO: Implementar búsqueda
                    debugPrint('Searching: $query');
                  },
                ),

                // Avatar de perfil
                ProfileAvatarWidget(context: context),

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
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              station.address,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(station.address, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: state.currentMode == StationType.bicycle
                      ? Colors.blue
                      : Colors.green,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => StationDetailsPage(
                        stationID: station.id,
                        stationType: state.currentMode,
                        stationDetails: station,
                      ),
                    ),
                  );
                },
                child: const Text('Info'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}