import 'dart:ui';
import 'package:nextmove_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:nextmove_app/src/funcionalidades/estaciones/presentacion/StationList.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/dominio/station_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class MapHomePage extends StatefulWidget {
  const MapHomePage({super.key});
  @override
  State<MapHomePage> createState() => _MapHomePageState();
}

class _MapHomePageState extends State<MapHomePage> {
  late GoogleMapController mapController;
  List<StationModel>? stations = [];
  List<StationModel>? bikeStations = [];
  //new target catalunya center
  final LatLng _catCenter = const LatLng(41.8205, 1.8677);
  //final LatLng _bcnCenter = const LatLng(41.3851, 2.1734);
  final LatLng _bcnCenter = const LatLng(41.3851, 2.1734);
  
  // Estado para el modo (bicicleta o coche)
  String _currentMode = 'bicicleta'; // Por defecto bicicleta, ya usaremos el modo por defecto del usuario
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadStations(getAllStations, (data) => stations = data,);
    _loadStations(getAllBikeStations, (data) => bikeStations = data,);
    //_loadBikeStations(getAllBikeStations, (data) => bikeStations = data);
  }

  Future<void> _loadStations(Future<List<StationModel>?> Function() getStatsFunc, void Function(List<StationModel>) onSuccess,) async {
    try {
      final stationsToLoad = await getStatsFunc();
      final stationsToLoad = await getAllStations();
      setState(() {
        onSuccess(stationsToLoad!);
      });
    } catch (e) {
      throw Exception('Error loading stations: $e');
    }
  }

 

  Future<void> _checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      await Geolocator.requestPermission();
    }
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
  void _switchMode(String mode) {
    setState(() {
      _currentMode = mode;
    });
    // LOGICA DE RECARGAR ESTACIONES SEGUN MODO
  }

  // Iconos bici y coches
  BitmapDescriptor _getCustomMarkerIcon() {
    if (_currentMode == 'bicicleta') {
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
    } else {
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
    }
  }

  // Navegar a EditUserDataPreferences
  void _navigateToEditUser() {
    //Navigator.push(
    //  context,
    //  MaterialPageRoute(builder: (context) => const EditUserDataPreferences()),
    //);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa de Estaciones'),
        backgroundColor: Colors.green[700],
      ),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: _catCenter,
          zoom: 7.5,
        ),
        markers: _buildMarkers(),
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        liteModeEnabled: false, 
        mapType: MapType.normal,  
      // Sin AppBar, todo en body
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _bcnCenter,
              zoom: 12,
            ),
            markers: _buildMarkers(),
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            liteModeEnabled: false,
            mapType: MapType.normal,
          ),

          // BOTON FOTO DE USUARIO
          Positioned(
            top: 70, // Ajustado para status bar, igual cambiar para android o dependiendo del display del dispositivo...
            left: 16,
            child: GestureDetector(
              onTap: _navigateToEditUser,
              child: CircleAvatar(
                radius: 25, 
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.person,
                  color: Colors.grey[600],
                  size: 28, 
                ),
              ),
            ),
          ),

          // BARRA DE BUSQUEDA
          Positioned(
            top: 70, 
            left: 80, 
            right: 16,
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
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                ),
                onSubmitted: (value) {
                  //LOGICA DE BUSQUEDA
                },
              ),
            ),
          ),

          // BOTONES DE TOGGLE MODO
          Positioned(
            bottom: 30,
            left: 140,
            right: 140,
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(3),
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
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Segmento bicicleta
                    Expanded(
                      flex: 1,
                      child: GestureDetector(
                        onTap: () => _switchMode('bicicleta'),
                        child: AnimatedContainer( // AnimatedContainer para transiciones 
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: _currentMode == 'bicicleta' ? Colors.blue.shade600 : Colors.transparent,
                            borderRadius: BorderRadius.circular(26), 
                          ),
                          child: Icon(
                            Icons.directions_bike,
                            color: _currentMode == 'bicicleta' ? Colors.white : Colors.grey[700],
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                    
                    // Segmento coche
                    Expanded(
                      flex: 1,
                      child: GestureDetector(
                        onTap: () => _switchMode('coche'),
                        child: AnimatedContainer( 
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: _currentMode == 'coche' ? Colors.green.shade600 : Colors.transparent,
                            borderRadius: BorderRadius.circular(26), 
                          ),
                          child: Icon(
                            Icons.electric_car,
                            color: _currentMode == 'coche' ? Colors.white : Colors.grey[700],
                            size: 24,
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
    for(int i = 0; i < stations!.length; i++) {
    if (stations == null || stations!.isEmpty) {
      print("null stations");
      return {};
    }

    Set<Marker> markers = {};
    final customIcon = _getCustomMarkerIcon(); 

    for (int i = 0; i < stations!.length; i++) {
      final station = stations![i];
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
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      station.address,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _currentMode == 'bicicleta' ? Colors.blue : Colors.green,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          //ACCION PARA LLEVARLE A LA INFORMACION DETALLADA
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

    for(int j = 0; j < bikeStations!.length; j++) {
      final bikeStation = bikeStations![j];
      markers.add(
        Marker(
          markerId: MarkerId(bikeStation.id),
          position: LatLng(bikeStation.latitude, bikeStation.longitude),
          infoWindow: InfoWindow(
            title: bikeStation.name,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        ),
      );
    }

    return markers;
  }
}