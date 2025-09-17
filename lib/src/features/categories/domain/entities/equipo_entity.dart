import 'package:hive/hive.dart';
part 'equipo_entity.g.dart';

@HiveType(typeId: 4)
class Equipo extends HiveObject {
  @HiveField(0)
  int? id;

  @HiveField(1)
  String nombre;

  @HiveField(2)
  int categoriaId;

  @HiveField(3)
  List<int> estudiantesIds;

  @HiveField(4)
  DateTime creadoEn;

  @HiveField(5)
  String? descripcion;

  @HiveField(6)
  String? color; // Para UI

  Equipo({
    this.id,
    required this.nombre,
    required this.categoriaId,
    this.estudiantesIds = const [],
    DateTime? creadoEn,
    this.descripcion,
    this.color,
  }) : creadoEn = creadoEn ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'id': id,
    'nombre': nombre,
    'categoriaId': categoriaId,
    'estudiantesIds': estudiantesIds,
    'creadoEn': creadoEn.toIso8601String(),
    'descripcion': descripcion,
    'color': color,
  };

  factory Equipo.fromJson(Map<String, dynamic> json) => Equipo(
    id: json['id'],
    nombre: json['nombre'],
    categoriaId: json['categoriaId'],
    estudiantesIds: List<int>.from(json['estudiantesIds'] ?? []),
    creadoEn: DateTime.parse(json['creadoEn']),
    descripcion: json['descripcion'],
    color: json['color'],
  );
}