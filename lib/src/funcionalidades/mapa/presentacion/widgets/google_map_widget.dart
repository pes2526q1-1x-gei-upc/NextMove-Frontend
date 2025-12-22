import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapWidget extends StatefulWidget {
  final CameraPosition initialCameraPosition;
  final Set<Marker> markers;
  final Polyline polyline;
  final Polyline navigationRoutePolyline;
  final MapType mapType;
  final void Function(GoogleMapController)? onMapCreated;


  final EdgeInsets padding;

  const MapWidget({
    super.key,
    required this.initialCameraPosition,
    required this.markers,
    required this.polyline,
    required this.navigationRoutePolyline,
    required this.mapType,
    this.onMapCreated,
    this.padding = EdgeInsets.zero,
  });

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      padding: widget.padding,
      onMapCreated: widget.onMapCreated,
      initialCameraPosition: widget.initialCameraPosition,
      markers: widget.markers,
      polylines: {widget.polyline, widget.navigationRoutePolyline},
      mapType: widget.mapType,
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      compassEnabled: true,
    );
  }
}
