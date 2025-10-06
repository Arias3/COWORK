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
    print('🔄 [HYBRID] Mapeando JSON a curso...');
    print('   - JSON keys: ${json.keys.join(', ')}');

    // ✅ CORRECCIÓN CRÍTICA: Obtener ID de _id o id
    dynamic rawId = json['_id'] ?? json['id'];
    int? convertedId;

    if (rawId != null) {
      print('🔄 [HYBRID] Convirtiendo ID: $rawId (tipo: ${rawId.runtimeType})');

      if (rawId is String && rawId.isNotEmpty) {
        // ✅ SOLUCIONADO: Usar función determinística en lugar de hashCode
        convertedId = _generateConsistentId(rawId);
        print('✅ [HYBRID] String ID convertido: "$rawId" -> $convertedId');
      } else if (rawId is int && rawId > 0) {
        convertedId = rawId;
        print('✅ [HYBRID] Numeric ID usado: $convertedId');
      }
    }

    final curso = RobleCursoDto(
      id: convertedId,
      nombre: json['nombre'] ?? '',
      descripcion: json['descripcion'] ?? '',
      codigoRegistro: json['codigo_registro'] ?? '',
      profesorId: json['profesor_id'] ?? 0,
      creadoEn: json['creado_en'] ?? DateTime.now().toIso8601String(),
      categorias: json['categorias'] != null
          ? (json['categorias'] is String
                ? (json['categorias'] as String)
                      .split(',')
                      .where((s) => s.isNotEmpty)
                      .toList()
                : List<String>.from(json['categorias']))
          : [],
      imagen: json['imagen'],
      estudiantesNombres: json['estudiantes_nombres'] != null
          ? (json['estudiantes_nombres'] is String
                ? (json['estudiantes_nombres'] as String)
                      .split(',')
                      .where((s) => s.isNotEmpty)
                      .toList()
                : List<String>.from(json['estudiantes_nombres']))
          : [],
    );

    print('✅ [HYBRID] Curso mapeado correctamente:');
    print('   - Nombre: ${curso.nombre}');
    print('   - ID original: $rawId');
    print('   - ID convertido: ${curso.id}');

    return curso;
  }

  factory RobleCursoDto.fromEntity(CursoDomain curso) {
    return RobleCursoDto(
      id: curso.id != 0 ? curso.id : null,
      nombre: curso.nombre,
      descripcion: curso.descripcion,
      codigoRegistro: curso.codigoRegistro,
      profesorId: curso.profesorId ?? 0, // ✅ Manejar null con valor por defecto
      creadoEn: (curso.creadoEn ?? curso.fechaCreacion)
          .toIso8601String(), // ✅ Usar fechaCreacion como fallback
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
      'categorias': categorias.join(
        ',',
      ), // ✅ Convertir array a string separado por comas
      'imagen': imagen,
      'estudiantes_nombres': estudiantesNombres.join(
        ',',
      ), // ✅ Convertir array a string separado por comas
    };
  }

  CursoDomain toEntity() {
    // ✅ CORRECCIÓN: Asegurar que nunca se retorne ID 0
    final finalId = id ?? 1; // Si es null, usar 1 en lugar de 0

    print('🔄 [HYBRID] Convirtiendo DTO a entidad:');
    print('   - ID: $finalId');
    print('   - Nombre: $nombre');

    return CursoDomain(
      id: finalId,
      nombre: nombre,
      descripcion: descripcion,
      codigoRegistro: codigoRegistro,
      profesorId: profesorId,
      creadoEn: DateTime.parse(creadoEn), // ✅ Usar creadoEn aquí
      categorias: categorias,
      imagen: imagen,
      estudiantesNombres: estudiantesNombres,
      fechaCreacion: DateTime.parse(
        creadoEn,
      ), // ✅ Mismo valor para fechaCreacion
    );
  }

  /// ✅ MÉTODO AGREGADO: Genera un ID consistente entre plataformas
  /// En lugar de usar hashCode (que varía entre web/mobile),
  /// usamos una función determinística basada en los códigos de caracteres
  static int _generateConsistentId(String input) {
    if (input.isEmpty) return 1;

    int hash = 0;
    for (int i = 0; i < input.length; i++) {
      hash = (hash * 31 + input.codeUnitAt(i)) & 0x7FFFFFFF;
    }

    // Asegurar que nunca sea 0
    return hash == 0 ? 1 : hash;
  }
}
