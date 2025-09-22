import '../../features/home/domain/entities/curso_entity.dart';

class RobleCursoDto {
  final int? id;
  final String nombre;
  final String descripcion;
  final int profesorId;
  final String codigoRegistro;
  final String creadoEn;
  final List<String> categorias;
  final String imagen;
  final List<String> estudiantesNombres;

  RobleCursoDto({
    this.id,
    required this.nombre,
    required this.descripcion,
    required this.profesorId,
    required this.codigoRegistro,
    required this.creadoEn,
    required this.categorias,
    required this.imagen,
    required this.estudiantesNombres,
  });

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'nombre': nombre,
    'descripcion': descripcion,
    'profesor_id': profesorId,
    'codigo_registro': codigoRegistro,
    'creado_en': creadoEn,
    'categorias': categorias.join(','),
    'imagen': imagen,
    'estudiantes_nombres': estudiantesNombres.join(','),
  };

  factory RobleCursoDto.fromJson(Map<String, dynamic> json) => RobleCursoDto(
    id: json['id'],
    nombre: json['nombre'],
    descripcion: json['descripcion'],
    profesorId: json['profesor_id'],
    codigoRegistro: json['codigo_registro'],
    creadoEn: json['creado_en'],
    categorias: (json['categorias'] as String?)?.split(',') ?? [],
    imagen: json['imagen'] ?? '',
    estudiantesNombres: (json['estudiantes_nombres'] as String?)?.split(',') ?? [],
  );

  factory RobleCursoDto.fromEntity(CursoDomain curso) => RobleCursoDto(
    id: curso.id,
    nombre: curso.nombre,
    descripcion: curso.descripcion,
    profesorId: curso.profesorId,
    codigoRegistro: curso.codigoRegistro,
    creadoEn: curso.creadoEn.toIso8601String(),
    categorias: curso.categorias,
    imagen: curso.imagen,
    estudiantesNombres: curso.estudiantesNombres,
  );

  CursoDomain toEntity() => CursoDomain(
    id: id,
    nombre: nombre,
    descripcion: descripcion,
    profesorId: profesorId,
    codigoRegistro: codigoRegistro,
    creadoEn: DateTime.parse(creadoEn),
    categorias: categorias,
    imagen: imagen,
    estudiantesNombres: estudiantesNombres,
  );
}