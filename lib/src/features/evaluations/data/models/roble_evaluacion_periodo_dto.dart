import '../../domain/entities/evaluacion_periodo.dart';

class RobleEvaluacionPeriodoDto {
  final String id;
  final String actividadId;
  final String titulo;
  final String? descripcion;
  final String fechaInicio; // ISO String
  final String? fechaFin; // ISO String
  final String fechaCreacion; // ISO String
  final String profesorId;
  final bool evaluacionEntrePares;
  final List<String> criteriosEvaluacion;
  final String estado;
  final bool habilitarComentarios;
  final double puntuacionMaxima;
  final String? fechaActualizacion; // ISO String

  RobleEvaluacionPeriodoDto({
    required this.id,
    required this.actividadId,
    required this.titulo,
    this.descripcion,
    required this.fechaInicio,
    this.fechaFin,
    required this.fechaCreacion,
    required this.profesorId,
    required this.evaluacionEntrePares,
    required this.criteriosEvaluacion,
    required this.estado,
    required this.habilitarComentarios,
    required this.puntuacionMaxima,
    this.fechaActualizacion,
  });

  factory RobleEvaluacionPeriodoDto.fromJson(Map<String, dynamic> json) {
    // Manejo especial para criteriosEvaluacion que puede venir como String o List
    List<String> criterios = [];
    if (json['criteriosEvaluacion'] != null) {
      if (json['criteriosEvaluacion'] is String) {
        // Si viene como String, intentar parsearlo
        String criteriosStr = json['criteriosEvaluacion'];
        if (criteriosStr.startsWith('{') && criteriosStr.endsWith('}')) {
          // Formato PostgreSQL array: {"item1","item2","item3"}
          criteriosStr = criteriosStr.substring(1, criteriosStr.length - 1);
          criterios = criteriosStr
              .split(',')
              .map((e) => e.trim().replaceAll('"', ''))
              .toList();
        } else {
          // Fallback: usar el string como un solo criterio
          criterios = [criteriosStr];
        }
      } else if (json['criteriosEvaluacion'] is List) {
        criterios = List<String>.from(json['criteriosEvaluacion']);
      }
    }

    return RobleEvaluacionPeriodoDto(
      id: json['_id'] ?? json['id'],
      actividadId: json['actividadId'],
      titulo: json['titulo'],
      descripcion: json['descripcion'],
      fechaInicio: json['fechaInicio'],
      fechaFin: json['fechaFin'],
      fechaCreacion: json['fechaCreacion'],
      profesorId: json['profesorId'],
      evaluacionEntrePares: json['evaluacionEntrePares'] ?? true,
      criteriosEvaluacion: criterios,
      estado: json['estado'] ?? 'pendiente',
      habilitarComentarios: json['habilitarComentarios'] ?? true,
      puntuacionMaxima: json['puntuacionMaxima']?.toDouble() ?? 5.0,
      fechaActualizacion: json['fechaActualizacion'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'actividadId': actividadId,
      'titulo': titulo,
      'descripcion': descripcion,
      'fechaInicio': fechaInicio,
      'fechaFin': fechaFin,
      'fechaCreacion': fechaCreacion,
      'profesorId': profesorId,
      'evaluacionEntrePares': evaluacionEntrePares,
      'criteriosEvaluacion': criteriosEvaluacion,
      'estado': estado,
      'habilitarComentarios': habilitarComentarios,
      'puntuacionMaxima': puntuacionMaxima,
      'fechaActualizacion': fechaActualizacion,
    };
  }

  factory RobleEvaluacionPeriodoDto.fromEntity(EvaluacionPeriodo entity) {
    return RobleEvaluacionPeriodoDto(
      id: entity.id,
      actividadId: entity.actividadId,
      titulo: entity.titulo,
      descripcion: entity.descripcion,
      fechaInicio: entity.fechaInicio.toIso8601String(),
      fechaFin: entity.fechaFin?.toIso8601String(),
      fechaCreacion: entity.fechaCreacion.toIso8601String(),
      profesorId: entity.profesorId,
      evaluacionEntrePares: entity.evaluacionEntrePares,
      criteriosEvaluacion: entity.criteriosEvaluacion,
      estado: entity.estado.name,
      habilitarComentarios: entity.habilitarComentarios,
      puntuacionMaxima: entity.puntuacionMaxima,
      fechaActualizacion: entity.fechaActualizacion?.toIso8601String(),
    );
  }

  EvaluacionPeriodo toEntity() {
    return EvaluacionPeriodo(
      id: id,
      actividadId: actividadId,
      titulo: titulo,
      descripcion: descripcion,
      fechaInicio: DateTime.parse(fechaInicio),
      fechaFin: fechaFin != null ? DateTime.parse(fechaFin!) : null,
      fechaCreacion: DateTime.parse(fechaCreacion),
      profesorId: profesorId,
      evaluacionEntrePares: evaluacionEntrePares,
      criteriosEvaluacion: criteriosEvaluacion,
      estado: EstadoEvaluacionPeriodo.values.firstWhere(
        (e) => e.name == estado,
        orElse: () => EstadoEvaluacionPeriodo.pendiente,
      ),
      habilitarComentarios: habilitarComentarios,
      puntuacionMaxima: puntuacionMaxima,
      fechaActualizacion: fechaActualizacion != null
          ? DateTime.parse(fechaActualizacion!)
          : null,
    );
  }
}
