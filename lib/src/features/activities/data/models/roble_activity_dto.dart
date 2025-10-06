import '../../domain/entities/activity.dart';

class RobleActivityDto {
  final String? id;
  final int categoriaId;
  final String nombre;
  final String descripcion;
  final String fechaEntrega;
  final String? creadoEn;
  final String archivoAdjunto;
  final bool activo;

  RobleActivityDto({
    this.id,
    required this.categoriaId,
    required this.nombre,
    required this.descripcion,
    required this.fechaEntrega,
    this.creadoEn,
    this.archivoAdjunto = '',
    this.activo = true,
  });

  // ✅ CREAR DTO DESDE JSON DE ROBLE
  factory RobleActivityDto.fromJson(Map<String, dynamic> json) {
    print('🔍 [DTO] Parseando actividad desde JSON: $json');

    try {
      final dto = RobleActivityDto(
        id: json['_id']?.toString() ?? json['id']?.toString(),
        categoriaId: json['categoria_id'] is String
            ? int.tryParse(json['categoria_id']) ?? 0
            : json['categoria_id'] ?? 0,
        nombre: json['nombre']?.toString() ?? '',
        descripcion: json['descripcion']?.toString() ?? '',
        fechaEntrega:
            json['fecha_entrega']?.toString() ??
            DateTime.now().toIso8601String(),
        creadoEn: json['creado_en']?.toString(),
        archivoAdjunto: json['archivo_adjunto']?.toString() ?? '',
        activo: json['activo'] == true || json['activo'] == 'true',
      );

      print(
        '✅ [DTO] Actividad parseada exitosamente: ${dto.nombre} (ID: ${dto.id})',
      );
      return dto;
    } catch (e) {
      print('❌ [DTO] Error parseando actividad: $e');
      print('❌ [DTO] JSON problemático: $json');
      rethrow;
    }
  }

  // ✅ CREAR DTO DESDE ENTIDAD
  factory RobleActivityDto.fromEntity(Activity activity) {
    return RobleActivityDto(
      id: activity.robleId,
      categoriaId: activity.categoriaId,
      nombre: activity.nombre,
      descripcion: activity.descripcion,
      fechaEntrega: activity.fechaEntrega.toIso8601String(),
      creadoEn: activity.creadoEn?.toIso8601String(),
      archivoAdjunto: activity.archivoAdjunto ?? '',
      activo: activity.activo,
    );
  }

  // ✅ CONVERTIR DTO A ENTIDAD
  Activity toEntity() {
    try {
      print('🔄 [DTO] Convirtiendo DTO a Actividad...');
      print('   - Roble ID: "$id"');
      print('   - Nombre: "$nombre"');
      print('   - Categoría ID: $categoriaId');

      // ✅ GENERAR ID LOCAL CONSISTENTE SI ES NECESARIO
      int? localId;
      if (id != null && id!.isNotEmpty) {
        localId = _generateConsistentId(id!);
      }

      final activity = Activity(
        id: localId,
        robleId: id,
        categoriaId: categoriaId,
        nombre: nombre,
        descripcion: descripcion,
        fechaEntrega: DateTime.tryParse(fechaEntrega) ?? DateTime.now(),
        creadoEn: creadoEn != null ? DateTime.tryParse(creadoEn!) : null,
        archivoAdjunto: archivoAdjunto.isEmpty ? null : archivoAdjunto,
        activo: activo,
      );

      print('✅ [DTO] Entidad creada: ${activity.nombre} (ID: ${activity.id})');
      return activity;
    } catch (e) {
      print('❌ [DTO] Error convirtiendo a entidad: $e');
      rethrow;
    }
  }

  // ✅ CONVERTIR DTO A JSON PARA ROBLE
  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'categoria_id': categoriaId,
      'nombre': nombre,
      'descripcion': descripcion,
      'fecha_entrega': fechaEntrega,
      'creado_en': creadoEn ?? DateTime.now().toIso8601String(),
      'archivo_adjunto': archivoAdjunto,
      'activo': activo,
    };
  }

  // ========================================================================
  // FUNCIÓN DETERMINÍSTICA PARA IDs CONSISTENTES
  // ========================================================================
  static int _generateConsistentId(String input) {
    int hash = 0;
    for (int i = 0; i < input.length; i++) {
      int char = input.codeUnitAt(i);
      hash = ((hash << 5) - hash + char) & 0x7FFFFFFF;
    }
    return hash == 0 ? 1 : hash; // Evitar 0
  }

  @override
  String toString() {
    return 'RobleActivityDto(id: $id, nombre: $nombre, categoriaId: $categoriaId)';
  }
}
