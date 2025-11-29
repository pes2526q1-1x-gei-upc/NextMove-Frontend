import 'package:flutter/material.dart';
import 'package:nextmove_app/l10n/app_localizations.dart';
import 'package:nextmove_app/src/funcionalidades/estaciones/dominio/station_model.dart';

extension ConnectionTypeLocalization on ConnectionType {
  String localized(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (this) {
      case ConnectionType.css2: return l10n.css2;
      case ConnectionType.chademo: return l10n.chademo;
      case ConnectionType.mennekes: return l10n.mennekes;
      case ConnectionType.shucko: return l10n.shucko;
    }
  }
}

extension ConnectorStatusLocalization on ConnectorStatus {
  String localized(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (this) {
      case ConnectorStatus.available: return l10n.available;
      case ConnectorStatus.occupied: return l10n.occupied;
      case ConnectorStatus.unavailable: return l10n.unavailable;
    }
  }

  Color get color {
    switch (this) {
      case ConnectorStatus.available: return Colors.green;
      case ConnectorStatus.occupied: return Colors.orange;
      case ConnectorStatus.unavailable: return Colors.red;
    }
  }
}

extension BicycleStationStateLocalization on BicycleStationState {
  String localized(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (this) {
      case BicycleStationState.operational: return l10n.operational;
      case BicycleStationState.closed: return l10n.closed;
    }
  }
}