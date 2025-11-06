import 'dart:async';
import 'dart:ui';
import 'package:nextmove_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:nextmove_app/src/funcionalidades/estaciones/presentacion/station_details_page.dart';
import 'package:nextmove_app/src/funcionalidades/estaciones/presentacion/station_list.dart';
import 'package:nextmove_app/src/funcionalidades/estaciones/dominio/station_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:nextmove_app/src/funcionalidades/perfil/presentacion/edit_user_data_preferences_page.dart';

class MapHomePage extends StatefulWidget {
  const MapHomePage({super.key});
  @override
  State<MapHomePage> createState() => _MapHomePageState();
}

class _MapHomePageState extends State<MapHomePage> {
  // -----------------------------------------------------------------------
  // Controllers & state
  // -----------------------------------------------------------------------
  late GoogleMapController mapController;
  List<StationDetails> stations = [];
  List<StationDetails> bikeStations = [];
  final LatLng _catCenter = const LatLng(41.8205, 1.8677);
  final LatLng _bcnCenter = const LatLng(41.3851, 2.1734);
  LatLng? _userLocation;

  StreamSubscription<Position>? _positionStream;
  MapType _currentMapType = MapType.normal;
  StationType _currentMode = StationType.bicycle; // default
  final TextEditingController _searchController = TextEditingController();

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
    _positionStream?.cancel();
    _searchController.dispose();
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
    mapController = controller;
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
    mapController.setMapStyle(style);
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

  void _navigateToEditUser() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const EditUserDataPreferences()),
    );
  }

  void _centerOnUser() {
    if (_userLocation != null) {
      mapController.animateCamera(
        CameraUpdate.newLatLngZoom(_userLocation!, 15),
      );
    }
  }

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
    // Loading / error UI
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_errorMessage != null) {
      return Scaffold(
        body: Center(child: Text('Error: $_errorMessage')),
      );
    }

    // Main UI – hide keyboard on any tap outside
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.translucent,
      child: Scaffold(
        body: Stack(
          children: [
            // ------------------- Google Map -------------------
            GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition:
                  CameraPosition(target: _bcnCenter, zoom: 12),
              markers: _buildMarkers(),
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              compassEnabled: true,
              mapType: _currentMapType,
            ),

            // ------------------- Profile avatar -------------------
            Positioned(
              top: 70,
              right: 16,
              child: GestureDetector(
                onTap: _navigateToEditUser,
                child: const CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, color: Colors.grey, size: 28),
                ),
              ),
            ),

            // ------------------- Search bar -------------------
            Positioned(
              top: 70,
              left: 16,
              right: 80,
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 5,
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!.searchStation,
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 15),
                  ),
                  onSubmitted: (_) {
                    // TODO: implement search
                  },
                ),
              ),
            ),

            // ------------------- Station list button -------------------
            Positioned(
              top: 130,
              right: 16,
              child: GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => StationList(
                      stationType: _currentMode,
                      latitude: _userLocation?.latitude ?? 0,
                      longitude: _userLocation?.longitude ?? 0,
                    ),
                  ),
                ),
                child: Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 2,
                        blurRadius: 5,
                      ),
                    ],
                  ),
                  child: Icon(Icons.list, color: Colors.grey[700], size: 28),
                ),
              ),
            ),

            // ------------------- Center on user -------------------
            Positioned(
              top: 190,
              right: 16,
              child: GestureDetector(
                onTap: _centerOnUser,
                child: Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 2,
                        blurRadius: 5,
                      ),
                    ],
                  ),
                  child:
                      Icon(Icons.my_location, color: Colors.grey[700], size: 28),
                ),
              ),
            ),

            // ------------------- Toggle map type -------------------
            Positioned(
              top: 250,
              right: 16,
              child: GestureDetector(
                onTap: _toggleMapType,
                child: Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 2,
                        blurRadius: 5,
                      ),
                    ],
                  ),
                  child: Icon(
                    _currentMapType == MapType.normal
                        ? Icons.satellite
                        : Icons.map,
                    color: Colors.grey[700],
                    size: 28,
                  ),
                ),
              ),
            ),

            // ------------------- Mode toggle (bike / car) -------------------
            Positioned(
              bottom: 30,
              left: 100,
              right: 100,
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      spreadRadius: 2,
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: Row(
                    children: [
                      // Bike
                      Expanded(
                        child: Material(
                          color: _currentMode == StationType.bicycle
                              ? Colors.blue.shade600
                              : Colors.transparent,
                          child: InkWell(
                            onTap: () => _switchMode(StationType.bicycle),
                            child: Center(
                              child: Icon(
                                Icons.directions_bike,
                                color: _currentMode == StationType.bicycle
                                    ? Colors.white
                                    : Colors.grey[700],
                                size: 28,
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Separator
                      Container(
                        width: 1,
                        color: Colors.grey[300],
                      ),
                      // Car
                      Expanded(
                        child: Material(
                          color: _currentMode == StationType.electricVehicle
                              ? Colors.green.shade600
                              : Colors.transparent,
                          child: InkWell(
                            onTap: () =>
                                _switchMode(StationType.electricVehicle),
                            child: Center(
                              child: Icon(
                                Icons.electric_car,
                                color:
                                    _currentMode == StationType.electricVehicle
                                        ? Colors.white
                                        : Colors.grey[700],
                                size: 28,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
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