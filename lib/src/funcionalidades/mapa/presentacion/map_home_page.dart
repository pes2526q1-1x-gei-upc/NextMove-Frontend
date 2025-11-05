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
  late GoogleMapController mapController;
  List<StationDetails>? stations = [];
  List<StationDetails>? bikeStations = [];
  final LatLng _catCenter = const LatLng(41.8205, 1.8677);
  final LatLng _bcnCenter = const LatLng(41.3851, 2.1734);
  LatLng? _userLocation;

  StreamSubscription<Position>?
  _positionStream; // listener de los cambios de ubicacion
  MapType _currentMapType = MapType.normal;

  // Estado para el modo (bicicleta o coche)
  StationType _currentMode = StationType
      .bicycle; // Por defecto bicicleta, ya usaremos el modo por defecto del usuario
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadStations(getAllEVStationDetails, (data) => stations = data);
    _loadStations(getAllBicycleStationDetails, (data) => bikeStations = data);
    //_loadBikeStations(getAllBikeStations, (data) => bikeStations = data);
    _initializateLocation();
  }

  Future<void> _loadStations(
    Future<List<StationDetails>?> Function() getStatsFunc,
    void Function(List<StationDetails>) onSuccess,
  ) async {
    try {
      final stationsToLoad = await getStatsFunc();
      if (stationsToLoad != null) {
        setState(() {
          onSuccess(stationsToLoad);
        });
      }
    } catch (e, stackTrace) {
      debugPrint('Error loading stations: $e');
      debugPrint('Stack trace: $stackTrace');
      // No lanzar la excepción, solo loguear
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar estaciones: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

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
    }

    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      _startLocationUpdates();
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Se requiere permiso de ubicación'),
        content: const Text(
          'Habilite la ubicación en la configuración del dispositivo',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Aceptar'),
          ),
          TextButton(
            onPressed: () {
              Geolocator.openAppSettings();
              Navigator.of(context).pop();
            },
            child: const Text('Abrir ajustes'),
          ),
        ],
      ),
    );
  }

  void _startLocationUpdates() {
    final LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high, //lo suyo seria lo que decida el usuario
      distanceFilter: 50, //se actualiza cada 50 metros
    );
    _positionStream =
        Geolocator.getPositionStream(
          locationSettings: locationSettings,
        ).listen((Position? position) {
          setState(() {
            if (position != null)
              _userLocation = LatLng(position.latitude, position.longitude);
          });
          print(
            position == null
                ? 'Unknown'
                : '${position.latitude.toString()}, ${position.longitude.toString()}',
          );
        });
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    _setMapStyle();
  }

  void _setMapStyle() async {
    String style = '''
    [
      {
        "featureType": "poi",
        "stylers": [
          {"visibility": "off"}
        ]
      }
    ]
    ''';
    mapController.setMapStyle(style);
  }

  // Cambiar modo
  void _switchMode(StationType mode) {
    setState(() {
      _currentMode = mode;
    });
    // LOGICA DE RECARGAR ESTACIONES SEGUN MODO
  }

  // Iconos bici y coches
  BitmapDescriptor _getCustomMarkerIcon() {
    if (_currentMode == StationType.bicycle) {
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
    } else {
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
    }
  }

  // Navegar a EditUserDataPreferences
  void _navigateToEditUser() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const EditUserDataPreferences(),
      ),
    );
  }

  void _centerOnUser() {
    if (_userLocation != null) {
      mapController.animateCamera(
        CameraUpdate.newLatLngZoom(
          _userLocation!,
          15, // Puedes ajustar el nivel de zoom al centrar
        ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(target: _bcnCenter, zoom: 12),
            markers: _buildMarkers(),
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            liteModeEnabled: false,
            compassEnabled: true,
            mapType: _currentMapType,
          ),

          // BOTON FOTO DE USUARIO
          Positioned(
            top:
                70, // Ajustado para status bar, igual cambiar para android o dependiendo del display del dispositivo...
            right: 16,
            child: GestureDetector(
              onTap: _navigateToEditUser,
              child: CircleAvatar(
                radius: 25,
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: Colors.grey[600], size: 28),
              ),
            ),
          ),

          // BARRA DE BUSQUEDA
          Positioned(
            top: 70,
            left: 16,
            right: 80,
            child: Container(
              height: 50,
              width: double.infinity,
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
                    horizontal: 20,
                    vertical: 15,
                  ),
                ),
                onSubmitted: (value) {
                  //LOGICA DE BUSQUEDA
                },
              ),
            ),
          ),

          // BOTON LISTA DE ESTACIONES
          Positioned(
            top: 130,
            right: 16,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StationList(
                      stationType: _currentMode,
                      latitude: _userLocation?.latitude ?? 0,
                      longitude: _userLocation?.longitude ?? 0,
                    ),
                  ),
                );
              },
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

          // BOTON CENTRAR EN USUARIO, hacemos uno propio y ocultamos el de google maps
          Positioned(
            top: 190, // Un poco más abajo que el botón de lista (130 + 50 + 10 de margen)
            right: 16,
            child: GestureDetector(
              onTap: _centerOnUser, // Llama a la función que creamos
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
                child: Icon(Icons.my_location, color: Colors.grey[700], size: 28),
              ),
            ),
          ),

        // BOTON CAMBIAR TIPO DE MAPA
          Positioned(
            top: 250, // Debajo del botón de centrado (190 + 50 + 10)
            right: 16,
            child: GestureDetector(
              onTap: _toggleMapType, // Llama a la nueva función
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
                // Cambiamos el icono según el modo actual
                child: Icon(
                  _currentMapType == MapType.normal 
                    ? Icons.satellite // Si es normal, muestra icono para cambiar a satélite
                    : Icons.map,      // Si es satélite, muestra icono para cambiar a normal
                  color: Colors.grey[700],
                  size: 28,
                ),
              ),
            ),
          ),

          // BOTONES DE TOGGLE MODO 
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
                    // BOTÓN BICICLETA - FONDO COMPLETO
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

                    // SEPARADOR CENTRAL
                    Container(
                      width: 1,
                      height: double.infinity,
                      color: Colors.grey[300],
                    ),

                    // BOTÓN COCHE - FONDO COMPLETO
                    Expanded(
                      child: Material(
                        color: _currentMode == StationType.electricVehicle
                            ? Colors.green.shade600
                            : Colors.transparent,
                        child: InkWell(
                          onTap: () => _switchMode(StationType.electricVehicle),
                          child: Center(
                            child: Icon(
                              Icons.electric_car,
                              color: _currentMode == StationType.electricVehicle
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
    );
  }

  Set<Marker> _buildMarkers() {
    Set<Marker> markers = {};
    //print del primer elemento de la estacion
    final customIcon = _getCustomMarkerIcon();
    List<StationDetails>? stationsToMark = [];
    if (_currentMode == StationType.bicycle) {
      stationsToMark = bikeStations;
    } else {
      stationsToMark = stations;
    }

    for (int i = 0; i < stationsToMark!.length; i++) {
      final station = stationsToMark![i];
      markers.add(
        Marker(
          markerId: MarkerId(station.id),
          position: LatLng(station.latitude, station.longitude),
          icon: customIcon,
          onTap: () {
            showModalBottomSheet(
              context: context,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              builder: (context) => Container(
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
                    const SizedBox(height: 8),
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
                              builder: (context) => StationDetailsPage(
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
          },
        ),
      );
    }

    return markers;
  }
}
