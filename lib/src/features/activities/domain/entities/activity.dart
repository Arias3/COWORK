class Activity {
  int? id; // ID local convertido del String de Roble
  String? robleId; // ID original de Roble (String)
  int categoriaId; // Referencia a categoría
  String nombre;
  String descripcion;
  DateTime fechaEntrega;
  DateTime? creadoEn;
  String? archivoAdjunto; // Para archivos adjuntos
  bool activo; // Para soft delete

  Activity({
    this.id,
    this.robleId,
    required this.categoriaId,
    required this.nombre,
    required this.descripcion,
    required this.fechaEntrega,
    DateTime? creadoEn,
    this.archivoAdjunto,
    this.activo = true,
  }) : creadoEn = creadoEn ?? DateTime.now();

  Activity copyWith({
    int? id,
    String? robleId,
    int? categoriaId,
    String? nombre,
    String? descripcion,
    DateTime? fechaEntrega,
    DateTime? creadoEn,
    String? archivoAdjunto,
    bool? activo,
  }) {
    return Activity(
      id: id ?? this.id,
      robleId: robleId ?? this.robleId,
      categoriaId: categoriaId ?? this.categoriaId,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      fechaEntrega: fechaEntrega ?? this.fechaEntrega,
      creadoEn: creadoEn ?? this.creadoEn,
      archivoAdjunto: archivoAdjunto ?? this.archivoAdjunto,
      activo: activo ?? this.activo,
    );
  }

  // Método para convertir a JSON (para Roble)
  Map<String, dynamic> toJson() => {
    'id': robleId,
    'categoria_id': categoriaId,
    'nombre': nombre,
    'descripcion': descripcion,
    'fecha_entrega': fechaEntrega.toIso8601String(),
    'creado_en': creadoEn?.toIso8601String(),
    'archivo_adjunto': archivoAdjunto ?? '',
    'activo': activo,
  };

  // Método para crear desde JSON (desde Roble)
  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      robleId: json['_id']?.toString() ?? json['id']?.toString(),
      categoriaId: json['categoria_id'] is String
          ? int.tryParse(json['categoria_id']) ?? 0
          : json['categoria_id'] ?? 0,
      nombre: json['nombre']?.toString() ?? '',
      descripcion: json['descripcion']?.toString() ?? '',
      fechaEntrega:
          DateTime.tryParse(json['fecha_entrega']?.toString() ?? '') ??
          DateTime.now(),
      creadoEn: json['creado_en'] != null
          ? DateTime.tryParse(json['creado_en'].toString())
          : null,
      archivoAdjunto: json['archivo_adjunto']?.toString(),
      activo: json['activo'] == true || json['activo'] == 'true',
    );
  }

  @override
  String toString() {
    return 'Activity(id: $id, robleId: $robleId, nombre: $nombre, categoriaId: $categoriaId)';
  }
}
