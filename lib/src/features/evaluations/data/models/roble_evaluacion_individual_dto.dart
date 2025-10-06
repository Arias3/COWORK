import 'dart:convert';

import '../../domain/entities/evaluacion_individual.dart';

class RobleEvaluacionIndividualDto {
  final String id;
  final String evaluacionPeriodoId;
  final String evaluadorId;
  final String evaluadoId;
  final String equipoId;
  final Map<String, double> calificaciones;
  final String? comentarios;
  final String fechaCreacion; // ISO String
  final String? fechaActualizacion; // ISO String
  final bool completada;

  RobleEvaluacionIndividualDto({
    required this.id,
    required this.evaluacionPeriodoId,
    required this.evaluadorId,
    required this.evaluadoId,
    required this.equipoId,
    required this.calificaciones,
    this.comentarios,
    required this.fechaCreacion,
    this.fechaActualizacion,
    required this.completada,
  });

  factory RobleEvaluacionIndividualDto.fromJson(Map<String, dynamic> json) {
    // Manejar las calificaciones que pueden venir como String o Map
    Map<String, double> calificacionesMap = {};
    final calificacionesRaw = json['calificaciones'];

    if (calificacionesRaw != null) {
      if (calificacionesRaw is Map) {
        // Si ya es un Map, convertir a Map<String, double> manejando int y double
        calificacionesMap = {};
        calificacionesRaw.forEach((key, value) {
          if (value is num) {
            calificacionesMap[key.toString()] = value.toDouble();
          }
        });
      } else if (calificacionesRaw is String && calificacionesRaw.isNotEmpty) {
        try {
          // Si es un String, parsearlo como JSON
          final decoded = jsonDecode(calificacionesRaw);
          if (decoded is Map) {
            calificacionesMap = {};
            decoded.forEach((key, value) {
              if (value is num) {
                calificacionesMap[key.toString()] = value.toDouble();
              }
            });
          }
        } catch (e) {
          print('Error parseando calificaciones: $e');
          calificacionesMap = {};
        }
      }
    }

    return RobleEvaluacionIndividualDto(
      id: json['_id'] ?? json['id'],
      evaluacionPeriodoId: json['evaluacionPeriodoId'],
      evaluadorId: json['evaluadorId'],
      evaluadoId: json['evaluadoId'],
      equipoId: json['equipoId'],
      calificaciones: calificacionesMap,
      comentarios: json['comentarios'],
      fechaCreacion: json['fechaCreacion'],
      fechaActualizacion: json['fechaActualizacion'],
      completada: json['completada'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'evaluacionPeriodoId': evaluacionPeriodoId,
      'evaluadorId': evaluadorId,
      'evaluadoId': evaluadoId,
      'equipoId': equipoId,
      'calificaciones': calificaciones,
      'comentarios': comentarios,
      'fechaCreacion': fechaCreacion,
      'fechaActualizacion': fechaActualizacion,
      'completada': completada,
    };
  }

  factory RobleEvaluacionIndividualDto.fromEntity(EvaluacionIndividual entity) {
    return RobleEvaluacionIndividualDto(
      id: entity.id,
      evaluacionPeriodoId: entity.evaluacionPeriodoId,
      evaluadorId: entity.evaluadorId,
      evaluadoId: entity.evaluadoId,
      equipoId: entity.equipoId,
      calificaciones: Map<String, double>.from(entity.calificaciones),
      comentarios: entity.comentarios,
      fechaCreacion: entity.fechaCreacion.toIso8601String(),
      fechaActualizacion: entity.fechaActualizacion?.toIso8601String(),
      completada: entity.completada,
    );
  }

  EvaluacionIndividual toEntity() {
    return EvaluacionIndividual(
      id: id,
      evaluacionPeriodoId: evaluacionPeriodoId,
      evaluadorId: evaluadorId,
      evaluadoId: evaluadoId,
      equipoId: equipoId,
      calificaciones: Map<String, double>.from(calificaciones),
      comentarios: comentarios,
      fechaCreacion: DateTime.parse(fechaCreacion),
      fechaActualizacion: fechaActualizacion != null
          ? DateTime.parse(fechaActualizacion!)
          : null,
      completada: completada,
    );
  }
}
