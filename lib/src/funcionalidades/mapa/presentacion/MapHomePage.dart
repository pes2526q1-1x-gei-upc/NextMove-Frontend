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
      ),
    );
  }

  Set<Marker> _buildMarkers() {
    Set<Marker> markers = {};
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
