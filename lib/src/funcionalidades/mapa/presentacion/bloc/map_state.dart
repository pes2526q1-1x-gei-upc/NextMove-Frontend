import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nextmove_app/src/funcionalidades/estaciones/dominio/station_model.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/domain/navigation_route.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/domain/recorded_track.dart';
import 'package:nextmove_app/src/funcionalidades/competition/challenges/domain/company.dart';

/// Clase base abstracta para todos los estados del mapa
abstract class MapState extends Equatable {
  const MapState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial: cuando la aplicación arranca
class MapInitialState extends MapState {
  const MapInitialState();
}

/// Estado de carga: mientras se cargan estaciones y ubicación
class MapLoadingState extends MapState {
  const MapLoadingState();
}

/// Estado cargado con éxito: contiene todos los datos necesarios
class MapLoadedState extends MapState {
  final List<StationDetails> bikeStations;
  final List<StationDetails> evStations;
  final List<Company> promotedCompanies;
  final LatLng? userLocation;
  final StationType currentMode;
  final MapType currentMapType;
  final Set<Marker> bikeMarkers;
  final Set<Marker> carMarkers;
  final Set<Marker> companyMarkers;
  final LatLng centerPosition;
  final String? searchQuery;
  final List<StationDetails> searchResults;
  final bool isSearching;
  final bool isRecordingRoute;
  final RecordedTrack? recordedTrack;
  final Polyline routePolyline;
  final String? snackbarError;
  final Duration recordingElapsedTime;
  final List<StationDetails> recentBikeSearches;
  final List<StationDetails> recentEvSearches;
  final bool isNavigationMode;
  final StationDetails? selectedStation;
  final NavigationRoute? navigationRoute;
  final Polyline? decodedPolyline;
  final RouteViewport? routeViewport;
  final ClusterManager? bikeClusterManager;
  final ClusterManager? evClusterManager;
  final bool shouldShowStatistics;
  final bool routeSavedSuccessfully;
  final ClusterManager? companyClusterManager;
  final String? challengeNotificationMessage;
  final String? challengeNotificationTitle;
  final int? challengeNotificationPercentage;
  final String? challengeNotificationName;  
  final bool isTurnByTurnActive;
  final int? currentStepIndex;
  final int? distanceToNextStepMeters;
  final double? userHeading; // Orientación del usuario para rotar el mapa (0-360)
  final bool isLocationPermissionDenied;
  final bool isLocationPermissionPermanentlyDenied;

  const MapLoadedState({
    required this.bikeStations,
    required this.evStations,
    required this.promotedCompanies,
    this.userLocation,
    required this.currentMode,
    required this.currentMapType,
    required this.bikeMarkers,
    required this.carMarkers,
    required this.companyMarkers,
    required this.centerPosition,
    this.searchQuery,
    this.searchResults = const [],
    required this.isSearching,
    this.isRecordingRoute = false,
    this.recordedTrack,
    required this.routePolyline,
    this.snackbarError,
    this.recordingElapsedTime = Duration.zero,
    this.recentBikeSearches = const [],
    this.recentEvSearches = const [],
    this.isNavigationMode = false,
    this.selectedStation,
    this.navigationRoute,
    this.decodedPolyline,
    this.routeViewport,
    this.bikeClusterManager,
    this.evClusterManager,
    this.shouldShowStatistics = false,
    this.routeSavedSuccessfully = false,
    this.companyClusterManager,
    this.challengeNotificationTitle,
    this.challengeNotificationMessage,
    this.challengeNotificationPercentage,
    this.challengeNotificationName,
    this.isTurnByTurnActive = false,
    this.currentStepIndex,
    this.distanceToNextStepMeters,
    this.userHeading,
    this.isLocationPermissionDenied = false,
    this.isLocationPermissionPermanentlyDenied = false,
  });

  @override
  List<Object?> get props => [
        bikeStations,
        evStations,
        promotedCompanies,
        userLocation,
        currentMode,
        currentMapType,
        bikeMarkers,
        carMarkers,
        companyMarkers,
        centerPosition,
        searchQuery,
        searchResults,
        isSearching,
        isRecordingRoute,
        recordedTrack,
        routePolyline,
        snackbarError,
        recordingElapsedTime,
        recentBikeSearches,
        recentEvSearches,
        isNavigationMode,
        selectedStation,
        navigationRoute,
        decodedPolyline,
        routeViewport,
        bikeClusterManager,
        evClusterManager,
        shouldShowStatistics,
        routeSavedSuccessfully,
        companyClusterManager,
        challengeNotificationTitle,
        challengeNotificationMessage,
        challengeNotificationPercentage,
        challengeNotificationName,
        isTurnByTurnActive,
        currentStepIndex,
        distanceToNextStepMeters,
        userHeading,
        isLocationPermissionDenied,
        isLocationPermissionPermanentlyDenied,
      ];

  MapLoadedState copyWith({
    List<StationDetails>? bikeStations,
    List<StationDetails>? evStations,
    List<Company>? promotedCompanies,
    LatLng? userLocation,
    StationType? currentMode,
    MapType? currentMapType,
    Set<Marker>? bikeMarkers,
    Set<Marker>? carMarkers,
    Set<Marker>? companyMarkers,
    LatLng? centerPosition,
    String? searchQuery,
    bool clearSearchQuery = false,
    List<StationDetails>? searchResults,
    bool? isSearching,
    bool? isRecordingRoute,
    RecordedTrack? recordedTrack,
    Polyline? routePolyline,
    String? snackbarError,
    bool clearSnackbarError = false,
    Duration? recordingElapsedTime,
    List<StationDetails>? recentBikeSearches,
    List<StationDetails>? recentEvSearches,
    bool? isNavigationMode,
    StationDetails? selectedStation,
    NavigationRoute? navigationRoute,
    Polyline? decodedPolyline,
    RouteViewport? routeViewport,
    ClusterManager? bikeClusterManager,
    ClusterManager? evClusterManager,
    bool? shouldShowStatistics,
    bool? routeSavedSuccessfully,
    ClusterManager? companyClusterManager,
    String? challengeNotificationTitle,
    String? challengeNotificationMessage,
    int? challengeNotificationPercentage,
    String? challengeNotificationName,
    bool? isTurnByTurnActive,
    int? currentStepIndex,
    int? distanceToNextStepMeters,
    double? userHeading,
    bool? isLocationPermissionDenied,
    bool? isLocationPermissionPermanentlyDenied,
  }) {
    return MapLoadedState(
      bikeStations: bikeStations ?? this.bikeStations,
      evStations: evStations ?? this.evStations,
      promotedCompanies: promotedCompanies ?? this.promotedCompanies,
      userLocation: userLocation ?? this.userLocation,
      currentMode: currentMode ?? this.currentMode,
      currentMapType: currentMapType ?? this.currentMapType,
      bikeMarkers: bikeMarkers ?? this.bikeMarkers,
      carMarkers: carMarkers ?? this.carMarkers,
      companyMarkers: companyMarkers ?? this.companyMarkers,
      centerPosition: centerPosition ?? this.centerPosition,
      searchQuery: clearSearchQuery ? null : (searchQuery ?? this.searchQuery),
      searchResults: searchResults ?? this.searchResults,
      isSearching: isSearching ?? this.isSearching,
      isRecordingRoute: isRecordingRoute ?? this.isRecordingRoute,
      recordedTrack: recordedTrack ?? this.recordedTrack,
      routePolyline: routePolyline ?? this.routePolyline,
      snackbarError: snackbarError ?? this.snackbarError,
      recordingElapsedTime: recordingElapsedTime ?? this.recordingElapsedTime,
      recentBikeSearches: recentBikeSearches ?? this.recentBikeSearches,
      recentEvSearches: recentEvSearches ?? this.recentEvSearches,
      isNavigationMode: isNavigationMode ?? this.isNavigationMode,
      selectedStation: selectedStation ?? this.selectedStation,
      navigationRoute: navigationRoute ?? this.navigationRoute,
      decodedPolyline: decodedPolyline ?? this.decodedPolyline,
      routeViewport: routeViewport ?? this.routeViewport,
      bikeClusterManager: bikeClusterManager ?? this.bikeClusterManager,
      evClusterManager: evClusterManager ?? this.evClusterManager,
      shouldShowStatistics: shouldShowStatistics ?? this.shouldShowStatistics,
      routeSavedSuccessfully: routeSavedSuccessfully ?? this.routeSavedSuccessfully,
      companyClusterManager: companyClusterManager ?? this.companyClusterManager,
      challengeNotificationTitle: challengeNotificationTitle ?? this.challengeNotificationTitle,
      challengeNotificationMessage: challengeNotificationMessage ?? this.challengeNotificationMessage,
      challengeNotificationPercentage: challengeNotificationPercentage ?? this.challengeNotificationPercentage,
      challengeNotificationName: challengeNotificationName ?? this.challengeNotificationName,
      isTurnByTurnActive: isTurnByTurnActive ?? this.isTurnByTurnActive,
      currentStepIndex: currentStepIndex ?? this.currentStepIndex,
      distanceToNextStepMeters: distanceToNextStepMeters ?? this.distanceToNextStepMeters,
      userHeading: userHeading ?? this.userHeading,
      isLocationPermissionDenied: isLocationPermissionDenied ?? this.isLocationPermissionDenied,
      isLocationPermissionPermanentlyDenied: isLocationPermissionPermanentlyDenied ?? this.isLocationPermissionPermanentlyDenied,
    );
  }

  /// Obtener búsquedas recientes según el modo actual
  List<StationDetails> get currentModeRecentSearches {
    return currentMode == StationType.bicycle 
      ? recentBikeSearches 
      : recentEvSearches;
  }
}

/// Estado de error: cuando algo falla
class MapErrorState extends MapState {
  final String message;

  const MapErrorState(this.message);

  @override
  List<Object?> get props => [message];
}

/// Estado de permisos de ubicación denegados
class MapLocationPermissionDeniedState extends MapState {
  final bool isPermanentlyDenied;

  const MapLocationPermissionDeniedState({
    this.isPermanentlyDenied = false,
  }); 

  @override
  List<Object?> get props => [isPermanentlyDenied];
}