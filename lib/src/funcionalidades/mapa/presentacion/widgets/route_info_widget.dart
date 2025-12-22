import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nextmove_app/src/funcionalidades/estaciones/dominio/station_model.dart';
import 'package:nextmove_app/l10n/app_localizations.dart';


class RouteInfoWidget extends StatelessWidget {
  final LatLng origin;
  final StationDetails destination;

  const RouteInfoWidget({
    super.key,
    required this.origin,
    required this.destination,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildLocationRow(
                context,
                icon: Icons.my_location,
                iconColor: Colors.blue,
                text: l10n.uLoc,
              ),
              _buildConnectorLine(),
              _buildLocationRow(
                context,
                icon: Icons.location_on,
                iconColor: Colors.red,
                text: destination.name!,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationRow(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String text,
  }) {
    final theme = Theme.of(context);
    
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurface.withOpacity(0.8),
              letterSpacing: -0.2,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildConnectorLine() {
    return Padding(
      padding: const EdgeInsets.only(left: 11.5, top: 4, bottom: 4),
      child: Row(
        children: [
          Container(
            width: 1.5,
            height: 20,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.blue.shade600.withOpacity(0.4),
                  Colors.red.shade600.withOpacity(0.4),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
