import 'package:hive/hive.dart';

part 'evaluacion_periodo.g.dart';

@HiveType(typeId: 11)
enum EstadoEvaluacionPeriodo {
  @HiveField(0)
  pendiente,
  @HiveField(1)
  activo,
  @HiveField(2)
  finalizado,
}

@HiveType(typeId: 10)
class EvaluacionPeriodo extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String actividadId; // Actividad asociada

  @HiveField(2)
  String titulo;

  @HiveField(3)
  String? descripcion;

  @HiveField(4)
  DateTime fechaInicio;

  @HiveField(5)
  DateTime? fechaFin;

  @HiveField(6)
  DateTime fechaCreacion;

  @HiveField(7)
  String profesorId; // Profesor que creó la evaluación

  @HiveField(8)
  EstadoEvaluacionPeriodo estado;

  @HiveField(9)
  bool permitirAutoEvaluacion;

  @HiveField(10)
  int? duracionMaximaHoras; // Tiempo límite para completar evaluaciones

  EvaluacionPeriodo({
    required this.id,
    required this.actividadId,
    required this.titulo,
    this.descripcion,
    required this.fechaInicio,
    this.fechaFin,
    required this.fechaCreacion,
    required this.profesorId,
    this.estado = EstadoEvaluacionPeriodo.pendiente,
    this.permitirAutoEvaluacion = false,
    this.duracionMaximaHoras,
  });

  // Verificar si la evaluación está activa
  bool get estaActiva {
    return estado == EstadoEvaluacionPeriodo.activo &&
        DateTime.now().isAfter(fechaInicio) &&
        (fechaFin == null || DateTime.now().isBefore(fechaFin!));
  }

  // Verificar si la evaluación ha expirado
  bool get haExpirado {
    return fechaFin != null && DateTime.now().isAfter(fechaFin!);
  }

  // Calcular tiempo restante en horas
  int? get horasRestantes {
    if (fechaFin == null) return null;
    final diferencia = fechaFin!.difference(DateTime.now());
    return diferencia.inHours > 0 ? diferencia.inHours : 0;
  }

  // Iniciar evaluación
  void iniciarEvaluacion() {
    estado = EstadoEvaluacionPeriodo.activo;
    if (duracionMaximaHoras != null && fechaFin == null) {
      fechaFin = DateTime.now().add(Duration(hours: duracionMaximaHoras!));
    }
  }

  // Finalizar evaluación
  void finalizarEvaluacion() {
    estado = EstadoEvaluacionPeriodo.finalizado;
    fechaFin = DateTime.now();
  }

  // Factory para crear nueva evaluación
  factory EvaluacionPeriodo.nueva({
    required String actividadId,
    required String titulo,
    String? descripcion,
    required String profesorId,
    DateTime? fechaInicio,
    int? duracionMaximaHoras,
    bool permitirAutoEvaluacion = false,
  }) {
    return EvaluacionPeriodo(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      actividadId: actividadId,
      titulo: titulo,
      descripcion: descripcion,
      fechaInicio: fechaInicio ?? DateTime.now(),
      fechaCreacion: DateTime.now(),
      profesorId: profesorId,
      duracionMaximaHoras: duracionMaximaHoras,
      permitirAutoEvaluacion: permitirAutoEvaluacion,
    );
  }

  // Convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'actividadId': actividadId,
      'titulo': titulo,
      'descripcion': descripcion,
      'fechaInicio': fechaInicio.toIso8601String(),
      'fechaFin': fechaFin?.toIso8601String(),
      'fechaCreacion': fechaCreacion.toIso8601String(),
      'profesorId': profesorId,
      'estado': estado.toString(),
      'permitirAutoEvaluacion': permitirAutoEvaluacion,
      'duracionMaximaHoras': duracionMaximaHoras,
    };
  }

  // Factory desde JSON
  factory EvaluacionPeriodo.fromJson(Map<String, dynamic> json) {
    return EvaluacionPeriodo(
      id: json['id'],
      actividadId: json['actividadId'],
      titulo: json['titulo'],
      descripcion: json['descripcion'],
      fechaInicio: DateTime.parse(json['fechaInicio']),
      fechaFin: json['fechaFin'] != null
          ? DateTime.parse(json['fechaFin'])
          : null,
      fechaCreacion: DateTime.parse(json['fechaCreacion']),
      profesorId: json['profesorId'],
      estado: EstadoEvaluacionPeriodo.values.firstWhere(
        (e) => e.toString() == json['estado'],
        orElse: () => EstadoEvaluacionPeriodo.pendiente,
      ),
      permitirAutoEvaluacion: json['permitirAutoEvaluacion'] ?? false,
      duracionMaximaHoras: json['duracionMaximaHoras'],
    );
  }
}
