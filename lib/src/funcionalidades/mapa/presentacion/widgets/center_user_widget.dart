import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CenterOnUserButtonWidget extends StatelessWidget {
  final LatLng? userLocation;
  final GoogleMapController? mapController;

  const CenterOnUserButtonWidget({
    super.key,
    this.userLocation,
    this.mapController,
  });

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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final shadowColor = Colors.black.withOpacity(isDark ? 0.45 : 0.18);

    return Positioned(
      bottom: 220,
      right: 16,
      child: GestureDetector(
        onTap: _centerOnUser,
        child: Container(
          height: 50,
          width: 50,
          decoration: BoxDecoration(
            color: theme.cardColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: shadowColor,
                spreadRadius: 1,
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Icon(
            Icons.my_location,
            color: theme.colorScheme.onSurface,
            size: 28,
          ),
        ),
      ),
    );
  }
}
