import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapWidget extends StatefulWidget {
  final CameraPosition initialCameraPosition;
  final Set<Marker> markers;
  final MapType mapType;
  final void Function(GoogleMapController)? onMapCreated;


  const MapWidget({
    Key? key,
    required this.initialCameraPosition,
    required this.markers,
    required this.mapType,
    this.onMapCreated,
  }) : super(key: key);

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  GoogleMapController? _controller;

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      onMapCreated: widget.onMapCreated,
      initialCameraPosition: widget.initialCameraPosition,
      markers: widget.markers,
      mapType: widget.mapType,
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      compassEnabled: true,
    );
  }
}
