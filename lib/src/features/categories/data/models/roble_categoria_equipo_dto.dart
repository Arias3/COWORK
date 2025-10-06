import '../../domain/entities/categoria_equipo_entity.dart';
import '../../domain/entities/tipo_asignacion.dart';

class RobleCategoriaEquipoDto {
  final String? id; // ✅ CAMBIO: String en lugar de int (Roble usa strings)
  final String nombre;
  final int cursoId;
  final String tipoAsignacion;
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
    if (id != null) '_id': id, // ✅ CAMBIO: usar '_id' como en Roble
    'nombre': nombre,
    'curso_id': cursoId,
    'tipo_asignacion': tipoAsignacion,
    'max_estudiantes_por_equipo': maxEstudiantesPorEquipo,
    'equipos_ids': equiposIds.join(
      ',',
    ), // Mantener como string separado por comas
    'creado_en': creadoEn,
    'equipos_generados': equiposGenerados,
    'descripcion':
        descripcion ?? '', // ✅ CORRECIÓN: Enviar string vacío en lugar de null
  };

  factory RobleCategoriaEquipoDto.fromJson(Map<String, dynamic> json) {
    try {
      print('🔍 [DTO] Parseando categoría desde JSON: $json');

      // ✅ MANEJO SEGURO DEL ID
      final rawId = json['_id'] ?? json['id'];
      final idString = rawId?.toString();

      // ✅ MANEJO SEGURO DE CURSO_ID
      final rawCursoId = json['curso_id'];
      int cursoId;
      if (rawCursoId is int) {
        cursoId = rawCursoId;
      } else if (rawCursoId is String) {
        cursoId = int.tryParse(rawCursoId) ?? 0;
      } else {
        cursoId = 0;
        print('⚠️ [DTO] curso_id no válido: $rawCursoId');
      }

      // ✅ MANEJO SEGURO DE MAX_ESTUDIANTES_POR_EQUIPO
      final rawMaxEstudiantes = json['max_estudiantes_por_equipo'];
      int maxEstudiantes;
      if (rawMaxEstudiantes is int) {
        maxEstudiantes = rawMaxEstudiantes;
      } else if (rawMaxEstudiantes is String) {
        maxEstudiantes = int.tryParse(rawMaxEstudiantes) ?? 4;
      } else {
        maxEstudiantes = 4;
        print(
          '⚠️ [DTO] max_estudiantes_por_equipo no válido: $rawMaxEstudiantes, usando 4',
        );
      }

      // ✅ MANEJO SEGURO DE EQUIPOS_IDS
      List<int> equiposIds = [];
      final rawEquiposIds = json['equipos_ids'];
      if (rawEquiposIds is String && rawEquiposIds.isNotEmpty) {
        try {
          equiposIds = rawEquiposIds
              .split(',')
              .map((e) => int.tryParse(e.trim()) ?? 0)
              .where((id) => id > 0)
              .toList();
        } catch (e) {
          print('⚠️ [DTO] Error parseando equipos_ids: $e');
          equiposIds = [];
        }
      }

      // ✅ MANEJO SEGURO DE EQUIPOS_GENERADOS
      final rawEquiposGenerados = json['equipos_generados'];
      bool equiposGenerados;
      if (rawEquiposGenerados is bool) {
        equiposGenerados = rawEquiposGenerados;
      } else if (rawEquiposGenerados is String) {
        equiposGenerados = rawEquiposGenerados.toLowerCase() == 'true';
      } else if (rawEquiposGenerados is int) {
        equiposGenerados = rawEquiposGenerados == 1;
      } else {
        equiposGenerados = false;
      }

      // ✅ MANEJO SEGURO DE FECHA
      String creadoEn;
      final rawFecha = json['creado_en'];
      if (rawFecha is String && rawFecha.isNotEmpty) {
        creadoEn = rawFecha;
      } else {
        creadoEn = DateTime.now().toIso8601String();
        print('⚠️ [DTO] Fecha no válida, usando actual: $creadoEn');
      }

      final dto = RobleCategoriaEquipoDto(
        id: idString,
        nombre: json['nombre']?.toString() ?? '',
        cursoId: cursoId,
        tipoAsignacion: json['tipo_asignacion']?.toString() ?? 'manual',
        maxEstudiantesPorEquipo: maxEstudiantes,
        equiposIds: equiposIds,
        creadoEn: creadoEn,
        equiposGenerados: equiposGenerados,
        descripcion: json['descripcion']?.toString(),
      );

      print(
        '✅ [DTO] Categoría parseada exitosamente: ${dto.nombre} (ID: ${dto.id})',
      );
      return dto;
    } catch (e) {
      print('❌ [DTO] Error parseando categoría: $e');
      print('❌ [DTO] JSON problemático: $json');
      rethrow;
    }
  }

  factory RobleCategoriaEquipoDto.fromEntity(CategoriaEquipo categoria) {
    return RobleCategoriaEquipoDto(
      id: categoria.id?.toString(), // Convertir int a string si existe
      nombre: categoria.nombre,
      cursoId: categoria.cursoId,
      tipoAsignacion: categoria.tipoAsignacion.name,
      maxEstudiantesPorEquipo: categoria.maxEstudiantesPorEquipo,
      equiposIds: categoria.equiposIds,
      creadoEn: categoria.creadoEn.toIso8601String(),
      equiposGenerados: categoria.equiposGenerados,
      descripcion: categoria.descripcion,
    );
  }

  CategoriaEquipo toEntity() {
    try {
      // ✅ CONVERTIR STRING ID A INT (usando función determinística)
      int? entityId;
      if (id != null && id!.isNotEmpty) {
        // ✅ SOLUCIONADO: Usar función determinística en lugar de hashCode.abs()
        entityId = _generateConsistentId(id!);
        if (entityId == 0) entityId = 1;
      }

      final entity = CategoriaEquipo(
        id: entityId,
        nombre: nombre,
        cursoId: cursoId,
        tipoAsignacion: TipoAsignacion.values.firstWhere(
          (e) => e.name == tipoAsignacion,
          orElse: () => TipoAsignacion.manual,
        ),
        maxEstudiantesPorEquipo: maxEstudiantesPorEquipo,
        equiposIds: equiposIds,
        creadoEn: DateTime.tryParse(creadoEn) ?? DateTime.now(),
        equiposGenerados: equiposGenerados,
        descripcion: descripcion,
      );

      print('✅ [DTO] Entidad creada: ${entity.nombre} (ID: ${entity.id})');
      return entity;
    } catch (e) {
      print('❌ [DTO] Error creando entidad: $e');
      rethrow;
    }
  }

  // ========================================================================
  // FUNCIÓN DETERMINÍSTICA PARA IDs CONSISTENTES CROSS-PLATFORM
  // ========================================================================
  static int _generateConsistentId(String input) {
    int hash = 0;
    for (int i = 0; i < input.length; i++) {
      int char = input.codeUnitAt(i);
      hash = ((hash << 5) - hash + char) & 0x7FFFFFFF;
    }
    return hash == 0 ? 1 : hash; // Evitar 0
  }
}
