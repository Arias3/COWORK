// ============================================================================
// lib/domain/entities/inscripcion.dart
import 'package:hive/hive.dart';

part 'inscripcion_entity.g.dart';

@HiveType(typeId: 2)
class Inscripcion extends HiveObject {
  @HiveField(0)
  int? id;

  @HiveField(1)
  int usuarioId;

  @HiveField(2)
  int cursoId;

  @HiveField(3)
  DateTime fechaInscripcion;

  Inscripcion({
    this.id,
    required this.usuarioId,
    required this.cursoId,
    DateTime? fechaInscripcion,
  }) : fechaInscripcion = fechaInscripcion ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'id': id,
    'usuarioId': usuarioId,
    'cursoId': cursoId,
    'fechaInscripcion': fechaInscripcion.toIso8601String(),
  };

  factory Inscripcion.fromJson(Map<String, dynamic> json) => Inscripcion(
    id: json['id'],
    usuarioId: json['usuarioId'],
    cursoId: json['cursoId'],
    fechaInscripcion: DateTime.parse(json['fechaInscripcion']),
  );
}