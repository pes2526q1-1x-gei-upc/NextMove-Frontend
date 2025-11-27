import 'package:flutter/foundation.dart';

enum StationType {
    bicycle,
    electricVehicle,
}

class StationDetails {
    final String id;
    final String? name;
    final String? address;
    final int? totalSlots;
    final int? availableSlots;
    final double? rating;
    final double? distanceKm;
    final double? latitude;
    final double? longitude;
    bool? isFavorite;

    StationDetails({
    required this.id,
    this.name,
    this.address,
    this.totalSlots,
    this.availableSlots,
    this.rating,
    this.latitude,
    this.longitude,
    this.distanceKm,
    this.isFavorite,
    });
    
    StationDetails copyWith({double? rating}) {
      return StationDetails(
        id: id,
        name: name,
        address: address,
        totalSlots: totalSlots,
        availableSlots: availableSlots,
        rating: rating ?? this.rating,
        latitude: latitude,
        longitude: longitude,
        distanceKm: distanceKm,
      );
    }
}

enum BicycleStationState {
  operational,
  closed,
}

class BicycleStationDetails extends StationDetails {
  final int? availableBikes;
  final bool? electricRechargeStation;
  final bool? canAnchorBikes;
  final bool? canRentBikes;
  final BicycleStationState? state;
  final int? availableMechanicalBikes;
  final int? availableElectricBikes;

  BicycleStationDetails({
    required super.id,
    super.name,
    super.address,
    super.totalSlots,
    super.availableSlots,
    super.rating,
    super.latitude,
    super.longitude,
    super.distanceKm,
    this.availableBikes,
    this.electricRechargeStation,
    this.canAnchorBikes,
    this.canRentBikes,
    this.state,
    this.availableMechanicalBikes,
    this.availableElectricBikes,
  });

  // --- IMPLEMENTACIÓN ESPECÍFICA DE COPYWITH ---
  @override
  BicycleStationDetails copyWith({double? rating}) {
    return BicycleStationDetails(
      id: id,
      name: name,
      address: address,
      totalSlots: totalSlots,
      availableSlots: availableSlots,
      rating: rating ?? this.rating,
      latitude: latitude,
      longitude: longitude,
      distanceKm: distanceKm,
      availableBikes: availableBikes,
      electricRechargeStation: electricRechargeStation,
      canAnchorBikes: canAnchorBikes,
      canRentBikes: canRentBikes,
      state: state,
      availableMechanicalBikes: availableMechanicalBikes,
      availableElectricBikes: availableElectricBikes,
    );
  }

  factory BicycleStationDetails.fromJson(Map<String, dynamic> data) {
    // print('Parsing station: id=${data['id']}, nombre=${data['nombre']}');
    if (kDebugMode) {
      if (data['id'] == null) print('id is null for bicycle station');
      if (data['nombre'] == null) print('nombre is null for bicycle station id: ${data['id']}');
      if (data['direccion'] == null) print('direccion is null for bicycle station id: ${data['id']}');
      if (data['coordenadas'] == null || data['coordenadas']['latitude'] == null || data['coordenadas']['longitude'] == null) print('coordenadas is null for bicycle station id: ${data['id']}');
      if (data['plazasTotales'] == null) print('plazasTotales is null for bicycle station id: ${data['id']}');
      if (data['anclajesDisponibles'] == null) print('anclajesDisponibles is null for bicycle station id: ${data['id']}');
      if (data['bicisMecanicasDisponibles'] == null) print('bicisMecanicasDisponibles is null for bicycle station id: ${data['id']}');
      if (data['bicisElectricasDisponibles'] == null) print('bicisElectricasDisponibles is null for bicycle station id: ${data['id']}');
      if (data['estacionCargaElectrica'] == null) print('estacionCargaElectrica is null for bicycle station id: ${data['id']}');
      if (data['sePuedeAnclarBicis'] == null) print('sePuedeAnclarBicis is null for bicycle station id: ${data['id']}');
      if (data['sePuedenAlquilarBicis'] == null) print('sePuedenAlquilarBicis is null for bicycle station id: ${data['id']}');
      if (data['estado'] == null) print('estado is null for bicycle station id: ${data['id']}');
    }
    return BicycleStationDetails(
      id: data['id'],
      name: data['nombre'] as String?,
      address: data['direccion'] as String?,
      latitude: (data['coordenadas']?['latitude'] as num?)?.toDouble(),
      longitude: (data['coordenadas']?['longitude'] as num?)?.toDouble(),
      totalSlots: data['plazasTotales'] as int?,
      availableSlots: data['anclajesDisponibles'] as int?,
      rating: data['rating'] != null ? (data['rating'] as num).toDouble() : null,
      distanceKm: data['distanciaKm'] != null ? (data['distanciaKm'] as num).toDouble() : null,
      availableBikes: data['bicisMecanicasDisponibles'] != null && data['bicisElectricasDisponibles'] != null ? (data['bicisMecanicasDisponibles'] as int) + (data['bicisElectricasDisponibles'] as int) : null,
      electricRechargeStation: data['estacionCargaElectrica'] as bool?,
      canAnchorBikes: data['sePuedeAnclarBicis'] as bool?,
      canRentBikes: data['sePuedenAlquilarBicis'] as bool?,
      state: data['estado'] == "OPERATIVA" ? BicycleStationState.operational : data['estado'] == "CERRADA" ? BicycleStationState.closed : null,
      availableMechanicalBikes: data['bicisMecanicasDisponibles'] as int?,
      availableElectricBikes: data['bicisElectricasDisponibles'] as int?,
    );
  }
}

enum PowerType {
  ac,
  dc,
}

enum ConnectionType {
  css2,
  chademo,
  mennekes,
  shucko,
}

enum ConnectorStatus {
    available,
    occupied,
    unavailable,
}

class EVStationDetails extends StationDetails {
  final List<Connector>? connectors;
  final String? accessType;
  final bool? isSuperFast;

  EVStationDetails({
    required super.id,
    super.name,
    super.address,
    super.availableSlots,
    super.totalSlots,
    super.rating,
    super.latitude,
    super.longitude,
    super.distanceKm,
    this.isSuperFast,
    this.connectors,
    this.accessType,
  });

  // --- IMPLEMENTACIÓN ESPECÍFICA DE COPYWITH ---
  @override
  EVStationDetails copyWith({double? rating}) {
    return EVStationDetails(
      id: id,
      name: name,
      address: address,
      availableSlots: availableSlots,
      totalSlots: totalSlots,
      rating: rating ?? this.rating, 
      latitude: latitude,
      longitude: longitude,
      distanceKm: distanceKm,
      isSuperFast: isSuperFast,
      connectors: connectors,
      accessType: accessType,
    );
  }

  factory EVStationDetails.fromJson(Map<String, dynamic> data) {
    List<Connector>? connectors;
    if (data['connectors'] != null) {
      connectors = [];
      for (var connectorData in data['connectors']) {
        if (kDebugMode) {
          if (connectorData['type'] == null) print('connector type is null for EV station id: ${data['id']}');
          if (connectorData['powerKw'] == null) print('connector powerKw is null for EV station id: ${data['id']}');
          if (connectorData['status'] == null) print('connector status is null for EV station id: ${data['id']}');
        }
        connectors.add(Connector(
          connectionType: ConnectionType.values.firstWhere(
            (e) => e.name.toUpperCase() == (connectorData['type'] as String?)?.toUpperCase(),
            orElse: () => ConnectionType.mennekes,
          ),
          powerKw: (connectorData['powerKw'] as num?)?.toDouble(),
          status: ConnectorStatus.values.firstWhere(
            (e) => e.name.toUpperCase() == (connectorData['status'] as String?)?.toUpperCase(),
            orElse: () => ConnectorStatus.unavailable,
          ),
        ));
      }
    }
    if (kDebugMode) {
      if (data['id'] == null) print('id is null for EV station');
      if (data['name'] == null) print('name is null for EV station id: ${data['id']}');
      if (data['address'] == null) print('address is null for EV station id: ${data['id']}');
      if (data['coordinates'] == null || data['coordinates']['latitude'] == null || data['coordinates']['longitude'] == null) print('coordinates is null for EV station id: ${data['id']}');
      if (data['isSuperFast'] == null) print('isSuperFast is null for EV station id: ${data['id']}');
      if (data['accessType'] == null) print('accessType is null for EV station id: ${data['id']}');
    }
    // print('Parsing EV station: id=${data['id']}, name=${data['name']}');
    return EVStationDetails(
      id: data['id'],
      name: data['name'] as String?,
      address: data['address'] as String?,
      latitude: (data['coordinates']?['latitude'] as num?)?.toDouble(),
      longitude: (data['coordinates']?['longitude'] as num?)?.toDouble(),
      availableSlots: connectors?.where((c) => c.status == ConnectorStatus.available).length ?? 0,
      totalSlots: connectors?.length,
      rating: data['rating'] != null ? (data['rating'] as num).toDouble() : null, 
      distanceKm: data['distance'] != null ? (data['distance']).toDouble() : null,
      isSuperFast: data['isSuperFast'] as bool?,
      connectors: connectors,
      accessType: data['accessType'] as String?,
    );
  }
}

class Connector {
    final ConnectionType? connectionType;
    final double? powerKw;
    final ConnectorStatus? status;

    Connector({
        this.connectionType,
        this.powerKw,
        this.status,
    });
}