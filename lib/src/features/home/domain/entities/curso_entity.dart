import 'package:hive/hive.dart';

part 'curso_entity.g.dart';

@HiveType(typeId: 1)
class CursoDomain extends HiveObject {
  @HiveField(0)
  int? id;

  @HiveField(1)
  String nombre;

  @HiveField(2)
  String descripcion;

  @HiveField(3)
  int profesorId;

  @HiveField(4)
  String codigoRegistro;

  @HiveField(5)
  DateTime creadoEn;

  @HiveField(6)
  List<String> categorias;

  @HiveField(7)
  String imagen;

  @HiveField(8)
  List<String> estudiantesNombres;

  CursoDomain({
    this.id,
    required this.nombre,
    required this.descripcion,
    required this.profesorId,
    required this.codigoRegistro,
    DateTime? creadoEn,
    this.categorias = const [],
    this.imagen = '',
    this.estudiantesNombres = const [],
  }) : creadoEn = creadoEn ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'id': id,
    'nombre': nombre,
    'descripcion': descripcion,
    'profesorId': profesorId,
    'codigoRegistro': codigoRegistro,
    'creadoEn': creadoEn.toIso8601String(),
    'categorias': categorias,
    'imagen': imagen,
    'estudiantesNombres': estudiantesNombres,
  };

  factory CursoDomain.fromJson(Map<String, dynamic> json) => CursoDomain(
    id: json['id'],
    nombre: json['nombre'],
    descripcion: json['descripcion'],
    profesorId: json['profesorId'],
    codigoRegistro: json['codigoRegistro'],
    creadoEn: DateTime.parse(json['creadoEn']),
    categorias: List<String>.from(json['categorias'] ?? []),
    imagen: json['imagen'] ?? '',
    estudiantesNombres: List<String>.from(json['estudiantesNombres'] ?? []),
  );
}
