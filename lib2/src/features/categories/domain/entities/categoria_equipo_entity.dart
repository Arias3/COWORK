import 'package:hive/hive.dart';
import 'tipo_asignacion.dart';
part 'categoria_equipo_entity.g.dart';

@HiveType(typeId: 3)
class CategoriaEquipo extends HiveObject {
  @HiveField(0)
  int? id;

  @HiveField(1)
  String nombre;

  @HiveField(2)
  int cursoId;

  @HiveField(3)
  TipoAsignacion tipoAsignacion;

  @HiveField(4)
  int maxEstudiantesPorEquipo;

  @HiveField(5)
  List<int> equiposIds;

  @HiveField(6)
  DateTime creadoEn;

  @HiveField(7)
  bool equiposGenerados;

  @HiveField(8) // 👈 nuevo campo
  String? descripcion;

  CategoriaEquipo({
    this.id,
    required this.nombre,
    required this.cursoId,
    required this.tipoAsignacion,
    this.maxEstudiantesPorEquipo = 4,
    this.equiposIds = const [],
    DateTime? creadoEn,
    this.equiposGenerados = false,
    this.descripcion, // 👈 lo añadimos
  }) : creadoEn = creadoEn ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'nombre': nombre,
        'cursoId': cursoId,
        'tipoAsignacion': tipoAsignacion.name,
        'maxEstudiantesPorEquipo': maxEstudiantesPorEquipo,
        'equiposIds': equiposIds,
        'creadoEn': creadoEn.toIso8601String(),
        'equiposGenerados': equiposGenerados,
        'descripcion': descripcion, // 👈 lo añadimos
      };

  factory CategoriaEquipo.fromJson(Map<String, dynamic> json) => CategoriaEquipo(
        id: json['id'],
        nombre: json['nombre'],
        cursoId: json['cursoId'],
        tipoAsignacion: TipoAsignacion.values
            .firstWhere((e) => e.name == json['tipoAsignacion']),
        maxEstudiantesPorEquipo: json['maxEstudiantesPorEquipo'] ?? 4,
        equiposIds: List<int>.from(json['equiposIds'] ?? []),
        creadoEn: DateTime.parse(json['creadoEn']),
        equiposGenerados: json['equiposGenerados'] ?? false,
        descripcion: json['descripcion'], // 👈 lo añadimos
      );
}
