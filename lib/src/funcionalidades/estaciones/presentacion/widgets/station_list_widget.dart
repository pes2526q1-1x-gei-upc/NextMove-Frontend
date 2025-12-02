import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:nextmove_app/src/funcionalidades/estaciones/dominio/station_model.dart';
import 'package:nextmove_app/src/funcionalidades/estaciones/presentacion/station_list.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';


class StationListButtonWidget extends StatelessWidget {
  final StationType currentMode;
  final LatLng? userLocation;

  const StationListButtonWidget({
    super.key,
    required this.currentMode,
    this.userLocation,
  });

  void _navigateToStationList(BuildContext context) async {
    LatLng location = userLocation ?? await _getCurrentPosition();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StationList(
          stationType: currentMode,
          latitude: location.latitude,
          longitude: location.longitude,
        ),
      ),
    );
  }

  Future<LatLng> _getCurrentPosition() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      return LatLng(position.latitude, position.longitude);
    } catch (e) {
      return const LatLng(0.0, 0.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 70,
      right: 16,
      child: GestureDetector(
        onTap: () => _navigateToStationList(context),
        child: Container(
          height: 50,
          width: 50,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.3),
                spreadRadius: 2,
                blurRadius: 5,
              ),
            ],
          ),
          child: Icon(Icons.list, color: Colors.grey[700], size: 28),
        ),
      ),
    );
  }
}
