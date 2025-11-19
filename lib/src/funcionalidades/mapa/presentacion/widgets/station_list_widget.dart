import 'package:flutter/material.dart';
import 'package:nextmove_app/src/funcionalidades/estaciones/dominio/station_model.dart';
import 'package:nextmove_app/src/funcionalidades/estaciones/presentacion/station_list.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';


class StationListButtonWidget extends StatelessWidget {
  final StationType currentMode;
  final LatLng? userLocation;

  const StationListButtonWidget({
    Key? key,
    required this.currentMode,
    this.userLocation,
  }) : super(key: key);

  void _navigateToStationList(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StationList(
          stationType: currentMode,
          latitude: userLocation?.latitude ?? 0,
          longitude: userLocation?.longitude ?? 0,
        ),
      ),
    );
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
                color: Colors.grey.withOpacity(0.3),
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
