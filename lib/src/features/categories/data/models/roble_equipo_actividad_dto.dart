import '../../domain/entities/equipo_actividad_entity.dart';

class RobleEquipoActividadDto {
  final String? id; // String como otros DTOs de Roble
  final dynamic
  equipoId; // dynamic para manejar tanto int (local) como String (Roble)
  final String actividadId; // String como Activity
  final String asignadoEn;
  final String? fechaEntrega;
  final String? estado;
  final String? comentarioProfesor;
  final double? calificacion;
  final String? fechaCompletada;

  RobleEquipoActividadDto({
    this.id,
    required this.equipoId,
    required this.actividadId,
    required this.asignadoEn,
    this.fechaEntrega,
    this.estado,
    this.comentarioProfesor,
    this.calificacion,
    this.fechaCompletada,
  });

  Map<String, dynamic> toJson() => {
    if (id != null) '_id': id, // Usar '_id' como en otros DTOs de Roble
    'equipo_id': equipoId,
    'actividad_id': actividadId,
    'asignado_en': asignadoEn,
    'fecha_entrega': fechaEntrega, // null si no hay fecha
    'estado': estado ?? 'pendiente',
    'comentario_profesor': comentarioProfesor, // null si no hay comentario
    'calificacion': calificacion, // null si no hay calificación
    'fecha_completada': fechaCompletada, // null si no hay fecha
  };

  factory RobleEquipoActividadDto.fromJson(Map<String, dynamic> json) =>
      RobleEquipoActividadDto(
        id:
            json['_id'] ??
            json['id'], // Usar '_id' primero, luego 'id' como fallback
        equipoId:
            json['equipo_id'], // Mantenemos como viene de la base de datos
        actividadId: json['actividad_id'],
        asignadoEn: json['asignado_en'],
        fechaEntrega: json['fecha_entrega'],
        estado: json['estado'],
        comentarioProfesor: json['comentario_profesor'],
        calificacion: json['calificacion']?.toDouble(),
        fechaCompletada: json['fecha_completada'],
      );

  factory RobleEquipoActividadDto.fromEntity(EquipoActividad entity) =>
      RobleEquipoActividadDto(
        id: entity.id,
        equipoId: entity.equipoId,
        actividadId: entity.actividadId,
        asignadoEn: entity.asignadoEn.toIso8601String(),
        fechaEntrega: entity.fechaEntrega?.toIso8601String(),
        estado: entity.estado,
        comentarioProfesor: entity.comentarioProfesor,
        calificacion: entity.calificacion,
        fechaCompletada: entity.fechaCompletada?.toIso8601String(),
      );

  EquipoActividad toEntity() => EquipoActividad(
    id: id,
    equipoId: equipoId,
    actividadId: actividadId,
    asignadoEn: DateTime.parse(asignadoEn),
    fechaEntrega: fechaEntrega != null ? DateTime.parse(fechaEntrega!) : null,
    estado: estado,
    comentarioProfesor: comentarioProfesor,
    calificacion: calificacion,
    fechaCompletada: fechaCompletada != null
        ? DateTime.parse(fechaCompletada!)
        : null,
  );
}
