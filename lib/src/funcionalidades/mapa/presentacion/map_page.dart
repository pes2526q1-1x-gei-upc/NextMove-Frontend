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
import 'package:nextmove_app/src/funcionalidades/mapa/data/repositories/navigation_route_repository.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/data/repositories/track_repository.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/presentacion/widgets/route_info_widget.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/presentacion/widgets/route_preview_widget.dart';
import 'package:nextmove_app/src/funcionalidades/recorridos/data/repositories/recorded_routes_repository.dart';

// Imports del BLoC
import 'package:nextmove_app/src/funcionalidades/mapa/presentacion/bloc/map_bloc.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/presentacion/bloc/map_events.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/presentacion/bloc/map_state.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/data/services/search_history_service.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/domain/navigation_route.dart';

import 'package:nextmove_app/src/funcionalidades/mapa/presentacion/widgets/route_history_button_widget.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/presentacion/widgets/search_results_list.dart';

import 'package:nextmove_app/src/funcionalidades/estaciones/presentacion/widgets/station_bottom_sheet_widget.dart';

import 'widgets/google_map_widget.dart';
import 'widgets/toggle_map_mode_widget.dart';

import 'widgets/search_bar_widget.dart';
import 'package:nextmove_app/src/funcionalidades/estaciones/presentacion/widgets/station_list_widget.dart';
import 'widgets/map_controls_column_widget.dart';
import 'package:provider/provider.dart';
import 'package:nextmove_app/src/funcionalidades/auth/dominio/providers/user_provider.dart';

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
  BuildContext? _blocContext;
  List<StationDetails> stations = [];
  List<StationDetails> bikeStations = [];
  StationRepository stationRepository = StationRepository();
  TrackRepository trackRepository = TrackRepository();
  RecordedRoutesRepository recordedRoutesRepository = RecordedRoutesRepository();
  NavigationRouteRepository navigationRouteRepository = NavigationRouteRepository();

  //final LatLng _catCenter = const LatLng(41.8205, 1.8677);
  final LatLng _bcnCenter = const LatLng(41.3851, 2.1734);
  final searchHistoryService = SearchHistoryService();
  bool _isSearchBarFocused = false;
  bool _hasCenteredOnUser = false;

  
  StreamSubscription<Position>? _positionStream;

  LatLngBounds? _currentViewportBounds;
  
  Timer? _viewportUpdateTimer;
  
  static const Duration _viewportUpdateThrottle = Duration(milliseconds: 50);
  
  static const double _viewportPadding = 0.1;

  @override
  void dispose() {
    _mapController?.dispose();
    _positionStream?.cancel();
    _viewportUpdateTimer?.cancel();
    super.dispose();
  }

  // -----------------------------------------------------------------------
  // Map callbacks
  // -----------------------------------------------------------------------
  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    
    Future.delayed(const Duration(milliseconds: 250), () {
      if (mounted && _mapController != null) {
        _updateViewportBounds();
      }
    });
  }

  // =======================================================================

  Future<void> _updateViewportBounds() async {
    if (_mapController == null) return;
    
    try {
      final visibleRegion = await _mapController!.getVisibleRegion();
      
      final latSpan = visibleRegion.northeast.latitude - visibleRegion.southwest.latitude;
      final lngSpan = visibleRegion.northeast.longitude - visibleRegion.southwest.longitude;
      
      final latPadding = latSpan * _viewportPadding;
      final lngPadding = lngSpan * _viewportPadding;
      
      if (mounted) {
        setState(() {
          _currentViewportBounds = LatLngBounds(
            southwest: LatLng(
              visibleRegion.southwest.latitude - latPadding,
              visibleRegion.southwest.longitude - lngPadding,
            ),
            northeast: LatLng(
              visibleRegion.northeast.latitude + latPadding,
              visibleRegion.northeast.longitude + lngPadding,
            ),
          );
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting visible region: $e');
      }
    }
  }

  Set<Marker> _filterMarkersByViewport(Set<Marker> allMarkers, LatLngBounds? bounds) {
    if (bounds == null) {
      return allMarkers;
    }
    
    return allMarkers.where((marker) {
      final position = marker.position;
      return bounds.contains(position);
    }).toSet();
  }
  
  void _onCameraMoveThrottled(CameraPosition position) {
    _viewportUpdateTimer?.cancel();
    
    _viewportUpdateTimer = Timer(_viewportUpdateThrottle, () {
      if (mounted) {
        _updateViewportBounds();
      }
    });
  }

  // -----------------------------------------------------------------------
  // UI helpers
  // -----------------------------------------------------------------------

  /// Convierte el modo preferido del usuario (string de la API) a StationType
  StationType? _getPreferredModeFromUser(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.user;
    
    if (user == null) return null;
    
    final preferredMode = user['preferredMode'] as String?;
    if (preferredMode == null) return null;
    
    // Convertir "BIKE" o "CAR" a StationType
    switch (preferredMode.toUpperCase()) {
      case 'BIKE':
        return StationType.bicycle;
      case 'CAR':
        return StationType.electricVehicle;
      default:
        return null;
    }
  }

  // -----------------------------------------------------------------------
  // Build
  // -----------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    // Obtener el modo preferido del usuario (o null si no tiene)
    final preferredMode = _getPreferredModeFromUser(context);
    
    return BlocProvider(
      create: (context) => MapBloc(
        stationRepository: stationRepository,
        trackRepository: trackRepository,
        recordedRoutesRepository: recordedRoutesRepository,
        searchHistoryService: searchHistoryService,
        navigationRouteRepository: navigationRouteRepository,
        stationsCache: context.read<StationsCache>(),
        onMarkerTapped: _showStationBottomSheet,
        initialMode: preferredMode, // Pasar el modo preferido (o null para usar bici por defecto)
      )..add(const LoadMapDataEvent()),
      child: Builder(  // ← AÑADE ESTE Builder
        builder: (blocContext) {
          _blocContext = blocContext;  // ← GUARDA el context
          return _buildUI(blocContext);
        },
      ),    
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
            if(state is MapLoadedState && state.routeViewport != null){
              _setZoomToViewport(state.routeViewport!); 
            }
            // Centrar la cámara en la ubicación del usuario la primera vez que se obtiene
            if (state is MapLoadedState && 
                state.userLocation != null && 
                !_hasCenteredOnUser && 
                _mapController != null) {
              _hasCenteredOnUser = true;

              _mapController!.animateCamera(
                CameraUpdate.newLatLngZoom(
                  state.userLocation!,
                  12.0,
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
                // Obtener todos los marcadores según el modo y estado de navegación
                final Set<Marker> sourceMarkers;
                if (state.isNavigationMode && state.selectedStation != null) {
                   final tempMarkers = state.currentMode == StationType.bicycle
                      ? state.bikeMarkers
                      : state.carMarkers;
                      
                   sourceMarkers = tempMarkers.where(
                      (m) => m.markerId.value == state.selectedStation!.id
                   ).toSet();
                } else {
                   sourceMarkers = state.currentMode == StationType.bicycle
                      ? state.bikeMarkers
                      : state.carMarkers;
                }

                
                final Set<Marker> markersToShow = _filterMarkersByViewport(
                  sourceMarkers,
                  _currentViewportBounds,
                );

                final clusterManagerToShow = state.currentMode == StationType.bicycle
                    ? state.bikeClusterManager
                    : state.evClusterManager;

                return Stack(
                  children: [
                    // Widget del mapa 
                    MapWidget(
                      initialCameraPosition: CameraPosition(
                        target: _bcnCenter,
                        zoom: 12,
                      ),
                      markers: markersToShow,
                      clusterManagers: clusterManagerToShow != null 
                          ? {clusterManagerToShow} 
                          : {},
                      onCameraMove: _onCameraMoveThrottled, 
                      polyline: state.routePolyline,
                      mapType: state.currentMapType,
                      darkMode: Theme.of(context).brightness == Brightness.dark,
                      onMapCreated: _onMapCreated,
                      navigationRoutePolyline: state.decodedPolyline != null ? state.decodedPolyline! : const Polyline(polylineId: PolylineId('No route')),
                      myLocationEnabled: state.userLocation != null,
                      padding: state.isNavigationMode 
                        ? const EdgeInsets.only(
                            top: 180,   
                            bottom: 240, 
                            left: 20,
                            right: 20,
                          )
                        : EdgeInsets.zero,
                    ),

                    if (state.isNavigationMode)...[
                      Positioned(
                        top:60,
                        left:0,
                        right:0,
                        child: RouteInfoWidget(
                          origin: state.userLocation!,
                          destination: state.selectedStation!,
                        )
                      ),
                      if(state.navigationRoute != null)
                      Positioned(
                        bottom: 30,
                        left: 16,
                        right: 16,
                        child: RoutePreviewWidget(
                          route: state.navigationRoute!,
                          onStartPressed: () {
                            debugPrint("Iniciar navegación presionado");
                          },
                          onCancelPressed: () {
                             context.read<MapBloc>().add(CancelNavigationEvent());
                          },
                        ),
                      ),
                    ],
                    

                    // Barra de búsqueda
                    if(!state.isNavigationMode)...[
                      SearchBarWidget(
                        hintText: AppLocalizations.of(context)!.searchStation,
                        onChanged: (query) {
                          if (kDebugMode) {
                            print('Searching: $query');
                          }
                        },
                        onFocusChanged: (isFocused) {
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

 void _setZoomToViewport(RouteViewport viewport) {
    if (_mapController == null) return;
  
  final bounds = LatLngBounds(
    southwest: viewport.low,
    northeast: viewport.high,
  );
  
  // Opción A: Con padding fijo (relativo al area visible del mapa)
  _mapController!.animateCamera(
    CameraUpdate.newLatLngBounds(
      bounds,
      50, 
    ),
  );
  }

  void _showStationBottomSheet(StationDetails station, MapLoadedState state) {
    final mapBloc = _blocContext!.read<MapBloc>();

    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(station.latitude!, station.longitude!),
          zoom: 16,
        ),
      ),
    );
    
    showModalBottomSheet(
      context: _blocContext!,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => BlocProvider<MapBloc>.value(
      value: mapBloc,
      child: StationBottomSheet(
        context: context,
        stationId: station.id,
        state: state
      ),
    ),
    );
  }
}
