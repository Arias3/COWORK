import '../../domain/entities/equipo_entity.dart';

class RobleEquipoDto {
  final int? id;
  final String nombre;
  final int categoriaId;
  final List<int> estudiantesIds;
  final String creadoEn;
  final String? descripcion;
  final String? color;

  RobleEquipoDto({
    this.id,
    required this.nombre,
    required this.categoriaId,
    required this.estudiantesIds,
    required this.creadoEn,
    this.descripcion,
    this.color,
  });

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'nombre': nombre,
    'categoria_id': categoriaId,
    'estudiantes_ids': estudiantesIds.join(','),
    'creado_en': creadoEn,
    'descripcion': descripcion,
    'color': color,
  };

  factory RobleEquipoDto.fromJson(Map<String, dynamic> json) => RobleEquipoDto(
    id: json['id'],
    nombre: json['nombre'],
    categoriaId: json['categoria_id'],
    estudiantesIds: (json['estudiantes_ids'] as String?)?.split(',').map<int>((e) => int.parse(e)).toList() ?? [],
    creadoEn: json['creado_en'],
    descripcion: json['descripcion'],
    color: json['color'],
  );

  factory RobleEquipoDto.fromEntity(Equipo equipo) => RobleEquipoDto(
    id: equipo.id,
    nombre: equipo.nombre,
    categoriaId: equipo.categoriaId,
    estudiantesIds: equipo.estudiantesIds,
    creadoEn: equipo.creadoEn.toIso8601String(),
    descripcion: equipo.descripcion,
    color: equipo.color,
  );

  Equipo toEntity() => Equipo(
    id: id,
    nombre: nombre,
    categoriaId: categoriaId,
    estudiantesIds: estudiantesIds,
    creadoEn: DateTime.parse(creadoEn),
    descripcion: descripcion,
    color: color,
  );
}