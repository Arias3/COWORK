import '../../domain/entities/categoria_equipo_entity.dart';
import '../../domain/entities/tipo_asignacion.dart';

class RobleCategoriaEquipoDto {
  final int? id;
  final String nombre;
  final int cursoId;
  final String tipoAsignacion; // 'manual' o 'aleatoria'
  final int maxEstudiantesPorEquipo;
  final List<int> equiposIds;
  final String creadoEn;
  final bool equiposGenerados;
  final String? descripcion;

  RobleCategoriaEquipoDto({
    this.id,
    required this.nombre,
    required this.cursoId,
    required this.tipoAsignacion,
    required this.maxEstudiantesPorEquipo,
    required this.equiposIds,
    required this.creadoEn,
    required this.equiposGenerados,
    this.descripcion,
  });

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'nombre': nombre,
    'curso_id': cursoId,
    'tipo_asignacion': tipoAsignacion,
    'max_estudiantes_por_equipo': maxEstudiantesPorEquipo,
    'equipos_ids': equiposIds.join(','),
    'creado_en': creadoEn,
    'equipos_generados': equiposGenerados,
    'descripcion': descripcion,
  };

  factory RobleCategoriaEquipoDto.fromJson(Map<String, dynamic> json) => RobleCategoriaEquipoDto(
    id: json['id'],
    nombre: json['nombre'],
    cursoId: json['curso_id'],
    tipoAsignacion: json['tipo_asignacion'],
    maxEstudiantesPorEquipo: json['max_estudiantes_por_equipo'],
    equiposIds: (json['equipos_ids'] as String?)?.split(',').map<int>((e) => int.parse(e)).toList() ?? [],
    creadoEn: json['creado_en'],
    equiposGenerados: json['equipos_generados'],
    descripcion: json['descripcion'],
  );

  factory RobleCategoriaEquipoDto.fromEntity(CategoriaEquipo categoria) => RobleCategoriaEquipoDto(
    id: categoria.id,
    nombre: categoria.nombre,
    cursoId: categoria.cursoId,
    tipoAsignacion: categoria.tipoAsignacion.name,
    maxEstudiantesPorEquipo: categoria.maxEstudiantesPorEquipo,
    equiposIds: categoria.equiposIds,
    creadoEn: categoria.creadoEn.toIso8601String(),
    equiposGenerados: categoria.equiposGenerados,
    descripcion: categoria.descripcion,
  );

  CategoriaEquipo toEntity() => CategoriaEquipo(
    id: id,
    nombre: nombre,
    cursoId: cursoId,
    tipoAsignacion: TipoAsignacion.values.firstWhere((e) => e.name == tipoAsignacion),
    maxEstudiantesPorEquipo: maxEstudiantesPorEquipo,
    equiposIds: equiposIds,
    creadoEn: DateTime.parse(creadoEn),
    equiposGenerados: equiposGenerados,
    descripcion: descripcion,
  );
}