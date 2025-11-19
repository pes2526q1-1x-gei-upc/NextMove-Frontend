import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CenterOnUserButtonWidget extends StatelessWidget {
  final LatLng? userLocation;
  final GoogleMapController? mapController;

  const CenterOnUserButtonWidget({
    Key? key,
    this.userLocation,
    this.mapController,
  }) : super(key: key);

  void _centerOnUser() {
    if (userLocation != null && mapController != null) {
      mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(userLocation!.latitude, userLocation!.longitude),
          15,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 100,
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
          child: Icon(Icons.my_location, color: Colors.grey[700], size: 28),
        ),
      ),
    );
  }
}
