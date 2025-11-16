import 'dart:async';
import 'dart:ui';
import 'package:nextmove_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:nextmove_app/src/funcionalidades/estaciones/presentacion/station_details_page.dart';
import 'package:nextmove_app/src/funcionalidades/estaciones/dominio/station_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

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
  void initState() {
    super.initState();
    _initializeApp();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _positionStream?.cancel();
    super.dispose();
  }

  // -----------------------------------------------------------------------
  // Initialization
  // -----------------------------------------------------------------------
  Future<void> _initializeApp() async {
    try {
      await Future.wait([
        _loadStations(getAllEVStationDetails, (data) => stations = data),
        _loadStations(getAllBicycleStationDetails, (data) => bikeStations = data),
        _initializateLocation(),
      ]);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadStations(
    Future<List<StationDetails>?> Function() fetchFunc,
    void Function(List<StationDetails>) onSuccess,
  ) async {
    try {
      final data = await fetchFunc();
      if (data != null) onSuccess(data);
    } catch (e, s) {
      debugPrint('Error loading stations: $e\n$s');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("error cargando estaciones: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // -----------------------------------------------------------------------
  // Location handling
  // -----------------------------------------------------------------------
  
  Future<void> _initializateLocation() async {
    await _checkLocationPermission();
  }

  Future<void> _checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      _showPermissionDialog();
      return;
    }

    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      _startLocationUpdates();
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Se requiere permiso de ubicación'),
        content: const Text(
            'Habilite la ubicación en la configuración del dispositivo'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Aceptar')),
          TextButton(
              onPressed: () {
                Geolocator.openAppSettings();
                Navigator.of(context).pop();
              },
              child: const Text('Abrir ajustes')),
        ],
      ),
    );
  }

  void _startLocationUpdates() {
    final settings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 50,
    );
    _positionStream = Geolocator.getPositionStream(locationSettings: settings)
        .listen((Position? pos) {
      if (pos != null && mounted) {
        setState(() => _userLocation = LatLng(pos.latitude, pos.longitude));
      }
    });
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
  
  void _switchMode(StationType mode) {
    setState(() => _currentMode = mode);
  }

  BitmapDescriptor _getCustomMarkerIcon() => _currentMode == StationType.bicycle
      ? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue)
      : BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);


  void _toggleMapType() {
    setState(() {
      _currentMapType = _currentMapType == MapType.normal
          ? MapType.satellite
          : MapType.normal;
    });
  }

  // -----------------------------------------------------------------------
  // Build
  // -----------------------------------------------------------------------
    @override
  Widget build(BuildContext context) {
    // Loading state
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Error state
    if (_errorMessage != null) {
      return Scaffold(
        body: Center(child: Text('Error: $_errorMessage')),
      );
    }

    // Main UI
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.translucent,
      child: Scaffold(
        body: Stack(
          children: [
            // Widget del mapa (fondo)
            MapWidget(
              initialCameraPosition: CameraPosition(
                target: _bcnCenter,
                zoom: 12,
              ),
              markers: _buildMarkers(),
              mapType: _currentMapType,
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
            const ProfileAvatarWidget(),

            // Botón de lista de estaciones
            StationListButtonWidget(
              currentMode: _currentMode,
              userLocation: _userLocation,
            ),

            // Botón centrar en usuario
            CenterOnUserButtonWidget(
              userLocation: _userLocation,
              mapController: _mapController,
            ),

            // Botón cambiar tipo de mapa
            MapTypeToggleWidget(
              currentMapType: _currentMapType,
              onToggle: _toggleMapType,
            ),

            // Selector de modo (bici/coche)
            ToggleMapModeWidget(
              currentMode: _currentMode,
              onModeChanged: _switchMode,
            ),
          ],
        ),
      ),
    );
  }


// -----------------------------------------------------------------------
  // Markers
  // -----------------------------------------------------------------------
  Set<Marker> _buildMarkers() {
    final Set<Marker> markers = {};
    final icon = _getCustomMarkerIcon();
    final List<StationDetails> stationsToShow =
        _currentMode == StationType.bicycle ? bikeStations : stations;

    for (final station in stationsToShow) {
      markers.add(
        Marker(
          markerId: MarkerId(station.id),
          position: LatLng(station.latitude, station.longitude),
          icon: icon,
          onTap: () => _showStationBottomSheet(station),
        ),
      );
    }
    return markers;
  }

  void _showStationBottomSheet(StationDetails station) {
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
                  backgroundColor: _currentMode == StationType.bicycle
                      ? Colors.blue
                      : Colors.green,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => StationDetailsPage(
                        stationID: station.id,
                        stationType: _currentMode,
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