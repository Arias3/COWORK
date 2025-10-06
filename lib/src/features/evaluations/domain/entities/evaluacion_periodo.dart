enum EstadoEvaluacionPeriodo { pendiente, activo, finalizado }

class EvaluacionPeriodo {
  final String id;
  final String actividadId; // Actividad asociada
  final String titulo;
  final String? descripcion;
  final DateTime fechaInicio;
  final DateTime? fechaFin;
  final DateTime fechaCreacion;
  final String profesorId; // Profesor que creó la evaluación
  final bool evaluacionEntrePares;
  final List<String> criteriosEvaluacion; // Lista de criterios seleccionados
  final EstadoEvaluacionPeriodo estado;
  final bool habilitarComentarios;
  final double puntuacionMaxima;
  final DateTime? fechaActualizacion;

  EvaluacionPeriodo({
    required this.id,
    required this.actividadId,
    required this.titulo,
    this.descripcion,
    required this.fechaInicio,
    this.fechaFin,
    required this.fechaCreacion,
    required this.profesorId,
    this.evaluacionEntrePares = true,
    required this.criteriosEvaluacion,
    this.estado = EstadoEvaluacionPeriodo.pendiente,
    this.habilitarComentarios = true,
    this.puntuacionMaxima = 5.0,
    this.fechaActualizacion,
  });

  EvaluacionPeriodo copyWith({
    String? id,
    String? actividadId,
    String? titulo,
    String? descripcion,
    DateTime? fechaInicio,
    DateTime? fechaFin,
    DateTime? fechaCreacion,
    String? profesorId,
    bool? evaluacionEntrePares,
    List<String>? criteriosEvaluacion,
    EstadoEvaluacionPeriodo? estado,
    bool? habilitarComentarios,
    double? puntuacionMaxima,
    DateTime? fechaActualizacion,
  }) {
    return EvaluacionPeriodo(
      id: id ?? this.id,
      actividadId: actividadId ?? this.actividadId,
      titulo: titulo ?? this.titulo,
      descripcion: descripcion ?? this.descripcion,
      fechaInicio: fechaInicio ?? this.fechaInicio,
      fechaFin: fechaFin ?? this.fechaFin,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      profesorId: profesorId ?? this.profesorId,
      evaluacionEntrePares: evaluacionEntrePares ?? this.evaluacionEntrePares,
      criteriosEvaluacion: criteriosEvaluacion ?? this.criteriosEvaluacion,
      estado: estado ?? this.estado,
      habilitarComentarios: habilitarComentarios ?? this.habilitarComentarios,
      puntuacionMaxima: puntuacionMaxima ?? this.puntuacionMaxima,
      fechaActualizacion: fechaActualizacion ?? this.fechaActualizacion,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'actividadId': actividadId,
      'titulo': titulo,
      'descripcion': descripcion,
      'fechaInicio': fechaInicio.toIso8601String(),
      'fechaFin': fechaFin?.toIso8601String(),
      'fechaCreacion': fechaCreacion.toIso8601String(),
      'profesorId': profesorId,
      'evaluacionEntrePares': evaluacionEntrePares,
      'criteriosEvaluacion': criteriosEvaluacion,
      'estado': estado.name,
      'habilitarComentarios': habilitarComentarios,
      'puntuacionMaxima': puntuacionMaxima,
      'fechaActualizacion': fechaActualizacion?.toIso8601String(),
    };
  }

  factory EvaluacionPeriodo.fromJson(Map<String, dynamic> json) {
    return EvaluacionPeriodo(
      id: json['id'],
      actividadId: json['actividadId'],
      titulo: json['titulo'],
      descripcion: json['descripcion'],
      fechaInicio: DateTime.parse(json['fechaInicio']),
      fechaFin: json['fechaFin'] != null
          ? DateTime.parse(json['fechaFin'])
          : null,
      fechaCreacion: DateTime.parse(json['fechaCreacion']),
      profesorId: json['profesorId'],
      evaluacionEntrePares: json['evaluacionEntrePares'] ?? true,
      criteriosEvaluacion: List<String>.from(json['criteriosEvaluacion']),
      estado: EstadoEvaluacionPeriodo.values.firstWhere(
        (e) => e.name == json['estado'],
        orElse: () => EstadoEvaluacionPeriodo.pendiente,
      ),
      habilitarComentarios: json['habilitarComentarios'] ?? true,
      puntuacionMaxima: json['puntuacionMaxima']?.toDouble() ?? 5.0,
      fechaActualizacion: json['fechaActualizacion'] != null
          ? DateTime.parse(json['fechaActualizacion'])
          : null,
    );
  }

  bool get estaActivo => estado == EstadoEvaluacionPeriodo.activo;
  bool get haFinalizado => estado == EstadoEvaluacionPeriodo.finalizado;
  bool get estaPendiente => estado == EstadoEvaluacionPeriodo.pendiente;

  bool get puedeEvaluar {
    final ahora = DateTime.now();
    return estaActivo &&
        ahora.isAfter(fechaInicio) &&
        (fechaFin == null || ahora.isBefore(fechaFin!));
  }
}
