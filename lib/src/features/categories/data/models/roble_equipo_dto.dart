import '../../domain/entities/equipo_entity.dart';

class RobleEquipoDto {
  final String? id; // ✅ CAMBIO: String en lugar de int
  final String nombre;
  final int categoriaId;
  final List<int> estudiantesIds;
  final String creadoEn;
  final String? descripcion;
  final String color;

  RobleEquipoDto({
    this.id,
    required this.nombre,
    required this.categoriaId,
    required this.estudiantesIds,
    required this.creadoEn,
    this.descripcion,
    required this.color,
  });

  Map<String, dynamic> toJson() => {
    'nombre': nombre,
    'categoria_id': categoriaId,
    'estudiantes_ids': estudiantesIds.isEmpty
        ? ''
        : estudiantesIds.join(','), // String vacío si está vacío
    'creado_en': creadoEn,
    'descripcion':
        descripcion ?? '', // ✅ CORRECCIÓN: Enviar string vacío en lugar de null
    'color': color,
  };

  factory RobleEquipoDto.fromJson(Map<String, dynamic> json) {
    try {
      print('🔍 [EQUIPO DTO] Parseando equipo desde JSON: $json');

      // ✅ MANEJO SEGURO DEL ID
      final rawId = json['_id'] ?? json['id'];
      final idString = rawId?.toString();

      // ✅ MANEJO SEGURO DE CATEGORIA_ID
      final rawCategoriaId = json['categoria_id'];
      int categoriaId;
      if (rawCategoriaId is int) {
        categoriaId = rawCategoriaId;
      } else if (rawCategoriaId is String) {
        categoriaId = int.tryParse(rawCategoriaId) ?? 0;
      } else {
        categoriaId = 0;
        print('⚠️ [EQUIPO DTO] categoria_id no válido: $rawCategoriaId');
      }

      // ✅ MANEJO SEGURO DE ESTUDIANTES_IDS
      List<int> estudiantesIds = [];
      final rawEstudiantesIds = json['estudiantes_ids'];
      if (rawEstudiantesIds is String && rawEstudiantesIds.isNotEmpty) {
        try {
          estudiantesIds = rawEstudiantesIds
              .split(',')
              .map((e) => int.tryParse(e.trim()) ?? 0)
              .where((id) => id > 0)
              .toList();
        } catch (e) {
          print('⚠️ [EQUIPO DTO] Error parseando estudiantes_ids: $e');
          estudiantesIds = [];
        }
      }

      // ✅ MANEJO SEGURO DE FECHA
      String creadoEn;
      final rawFecha = json['creado_en'];
      if (rawFecha is String && rawFecha.isNotEmpty) {
        creadoEn = rawFecha;
      } else {
        creadoEn = DateTime.now().toIso8601String();
        print('⚠️ [EQUIPO DTO] Fecha no válida, usando actual: $creadoEn');
      }

      final dto = RobleEquipoDto(
        id: idString,
        nombre: json['nombre']?.toString() ?? '',
        categoriaId: categoriaId,
        estudiantesIds: estudiantesIds,
        creadoEn: creadoEn,
        descripcion: json['descripcion']?.toString(),
        color: json['color']?.toString() ?? '#DDA0DD',
      );

      print(
        '✅ [EQUIPO DTO] Equipo parseado exitosamente: ${dto.nombre} (ID: ${dto.id})',
      );
      return dto;
    } catch (e) {
      print('❌ [EQUIPO DTO] Error parseando equipo: $e');
      print('❌ [EQUIPO DTO] JSON problemático: $json');
      rethrow;
    }
  }

  factory RobleEquipoDto.fromEntity(Equipo equipo) {
    return RobleEquipoDto(
      id: equipo.id?.toString(), // Convertir int a string si existe
      nombre: equipo.nombre,
      categoriaId: equipo.categoriaId,
      estudiantesIds: equipo.estudiantesIds,
      creadoEn: equipo.creadoEn.toIso8601String(),
      descripcion: equipo.descripcion,
      color:
          equipo.color ??
          '#DDA0DD', // ✅ FIX: Provide default value for nullable color
    );
  }

  Equipo toEntity() {
    try {
      // ✅ CONVERTIR STRING ID A INT (usando función determinística)
      int? entityId;
      if (id != null && id!.isNotEmpty) {
        // ✅ SOLUCIONADO: Usar función determinística en lugar de hashCode.abs()
        entityId = _generateConsistentId(id!);
        if (entityId == 0) entityId = 1;
      }

      final entity = Equipo(
        id: entityId,
        nombre: nombre,
        categoriaId: categoriaId,
        estudiantesIds: estudiantesIds,
        creadoEn: DateTime.tryParse(creadoEn) ?? DateTime.now(),
        descripcion: descripcion,
        color: color,
      );

      print(
        '✅ [EQUIPO DTO] Entidad creada: ${entity.nombre} (ID: ${entity.id})',
      );
      return entity;
    } catch (e) {
      print('❌ [EQUIPO DTO] Error creando entidad: $e');
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
