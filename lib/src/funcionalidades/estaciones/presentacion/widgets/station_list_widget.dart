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
    if (context.mounted) {
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
  }

  Future<LatLng> _getCurrentPosition() async {
    try {
      const LocationSettings locationSettings = LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
      );
      Position currentPosition = await Geolocator.getCurrentPosition(
        locationSettings: locationSettings,
      );
      return LatLng(currentPosition.latitude, currentPosition.longitude);
    } catch (e) {
      return const LatLng(0.0, 0.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final shadowColor = Colors.black.withValues(alpha: isDark ? 0.45 : 0.18);

    return Positioned(
      top: 70,
      right: 16,
      child: GestureDetector(
        onTap: () => _navigateToStationList(context),
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
            Icons.list,
            color: theme.colorScheme.onSurface,
            size: 28,
          ),
        ),
      ),
    );
  }
}
