import '../../domain/entities/inscripcion_entity.dart';

class RobleInscripcionDto {
  final int? id;
  final int usuarioId;
  final int cursoId;
  final String fechaInscripcion;

  RobleInscripcionDto({
    this.id,
    required this.usuarioId,
    required this.cursoId,
    required this.fechaInscripcion,
  });

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'usuario_id': usuarioId,
    'curso_id': cursoId,
    'fecha_inscripcion': fechaInscripcion,
  };

  factory RobleInscripcionDto.fromJson(Map<String, dynamic> json) => RobleInscripcionDto(
    id: json['id'],
    usuarioId: json['usuario_id'],
    cursoId: json['curso_id'],
    fechaInscripcion: json['fecha_inscripcion'],
  );

  factory RobleInscripcionDto.fromEntity(Inscripcion inscripcion) => RobleInscripcionDto(
    id: inscripcion.id,
    usuarioId: inscripcion.usuarioId,
    cursoId: inscripcion.cursoId,
    fechaInscripcion: inscripcion.fechaInscripcion.toIso8601String(),
  );

  Inscripcion toEntity() => Inscripcion(
    id: id,
    usuarioId: usuarioId,
    cursoId: cursoId,
    fechaInscripcion: DateTime.parse(fechaInscripcion),
  );
}