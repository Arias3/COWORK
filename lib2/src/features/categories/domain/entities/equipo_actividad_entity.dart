import 'package:hive/hive.dart';
part 'equipo_actividad_entity.g.dart';

@HiveType(typeId: 8)
class EquipoActividad extends HiveObject {
  @HiveField(0)
  int? id;

  @HiveField(1)
  int equipoId;

  @HiveField(2)
  String actividadId;

  @HiveField(3)
  DateTime asignadoEn;

  @HiveField(4)
  DateTime? fechaEntrega;

  @HiveField(5)
  String? estado; // 'pendiente', 'en_progreso', 'completada', 'vencida'

  @HiveField(6)
  String? comentarioProfesor;

  @HiveField(7)
  double? calificacion;

  @HiveField(8)
  DateTime? fechaCompletada;

  EquipoActividad({
    this.id,
    required this.equipoId,
    required this.actividadId,
    DateTime? asignadoEn,
    this.fechaEntrega,
    this.estado = 'pendiente',
    this.comentarioProfesor,
    this.calificacion,
    this.fechaCompletada,
  }) : asignadoEn = asignadoEn ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'id': id,
    'equipoId': equipoId,
    'actividadId': actividadId,
    'asignadoEn': asignadoEn.toIso8601String(),
    'fechaEntrega': fechaEntrega?.toIso8601String(),
    'estado': estado,
    'comentarioProfesor': comentarioProfesor,
    'calificacion': calificacion,
    'fechaCompletada': fechaCompletada?.toIso8601String(),
  };

  factory EquipoActividad.fromJson(Map<String, dynamic> json) =>
      EquipoActividad(
        id: json['id'],
        equipoId: json['equipoId'],
        actividadId: json['actividadId'],
        asignadoEn: DateTime.parse(json['asignadoEn']),
        fechaEntrega: json['fechaEntrega'] != null
            ? DateTime.parse(json['fechaEntrega'])
            : null,
        estado: json['estado'] ?? 'pendiente',
        comentarioProfesor: json['comentarioProfesor'],
        calificacion: json['calificacion']?.toDouble(),
        fechaCompletada: json['fechaCompletada'] != null
            ? DateTime.parse(json['fechaCompletada'])
            : null,
      );

  // Método para verificar si la actividad está vencida
  bool get isVencida {
    if (fechaEntrega == null) return false;
    return DateTime.now().isAfter(fechaEntrega!) && estado != 'completada';
  }

  // Método para obtener días restantes
  int get diasRestantes {
    if (fechaEntrega == null) return 0;
    return fechaEntrega!.difference(DateTime.now()).inDays;
  }
}
