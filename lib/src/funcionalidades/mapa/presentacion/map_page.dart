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
import 'package:nextmove_app/src/funcionalidades/mapa/data/repositories/promoted_companies_repository.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/data/repositories/track_repository.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/presentacion/widgets/route_info_widget.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/presentacion/widgets/route_preview_widget.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/presentacion/widgets/saved_track_statistics_page.dart';

import 'package:nextmove_app/src/funcionalidades/mapa/presentacion/widgets/turn_instruction_widget.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/presentacion/widgets/navigation_progress_widget.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/presentacion/widgets/navigation_completed_screen.dart';
import 'package:nextmove_app/src/funcionalidades/recorridos/data/repositories/recorded_routes_repository.dart';

// Imports del BLoC
import 'package:nextmove_app/src/funcionalidades/mapa/presentacion/bloc/map_bloc.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/presentacion/bloc/map_events.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/presentacion/bloc/map_state.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/data/services/search_history_service.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/domain/navigation_route.dart';

import 'package:nextmove_app/src/funcionalidades/mapa/presentacion/widgets/route_history_button_widget.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/presentacion/widgets/search_results_list.dart';
import 'package:nextmove_app/src/funcionalidades/competition/challenges/domain/company.dart';
import 'package:nextmove_app/src/funcionalidades/competition/challenges/data/repositories/challenges_repository.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/presentacion/widgets/company_bottom_sheet_widget.dart';

import 'package:nextmove_app/src/funcionalidades/estaciones/presentacion/widgets/station_bottom_sheet_widget.dart';
import 'package:nextmove_app/src/funcionalidades/estaciones/presentacion/widgets/favorite_stations_button_widget.dart';

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
  PromotedCompaniesRepository promotedCompaniesRepository = PromotedCompaniesRepository();
  final searchHistoryService = SearchHistoryService();
  bool _isSearchBarFocused = false;
  bool _hasCenteredOnUser = false;
  bool _wasRecordingRoute = false;
  bool _hasShownCompletionScreen = false;

  CameraPosition? _cameraPositionBeforeMapTypeChange;
  CameraPosition _currentCameraPosition = const CameraPosition(
    target: LatLng(41.3851, 2.1734), // Barcelona por defecto
    zoom: 12,
  );
  final GlobalKey<SearchBarWidgetState> _searchBarKey = GlobalKey<SearchBarWidgetState>();
  
  StreamSubscription<Position>? _positionStream;

  final ValueNotifier<LatLngBounds?> _viewportBoundsNotifier = 
      ValueNotifier<LatLngBounds?>(null);
  
  DateTime? _lastViewportUpdate;
  bool _isViewportUpdatePending = false;
  
  static const Duration _viewportUpdateThrottle = Duration(milliseconds: 300);
  
  static const double _viewportPadding = 0.1;

  @override
  void dispose() {
    _mapController?.dispose();
    _positionStream?.cancel();
    _viewportBoundsNotifier.dispose();
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
    if (_mapController == null || !mounted) return;
    
    // Evitar actualizaciones simultáneas
    if (_isViewportUpdatePending) return;
    
    _isViewportUpdatePending = true;
    
    try {
      final visibleRegion = await _mapController!.getVisibleRegion();
      
      final latSpan = visibleRegion.northeast.latitude - visibleRegion.southwest.latitude;
      final lngSpan = visibleRegion.northeast.longitude - visibleRegion.southwest.longitude;
      
      final latPadding = latSpan * _viewportPadding;
      final lngPadding = lngSpan * _viewportPadding;
      
      final newBounds = LatLngBounds(
        southwest: LatLng(
          visibleRegion.southwest.latitude - latPadding,
          visibleRegion.southwest.longitude - lngPadding,
        ),
        northeast: LatLng(
          visibleRegion.northeast.latitude + latPadding,
          visibleRegion.northeast.longitude + lngPadding,
        ),
      );
      
      // Actualizar ValueNotifier sin setState
      _viewportBoundsNotifier.value = newBounds;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting visible region: $e');
      }
    } finally {
      _isViewportUpdatePending = false;
    }
  }

  Set<Marker> _filterMarkersByViewport(Set<Marker> allMarkers, LatLngBounds? bounds) {
    if (bounds == null) {
      return {};
    }
    
    return allMarkers.where((marker) {
      final position = marker.position;
      return bounds.contains(position);
    }).toSet();
  }
  
  void _onCameraMoveThrottled(CameraPosition position) {
    // Guardar la posición actual de la cámara
    _currentCameraPosition = position;
    
    final now = DateTime.now();
    
    // Throttling real: solo ejecutar si ha pasado el tiempo mínimo desde la última actualización
    if (_lastViewportUpdate == null || 
        now.difference(_lastViewportUpdate!) >= _viewportUpdateThrottle) {
      _lastViewportUpdate = now;
      _updateViewportBounds();
    }
    // Si no ha pasado el tiempo suficiente, simplemente ignoramos esta llamada
    // El siguiente frame que cumpla el throttle ejecutará la actualización
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

  int _calculateRemainingSeconds(NavigationRoute route, int currentStepIndex, int distanceToNextStepMeters) {
    int remainingSeconds = 0;
    
    // Remaining time of current step
    if (currentStepIndex < route.steps.length) {
      final currentStep = route.steps[currentStepIndex];
      if (currentStep.distanceMeters > 0) {
        final progress = distanceToNextStepMeters / currentStep.distanceMeters;
        // Clamp progress to 0.0 - 1.0 just in case
        final safeProgress = progress.clamp(0.0, 1.0);
        remainingSeconds += (currentStep.durationSeconds * safeProgress).round();
      } else {
        remainingSeconds += currentStep.durationSeconds;
      }
    }
    
    // Time of subsequent steps
    for (int i = currentStepIndex + 1; i < route.steps.length; i++) {
        remainingSeconds += route.steps[i].durationSeconds;
    }
    
    return remainingSeconds;
  }

  int _calculateRemainingDistance(NavigationRoute route, int currentStepIndex, int distanceToNextStepMeters) {
    int remainingDistance = 0;
    
    // Remaining distance of current step
    remainingDistance += distanceToNextStepMeters;
    
    // Distance of subsequent steps
    for (int i = currentStepIndex + 1; i < route.steps.length; i++) {
        remainingDistance += route.steps[i].distanceMeters;
    }
    
    return remainingDistance;
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
        promotedCompaniesRepository: promotedCompaniesRepository,
        challengesRepository: ChallengesRepository(),
        onMarkerTapped: _showStationBottomSheet,
        onCompanyMarkerTapped: _showCompanyBottomSheet,
        initialMode: preferredMode, // Pasar el modo preferido (o null para usar bici por defecto)
      )..add(const LoadMapDataEvent()),
      child: Builder( 
        builder: (blocContext) {
          _blocContext = blocContext;  
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
        // Limpiar la búsqueda si hay texto
        _searchBarKey.currentState?.clearSearch();
        context.read<MapBloc>().add(const ClearSearchEvent());
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
            if (state is MapLoadedState && state.shouldShowStatistics) {
              final mapBloc = context.read<MapBloc>();
              mapBloc.add(const ResetStatisticsNavigationEvent());
              
              // Pestaña de estadísticas
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => BlocProvider<MapBloc>.value(
                    value: mapBloc,
                    child: const SavedTrackStatisticsPage(),
                  ),
                ),
              );
            }
            if (state is MapLoadedState && state.challengeNotificationTitle != null) {
              final mapBloc = context.read<MapBloc>();
              final title = state.challengeNotificationTitle == 'challengeCompletedTitle'
                  ? l10n.challengeCompletedTitle
                  : l10n.challengeProgressTitle;
              final message = state.challengeNotificationPercentage == null
                  ? '${l10n.challengeCompletedMessage} ${state.challengeNotificationName}'
                  : '${l10n.challengeProgressMessage(state.challengeNotificationPercentage.toString())} ${state.challengeNotificationName}';
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(title),
                  content: Text(message),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        mapBloc.add(const ResetChallengeCompletionEvent());
                      },
                      child: Text(l10n.ok),
                    ),
                  ],
                ),
              );
            }
            if(state is MapLoadedState && state.routeViewport != null){
              _setZoomToViewport(state.routeViewport!); 
            }
            
            // Detectar cuando se guarda exitosamente una ruta grabada
            if (state is MapLoadedState) {
              // Si estaba grabando y ahora no está grabando, y no hay errores, y tiene suficientes puntos
              if (_wasRecordingRoute && 
                  !state.isRecordingRoute && 
                  !_hasShownCompletionScreen &&
                  state.snackbarError == null &&
                  state.recordedTrack != null &&
                  state.recordedTrack!.points.length >= 2) {
                _hasShownCompletionScreen = true;
                // Esperar un momento antes de mostrar la pantalla para que la transición sea suave
                Future.delayed(const Duration(milliseconds: 500), () {
                  if (mounted && context.mounted) {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      barrierColor: Colors.black.withValues(alpha: 0.7),
                      builder: (dialogContext) => NavigationCompletedScreen(
                        onClose: () {
                          Navigator.of(dialogContext).pop();
                          _hasShownCompletionScreen = false;
                        },
                        currentMode: state.currentMode,
                        mapBloc: context.read<MapBloc>(),
                      ),
                    );
                  }
                });
              }
              
              // Actualizar el estado de grabación
              _wasRecordingRoute = state.isRecordingRoute;
              
              // Resetear el flag cuando se inicia una nueva grabación
              if (state.isRecordingRoute) {
                _hasShownCompletionScreen = false;
              }
            }
            
            // Actualizar la posición inicial cuando cambia el tipo de mapa
            if (state is MapLoadedState && 
                _cameraPositionBeforeMapTypeChange != null) {
              // Actualizar la posición inicial con la posición guardada
              setState(() {
                _currentCameraPosition = _cameraPositionBeforeMapTypeChange!;
                _cameraPositionBeforeMapTypeChange = null; // Limpiar
              });
            }
            
            // Auto-follow camera during turn-by-turn navigation
            if (state is MapLoadedState && 
                state.isTurnByTurnActive && 
                state.userLocation != null && 
                _mapController != null) {
              // Usar el heading del GPS si está disponible, sino 0
              final bearing = state.userHeading ?? 0.0;
              
              _mapController!.animateCamera(
                CameraUpdate.newCameraPosition(
                  CameraPosition(
                    target: state.userLocation!,
                    zoom: 17.0, // Closer zoom for navigation
                    bearing: bearing, // Rotar el mapa según la orientación (2D)
                    tilt: 0.0, // Sin inclinación 3D, vista plana
                  ),
                ),
              );
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
                      
                   sourceMarkers = {
                     ...tempMarkers.where(
                        (m) => m.markerId.value == state.selectedStation!.id
                     ),
                     ...state.companyMarkers,
                   };
                } else {
                   sourceMarkers = {
                     ...state.currentMode == StationType.bicycle
                        ? state.bikeMarkers
                        : state.carMarkers,
                     ...state.companyMarkers,
                   };
                }

                final clusterManagerToShow = state.currentMode == StationType.bicycle
                    ? state.bikeClusterManager
                    : state.evClusterManager;

                return ValueListenableBuilder<LatLngBounds?>(
                  valueListenable: _viewportBoundsNotifier,
                  builder: (context, viewportBounds, _) {
                    final Set<Marker> markersToShow = _filterMarkersByViewport(
                      sourceMarkers,
                      viewportBounds,
                    );

                    return Stack(
                      children: [
                        // Widget del mapa 
                        MapWidget(
                          key: ValueKey('map_${state.currentMapType}'), // Key que cambia con el tipo de mapa
                          initialCameraPosition: _currentCameraPosition,
                          markers: markersToShow,
                          clusterManagers: {
                            if (clusterManagerToShow != null) clusterManagerToShow,
                            state.companyClusterManager,
                          }.whereType<ClusterManager>().toSet(),
                          onCameraMove: _onCameraMoveThrottled, 
                          onTap: (LatLng position) {
                            // Limpiar la búsqueda cuando se toca el mapa
                            FocusScope.of(context).unfocus();
                            setState(() {
                              _isSearchBarFocused = false;
                            });
                            _searchBarKey.currentState?.clearSearch();
                            context.read<MapBloc>().add(const ClearSearchEvent());
                          },
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
                      // Show turn-by-turn navigation widgets when active
                      if (state.isTurnByTurnActive && 
                          state.navigationRoute != null && 
                          state.currentStepIndex != null) ...[
                        NavigationProgressWidget(
                          remainingSeconds: _calculateRemainingSeconds(
                            state.navigationRoute!,
                            state.currentStepIndex!,
                            state.distanceToNextStepMeters ?? 0,
                          ),
                          remainingDistance: _calculateRemainingDistance(
                            state.navigationRoute!,
                            state.currentStepIndex!,
                            state.distanceToNextStepMeters ?? 0,
                          ),
                        ),
                        TurnInstructionWidget(
                          currentStep: state.navigationRoute!.steps[state.currentStepIndex!],
                          distanceToNextStepMeters: state.distanceToNextStepMeters ?? 0,
                          onCancel: () {
                            context.read<MapBloc>().add(const StopTurnByTurnNavigationEvent());
                          },
                        ),
                      ] else ...[
                        // Show route preview when not in turn-by-turn mode
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
                        Positioned.fill(
                          bottom: 0,
                          child: DraggableScrollableSheet(
                            initialChildSize: 0.28, 
                            minChildSize: 0.15,
                            maxChildSize: 0.28, 
                            snap: true,
                            snapSizes: const [0.15, 0.28], 
                            builder: (context, scrollController) {
                              return NotificationListener<DraggableScrollableNotification>(
                                onNotification: (notification) {
                                  // Cuando el usuario suelta el drag y está en el mínimo o cerca
                                  if (notification.extent <= notification.minExtent + 0.05) {
                                    // Solo cancelar si realmente está en el mínimo
                                    if (notification.extent <= notification.minExtent + 0.02) {
                                      Future.delayed(const Duration(milliseconds: 200), () {
                                        if (context.mounted && 
                                            notification.extent <= notification.minExtent + 0.02) {
                                          context.read<MapBloc>().add(CancelNavigationEvent());
                                        }
                                      });
                                    }
                                  }
                                  return false; // Permitir que otros listeners también procesen
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).cardColor,
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(24),
                                    ),
                                  ),
                                  child: LayoutBuilder(
                                    builder: (context, constraints) {
                                      return SingleChildScrollView(
                                        controller: scrollController,
                                        physics: const ClampingScrollPhysics(),
                                        padding: EdgeInsets.only(
                                          bottom: MediaQuery.of(context).padding.bottom + 8,
                                        ),
                                        child: ConstrainedBox(
                                          constraints: BoxConstraints(
                                            minHeight: constraints.maxHeight,
                                          ),
                                          child: IntrinsicHeight(
                                            child: RoutePreviewWidget(
                                              route: state.navigationRoute!,
                                              onStartPressed: () {
                                                context.read<MapBloc>().add(const StartTurnByTurnNavigationEvent());
                                              },
                                              onCancelPressed: () {
                                                context.read<MapBloc>().add(CancelNavigationEvent());
                                              },
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ],
                    if(state.isTurnByTurnActive || !state.isNavigationMode)
                      MapControlsColumnWidget(
                        userLocation: state.userLocation,
                        mapController: _mapController,
                        currentMapType: state.currentMapType,
                        onBeforeToggleMapType: (position) {
                          _cameraPositionBeforeMapTypeChange = position;
                        },
                      ),
                    

                    // Barra de búsqueda
                    if(!state.isNavigationMode)...[
                      SearchBarWidget(
                        key: _searchBarKey,
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

                      // Favorite stations button
                      FavoriteStationsButtonWidget(
                        currentMode: state.currentMode,
                      ),
                   

                    // Botón de play/stop (solo en modo bici) - A la derecha del toggle con texto
                    if (state.currentMode == StationType.bicycle)
                      Positioned(
                        bottom: 30, // Misma altura que el toggle
                        right: 16, // A la derecha, con margen
                        child: GestureDetector(
                          onTap: () {
                            final bloc = context.read<MapBloc>();
                            if (state.isRecordingRoute) {
                              final l10n = AppLocalizations.of(context)!;
                              bloc.add(StopRouteRecordingEvent(l10n));
                            } else {
                              bloc.add(const StartRouteRecordingEvent());
                            }
                          },
                          child: Container(
                            height: 50,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: state.isRecordingRoute
                                  ? (Theme.of(context).brightness == Brightness.dark
                                      ? Colors.red.shade700
                                      : Theme.of(context).colorScheme.error)
                                  : (Theme.of(context).brightness == Brightness.dark
                                      ? Colors.green.shade700
                                      : Theme.of(context).colorScheme.primary),
                              borderRadius: BorderRadius.circular(25),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(
                                    alpha: Theme.of(context).brightness == Brightness.dark ? 0.45 : 0.18,
                                  ),
                                  spreadRadius: 1,
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                ),
                              ],
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
                                Builder(
                                  builder: (context) {
                                    final text = state.isRecordingRoute 
                                        ? AppLocalizations.of(context)!.stopRecording
                                        : l10n.startRoute;
                                    final words = text.split(' ');
                                    
                                    if (words.length == 1) {
                                      // Si es una sola palabra, mostrarla centrada
                                      return Text(
                                        text,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          height: 1.0,
                                        ),
                                      );
                                    } else {
                                      // Si hay múltiples palabras, mostrarlas en dos líneas
                                      return Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            words[0],
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              height: 1.0,
                                            ),
                                          ),
                                          Text(
                                            words.skip(1).join(' '),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              height: 1.0,
                                            ),
                                          ),
                                        ],
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                    // Selector de modo (bici/coche) - Siempre fijo en la misma posición
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
                  },
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

  void _showCompanyBottomSheet(Company company, MapLoadedState state) {
    final mapBloc = _blocContext!.read<MapBloc>();

    if (company.location != null) {
      _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: company.location!,
            zoom: 16,
          ),
        ),
      );
    }

    showModalBottomSheet(
      context: _blocContext!,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => BlocProvider<MapBloc>.value(
        value: mapBloc,
        child: CompanyBottomSheet(
          company: company,
          state: state,
        ),
      ),
    );
  }
}
