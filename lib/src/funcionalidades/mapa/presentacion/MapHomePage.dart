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
  final LatLng _bcnCenter = const LatLng(41.3851, 2.1734);

  @override
  void initState() {
    super.initState();
    _loadStations();
  }

  Future<void> _loadStations() async {
    try {
      print("iniciada");
      final stationsToLoad = await getAllStations();
      print("finalizada");
      setState(() {
        stations = stationsToLoad;
      });
    } catch (e) {
      print('Error loading stations: $e');
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
          target: _bcnCenter,
          zoom: 12,
        ),
        markers: _buildMarkers(),
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        liteModeEnabled: false, 
        mapType: MapType.normal,  
      ),
    );
  }

  Set<Marker> _buildMarkers() {
    if(stations!.isEmpty) {
      print("null stations");
      return {};
    }

    Set<Marker> markers = {};
    final firstStation = stations?[0];
    //print del primer elemento de la estacion
    for(int i = 0; i < stations!.length; i++) {
      final station = stations![i];
      markers.add(
        Marker(
          markerId: MarkerId(station.id),
          position: LatLng(station.latitude, station.longitude),
          infoWindow: InfoWindow(
            title: station.name,
          ),
        ),
      );
    }

    return markers;
  }
 
}
