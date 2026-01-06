class StationAlert {
  final String id;
  final String userEmail;
  final String stationId;
  final List<String> horas; // Formato 'HH:MM'
  final List<int> diasSemana; // 0=Lunes, 6=Domingo
  final bool activa;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? stationNombre;
  final String? stationDireccion;

  StationAlert({
    required this.id,
    required this.userEmail,
    required this.stationId,
    required this.horas,
    required this.diasSemana,
    required this.activa,
    required this.createdAt,
    required this.updatedAt,
    this.stationNombre,
    this.stationDireccion,
  });

  factory StationAlert.fromJson(Map<String, dynamic> json) {
    return StationAlert(
      id: json['id']?.toString() ?? '',
      userEmail: json['userEmail'] as String? ?? '',
      stationId: json['stationId'] as String? ?? '',
      horas: json['horas'] != null 
          ? List<String>.from(json['horas'] as List)
          : [],
      diasSemana: json['diasSemana'] != null
          ? List<int>.from((json['diasSemana'] as List).map((e) => e is int ? e : int.parse(e.toString())))
          : [],
      activa: json['activa'] as bool? ?? true,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
      stationNombre: json['stationNombre'] as String?,
      stationDireccion: json['stationDireccion'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userEmail': userEmail,
      'stationId': stationId,
      'horas': horas,
      'diasSemana': diasSemana,
      'activa': activa,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'stationNombre': stationNombre,
      'stationDireccion': stationDireccion,
    };
  }

  StationAlert copyWith({
    String? id,
    String? userEmail,
    String? stationId,
    List<String>? horas,
    List<int>? diasSemana,
    bool? activa,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? stationNombre,
    String? stationDireccion,
  }) {
    return StationAlert(
      id: id ?? this.id,
      userEmail: userEmail ?? this.userEmail,
      stationId: stationId ?? this.stationId,
      horas: horas ?? this.horas,
      diasSemana: diasSemana ?? this.diasSemana,
      activa: activa ?? this.activa,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      stationNombre: stationNombre ?? this.stationNombre,
      stationDireccion: stationDireccion ?? this.stationDireccion,
    );
  }

  // Helper para obtener nombres de días
  static String getDiaNombre(int dia) {
    const dias = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];
    return dias[dia];
  }

  // Helper para obtener lista de nombres de días
  List<String> get diasSemanaNombres {
    return diasSemana.map((dia) => getDiaNombre(dia)).toList();
  }
}

