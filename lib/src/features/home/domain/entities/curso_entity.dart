import 'package:hive/hive.dart';

part 'curso_entity.g.dart'; // Para generar el adaptador de Hive

@HiveType(typeId: 1)
class CursoDomain extends HiveObject {
  @HiveField(0)
  int id;

  @HiveField(1)
  String nombre;

  @HiveField(2)
  String descripcion;

  @HiveField(3)
  String codigoRegistro;

  @HiveField(4)
  int? profesorId;

  @HiveField(5)
  DateTime? creadoEn; // ✅ Campo que faltaba

  @HiveField(6)
  List<String> categorias; // ✅ Campo que faltaba

  @HiveField(7)
  String? imagen; // ✅ Campo que faltaba

  @HiveField(8)
  List<String> estudiantesNombres; // ✅ Campo que faltaba

  @HiveField(9)
  DateTime fechaCreacion;

  @HiveField(10, defaultValue: false)
  bool isOfflineOnly; // Flag para identificar cursos no sincronizados

  @HiveField(11)
  DateTime? lastSyncAttempt; // Para retry logic

  CursoDomain({
    this.id = 0,
    required this.nombre,
    this.descripcion = '',
    required this.codigoRegistro,
    this.profesorId,
    this.creadoEn, // ✅ Agregado
    this.categorias = const [], // ✅ Agregado con valor por defecto
    this.imagen, // ✅ Agregado
    this.estudiantesNombres = const [], // ✅ Agregado con valor por defecto
    DateTime? fechaCreacion,
    this.isOfflineOnly = false,
    this.lastSyncAttempt,
  }) : fechaCreacion = fechaCreacion ?? DateTime.now();

  // Método para crear copia con cambios
  CursoDomain copyWith({
    int? id,
    String? nombre,
    String? descripcion,
    String? codigoRegistro,
    int? profesorId,
    DateTime? creadoEn,
    List<String>? categorias,
    String? imagen,
    List<String>? estudiantesNombres,
    DateTime? fechaCreacion,
    bool? isOfflineOnly,
    DateTime? lastSyncAttempt,
  }) {
    return CursoDomain(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      codigoRegistro: codigoRegistro ?? this.codigoRegistro,
      profesorId: profesorId ?? this.profesorId,
      creadoEn: creadoEn ?? this.creadoEn,
      categorias: categorias ?? this.categorias,
      imagen: imagen ?? this.imagen,
      estudiantesNombres: estudiantesNombres ?? this.estudiantesNombres,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      isOfflineOnly: isOfflineOnly ?? this.isOfflineOnly,
      lastSyncAttempt: lastSyncAttempt ?? this.lastSyncAttempt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'codigo_registro': codigoRegistro,
      'profesor_id': profesorId,
      'creado_en': creadoEn?.toIso8601String(),
      'categorias': categorias,
      'imagen': imagen,
      'estudiantes_nombres': estudiantesNombres,
      'fecha_creacion': fechaCreacion.toIso8601String(),
      'is_offline_only': isOfflineOnly,
      'last_sync_attempt': lastSyncAttempt?.toIso8601String(),
    };
  }

  factory CursoDomain.fromJson(Map<String, dynamic> json) {
    return CursoDomain(
      id: json['id'] ?? 0,
      nombre: json['nombre'] ?? '',
      descripcion: json['descripcion'] ?? '',
      codigoRegistro: json['codigo_registro'] ?? '',
      profesorId: json['profesor_id'],
      creadoEn: json['creado_en'] != null 
          ? DateTime.parse(json['creado_en'])
          : null,
      categorias: json['categorias'] != null 
          ? List<String>.from(json['categorias'])
          : [],
      imagen: json['imagen'],
      estudiantesNombres: json['estudiantes_nombres'] != null 
          ? List<String>.from(json['estudiantes_nombres'])
          : [],
      fechaCreacion: json['fecha_creacion'] != null 
          ? DateTime.parse(json['fecha_creacion'])
          : DateTime.now(),
      isOfflineOnly: json['is_offline_only'] ?? false,
      lastSyncAttempt: json['last_sync_attempt'] != null
          ? DateTime.parse(json['last_sync_attempt'])
          : null,
    );
  }

  @override
  String toString() {
    return 'CursoDomain(id: $id, nombre: $nombre, codigo: $codigoRegistro, offline: $isOfflineOnly)';
  }
}