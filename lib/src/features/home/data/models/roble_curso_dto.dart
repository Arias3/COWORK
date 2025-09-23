import '../../domain/entities/curso_entity.dart';

class RobleCursoDto {
  final int? id;
  final String nombre;
  final String descripcion;
  final String codigoRegistro;
  final int profesorId; // ✅ Cambiado a required int
  final String creadoEn;
  final List<String> categorias;
  final String? imagen;
  final List<String> estudiantesNombres;

  RobleCursoDto({
    this.id,
    required this.nombre,
    required this.descripcion,
    required this.codigoRegistro,
    required this.profesorId, // ✅ Sin nullable
    required this.creadoEn,
    required this.categorias,
    this.imagen,
    required this.estudiantesNombres,
  });

  factory RobleCursoDto.fromJson(Map<String, dynamic> json) {
    return RobleCursoDto(
      id: json['id'],
      nombre: json['nombre'] ?? '',
      descripcion: json['descripcion'] ?? '',
      codigoRegistro: json['codigo_registro'] ?? '',
      profesorId: json['profesor_id'] ?? 0,
      creadoEn: json['creado_en'] ?? DateTime.now().toIso8601String(),
      categorias: json['categorias'] != null 
          ? (json['categorias'] is String 
              ? (json['categorias'] as String).split(',').where((s) => s.isNotEmpty).toList()
              : List<String>.from(json['categorias']))
          : [],
      imagen: json['imagen'],
      estudiantesNombres: json['estudiantes_nombres'] != null 
          ? (json['estudiantes_nombres'] is String 
              ? (json['estudiantes_nombres'] as String).split(',').where((s) => s.isNotEmpty).toList()
              : List<String>.from(json['estudiantes_nombres']))
          : [],
    );
  }

  factory RobleCursoDto.fromEntity(CursoDomain curso) {
    return RobleCursoDto(
      id: curso.id != 0 ? curso.id : null,
      nombre: curso.nombre,
      descripcion: curso.descripcion,
      codigoRegistro: curso.codigoRegistro,
      profesorId: curso.profesorId ?? 0, // ✅ Manejar null con valor por defecto
      creadoEn: (curso.creadoEn ?? curso.fechaCreacion).toIso8601String(), // ✅ Usar fechaCreacion como fallback
      categorias: curso.categorias,
      imagen: curso.imagen,
      estudiantesNombres: curso.estudiantesNombres,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'codigo_registro': codigoRegistro,
      'profesor_id': profesorId,
      'creado_en': creadoEn,
      'categorias': categorias.join(','), // ✅ Convertir array a string separado por comas
      'imagen': imagen,
      'estudiantes_nombres': estudiantesNombres.join(','), // ✅ Convertir array a string separado por comas
    };
  }

  CursoDomain toEntity() {
    return CursoDomain(
      id: id ?? 0,
      nombre: nombre,
      descripcion: descripcion,
      codigoRegistro: codigoRegistro,
      profesorId: profesorId,
      creadoEn: DateTime.parse(creadoEn), // ✅ Usar creadoEn aquí
      categorias: categorias,
      imagen: imagen,
      estudiantesNombres: estudiantesNombres,
      fechaCreacion: DateTime.parse(creadoEn), // ✅ Mismo valor para fechaCreacion
    );
  }
}