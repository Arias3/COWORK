import 'package:hive/hive.dart';
import 'criterios_evaluacion.dart';

part 'evaluacion_individual.g.dart';

@HiveType(typeId: 9)
class EvaluacionIndividual extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String evaluacionPeriodoId; // ID del período de evaluación

  @HiveField(2)
  String evaluadorId; // Usuario que evalúa

  @HiveField(3)
  String evaluadoId; // Usuario evaluado

  @HiveField(4)
  String equipoId; // Equipo al que pertenecen

  @HiveField(5)
  Map<String, double> calificaciones; // criterio -> calificación

  @HiveField(6)
  String? comentarios;

  @HiveField(7)
  DateTime fechaCreacion;

  @HiveField(8)
  DateTime? fechaActualizacion;

  @HiveField(9)
  bool completada;

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

  // Calcular promedio de todas las calificaciones
  double get promedioGeneral {
    if (calificaciones.isEmpty) return 0.0;
    final suma = calificaciones.values.reduce((a, b) => a + b);
    return suma / calificaciones.length;
  }

  // Obtener calificación por criterio
  double getCalificacionPorCriterio(CriterioEvaluacion criterio) {
    return calificaciones[criterio.toString()] ?? 0.0;
  }

  // Establecer calificación por criterio
  void setCalificacionPorCriterio(
    CriterioEvaluacion criterio,
    NivelEvaluacion nivel,
  ) {
    calificaciones[criterio.toString()] = nivel.calificacion;
    fechaActualizacion = DateTime.now();
  }

  // Verificar si la evaluación está completa (todos los criterios evaluados)
  bool get esCompleta {
    return calificaciones.length == CriterioEvaluacion.values.length &&
        calificaciones.values.every((calificacion) => calificacion > 0);
  }

  // Marcar como completada
  void completarEvaluacion() {
    if (esCompleta) {
      completada = true;
      fechaActualizacion = DateTime.now();
    }
  }

  // Factory para crear evaluación vacía
  factory EvaluacionIndividual.nueva({
    required String evaluacionPeriodoId,
    required String evaluadorId,
    required String evaluadoId,
    required String equipoId,
  }) {
    return EvaluacionIndividual(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      evaluacionPeriodoId: evaluacionPeriodoId,
      evaluadorId: evaluadorId,
      evaluadoId: evaluadoId,
      equipoId: equipoId,
      calificaciones: {},
      fechaCreacion: DateTime.now(),
    );
  }

  // Convertir a JSON
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

  // Factory desde JSON
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
}
