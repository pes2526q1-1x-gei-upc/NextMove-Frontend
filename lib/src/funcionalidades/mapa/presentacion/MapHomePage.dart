import 'package:flutter/material.dart';
import 'package:nextmove_app/src/funcionalidades/estaciones/presentacion/StationList.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapHomePage extends StatefulWidget {
  const MapHomePage({super.key});
  @override
  State<MapHomePage> createState() => _MapHomePageState();
}

class _MapHomePageState extends State<MapHomePage> {
  late GoogleMapController mapController;

  final LatLng _bcnCenter = const LatLng(41.3851, 2.1734);

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
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
        markers: {
          const Marker(
            markerId: MarkerId('Gran Via de les Corts Catalanes, 642'),
            position: LatLng(41.3979779, 2.1801069),
            infoWindow: InfoWindow(
              title: 'Estación Gran Via de les Corts Catalanes, 642',
              snippet: 'Bicicletas',
            ),
          )
        },
      ),
    );
  }
}
