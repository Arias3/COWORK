class EquipoActividad {
  String? id; // String para Roble (ObjectId)
  int equipoId;
  String actividadId; // String para mantener consistencia con Activity
  DateTime asignadoEn;
  DateTime? fechaEntrega;
  String? estado; // 'pendiente', 'en_progreso', 'completada', 'vencida'
  String? comentarioProfesor;
  double? calificacion;
  DateTime? fechaCompletada;

  EquipoActividad({
    this.id,
    required this.equipoId,
    required this.actividadId, // String como en Activity
    DateTime? asignadoEn,
    this.fechaEntrega,
    this.estado = 'pendiente',
    this.comentarioProfesor,
    this.calificacion,
    this.fechaCompletada,
  }) : asignadoEn = asignadoEn ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'id': id,
    'equipoId': equipoId,
    'actividadId': actividadId, // String
    'asignadoEn': asignadoEn.toIso8601String(),
    'fechaEntrega': fechaEntrega?.toIso8601String(),
    'estado': estado,
    'comentarioProfesor': comentarioProfesor,
    'calificacion': calificacion,
    'fechaCompletada': fechaCompletada?.toIso8601String(),
  };

  factory EquipoActividad.fromJson(Map<String, dynamic> json) {
    return EquipoActividad(
      id: json['id'],
      equipoId: json['equipoId'],
      actividadId: json['actividadId'], // String
      asignadoEn: DateTime.parse(json['asignadoEn']),
      fechaEntrega: json['fechaEntrega'] != null
          ? DateTime.parse(json['fechaEntrega'])
          : null,
      estado: json['estado'],
      comentarioProfesor: json['comentarioProfesor'],
      calificacion: json['calificacion']?.toDouble(),
      fechaCompletada: json['fechaCompletada'] != null
          ? DateTime.parse(json['fechaCompletada'])
          : null,
    );
  }

  EquipoActividad copyWith({
    String? id,
    int? equipoId,
    String? actividadId, // String como en Activity
    DateTime? asignadoEn,
    DateTime? fechaEntrega,
    String? estado,
    String? comentarioProfesor,
    double? calificacion,
    DateTime? fechaCompletada,
  }) {
    return EquipoActividad(
      id: id ?? this.id,
      equipoId: equipoId ?? this.equipoId,
      actividadId: actividadId ?? this.actividadId,
      asignadoEn: asignadoEn ?? this.asignadoEn,
      fechaEntrega: fechaEntrega ?? this.fechaEntrega,
      estado: estado ?? this.estado,
      comentarioProfesor: comentarioProfesor ?? this.comentarioProfesor,
      calificacion: calificacion ?? this.calificacion,
      fechaCompletada: fechaCompletada ?? this.fechaCompletada,
    );
  }

  @override
  String toString() {
    return 'EquipoActividad(id: $id, equipoId: $equipoId, actividadId: $actividadId, estado: $estado)';
  }
}
