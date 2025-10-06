import 'criterios_evaluacion.dart';

class EvaluacionIndividual {
  final String id;
  final String evaluacionPeriodoId; // ID del período de evaluación
  final String evaluadorId; // Usuario que evalúa
  final String evaluadoId; // Usuario evaluado
  final String equipoId; // Equipo al que pertenecen
  final Map<String, double> calificaciones; // criterio -> calificación
  final String? comentarios;
  final DateTime fechaCreacion;
  final DateTime? fechaActualizacion;
  final bool completada;

  EvaluacionIndividual({
    required this.id,
    required this.evaluacionPeriodoId,
    required this.evaluadorId,
    required this.evaluadoId,
    required this.equipoId,
    required this.calificaciones,
    this.comentarios,
    required this.fechaCreacion,
    this.fechaActualizacion,
    this.completada = false,
  });

  EvaluacionIndividual copyWith({
    String? id,
    String? evaluacionPeriodoId,
    String? evaluadorId,
    String? evaluadoId,
    String? equipoId,
    Map<String, double>? calificaciones,
    String? comentarios,
    DateTime? fechaCreacion,
    DateTime? fechaActualizacion,
    bool? completada,
  }) {
    return EvaluacionIndividual(
      id: id ?? this.id,
      evaluacionPeriodoId: evaluacionPeriodoId ?? this.evaluacionPeriodoId,
      evaluadorId: evaluadorId ?? this.evaluadorId,
      evaluadoId: evaluadoId ?? this.evaluadoId,
      equipoId: equipoId ?? this.equipoId,
      calificaciones:
          calificaciones ?? Map<String, double>.from(this.calificaciones),
      comentarios: comentarios ?? this.comentarios,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      fechaActualizacion: fechaActualizacion ?? this.fechaActualizacion,
      completada: completada ?? this.completada,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'evaluacionPeriodoId': evaluacionPeriodoId,
      'evaluadorId': evaluadorId,
      'evaluadoId': evaluadoId,
      'equipoId': equipoId,
      'calificaciones': calificaciones,
      'comentarios': comentarios,
      'fechaCreacion': fechaCreacion.toIso8601String(),
      'fechaActualizacion': fechaActualizacion?.toIso8601String(),
      'completada': completada,
    };
  }

  factory EvaluacionIndividual.fromJson(Map<String, dynamic> json) {
    return EvaluacionIndividual(
      id: json['id'],
      evaluacionPeriodoId: json['evaluacionPeriodoId'],
      evaluadorId: json['evaluadorId'],
      evaluadoId: json['evaluadoId'],
      equipoId: json['equipoId'],
      calificaciones: Map<String, double>.from(json['calificaciones'] ?? {}),
      comentarios: json['comentarios'],
      fechaCreacion: DateTime.parse(json['fechaCreacion']),
      fechaActualizacion: json['fechaActualizacion'] != null
          ? DateTime.parse(json['fechaActualizacion'])
          : null,
      completada: json['completada'] ?? false,
    );
  }

  // Métodos de utilidad
  double get promedioCalificaciones {
    if (calificaciones.isEmpty) return 0.0;
    double suma = calificaciones.values.reduce((a, b) => a + b);
    return suma / calificaciones.length;
  }

  NivelEvaluacion get nivelPromedio {
    return NivelEvaluacionExtension.fromCalificacion(promedioCalificaciones);
  }

  bool get tieneCalificaciones => calificaciones.isNotEmpty;

  Map<CriterioEvaluacion, double> get calificacionesPorCriterio {
    Map<CriterioEvaluacion, double> resultado = {};
    for (var criterio in CriterioEvaluacion.values) {
      if (calificaciones.containsKey(criterio.key)) {
        resultado[criterio] = calificaciones[criterio.key]!;
      }
    }
    return resultado;
  }

  void actualizarCalificacion(
    CriterioEvaluacion criterio,
    double calificacion,
  ) {
    calificaciones[criterio.key] = calificacion;
  }

  bool puedeSerEditada() {
    // Una evaluación puede ser editada si no está completada
    // o si fue completada hace menos de 24 horas
    if (!completada) return true;

    if (fechaActualizacion != null) {
      final diferencia = DateTime.now().difference(fechaActualizacion!);
      return diferencia.inHours < 24;
    }

    final diferencia = DateTime.now().difference(fechaCreacion);
    return diferencia.inHours < 24;
  }

  @override
  String toString() {
    return 'EvaluacionIndividual(id: $id, evaluador: $evaluadorId, evaluado: $evaluadoId, equipo: $equipoId, completada: $completada)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is EvaluacionIndividual &&
        other.id == id &&
        other.evaluacionPeriodoId == evaluacionPeriodoId &&
        other.evaluadorId == evaluadorId &&
        other.evaluadoId == evaluadoId &&
        other.equipoId == equipoId;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        evaluacionPeriodoId.hashCode ^
        evaluadorId.hashCode ^
        evaluadoId.hashCode ^
        equipoId.hashCode;
  }
}
