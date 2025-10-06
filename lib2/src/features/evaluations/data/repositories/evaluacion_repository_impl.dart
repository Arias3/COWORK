import 'package:hive/hive.dart';
import '../../domain/entities/evaluacion_periodo.dart';
import '../../domain/entities/evaluacion_individual.dart';
import '../../domain/repositories/i_evaluacion_repository.dart';

class EvaluacionRepositoryImpl implements IEvaluacionRepository {
  static const String _periodoBoxName = 'evaluacion_periodo';
  static const String _individualBoxName = 'evaluacion_individual';

  Box<EvaluacionPeriodo>? _periodoBox;
  Box<EvaluacionIndividual>? _individualBox;

  Future<Box<EvaluacionPeriodo>> get _getPeriodoBox async {
    return _periodoBox ??= await Hive.openBox<EvaluacionPeriodo>(
      _periodoBoxName,
    );
  }

  Future<Box<EvaluacionIndividual>> get _getIndividualBox async {
    return _individualBox ??= await Hive.openBox<EvaluacionIndividual>(
      _individualBoxName,
    );
  }

  // ========================== PERÍODOS DE EVALUACIÓN ==========================

  @override
  Future<void> guardarEvaluacionPeriodo(EvaluacionPeriodo periodo) async {
    final box = await _getPeriodoBox;
    await box.put(periodo.id, periodo);
  }

  @override
  Future<void> actualizarEvaluacionPeriodo(EvaluacionPeriodo periodo) async {
    final box = await _getPeriodoBox;
    await box.put(periodo.id, periodo);
  }

  @override
  Future<void> eliminarEvaluacionPeriodo(String id) async {
    final box = await _getPeriodoBox;
    await box.delete(id);

    // También eliminar todas las evaluaciones individuales asociadas
    final individualBox = await _getIndividualBox;
    final evaluacionesAEliminar = individualBox.values
        .where((eval) => eval.evaluacionPeriodoId == id)
        .toList();

    for (final evaluacion in evaluacionesAEliminar) {
      await individualBox.delete(evaluacion.id);
    }
  }

  @override
  Future<EvaluacionPeriodo?> obtenerEvaluacionPeriodo(String id) async {
    final box = await _getPeriodoBox;
    return box.get(id);
  }

  @override
  Future<List<EvaluacionPeriodo>> obtenerEvaluacionesPorActividad(
    String actividadId,
  ) async {
    final box = await _getPeriodoBox;
    return box.values
        .where((periodo) => periodo.actividadId == actividadId)
        .toList()
      ..sort((a, b) => b.fechaCreacion.compareTo(a.fechaCreacion));
  }

  @override
  Future<List<EvaluacionPeriodo>> obtenerEvaluacionesPorProfesor(
    String profesorId,
  ) async {
    final box = await _getPeriodoBox;
    return box.values
        .where((periodo) => periodo.profesorId == profesorId)
        .toList()
      ..sort((a, b) => b.fechaCreacion.compareTo(a.fechaCreacion));
  }

  @override
  Future<List<EvaluacionPeriodo>> obtenerEvaluacionesActivas() async {
    final box = await _getPeriodoBox;
    return box.values.where((periodo) => periodo.estaActiva).toList()
      ..sort((a, b) => a.fechaInicio.compareTo(b.fechaInicio));
  }

  // ========================== EVALUACIONES INDIVIDUALES ==========================

  @override
  Future<void> guardarEvaluacionIndividual(
    EvaluacionIndividual evaluacion,
  ) async {
    final box = await _getIndividualBox;
    await box.put(evaluacion.id, evaluacion);
  }

  @override
  Future<void> actualizarEvaluacionIndividual(
    EvaluacionIndividual evaluacion,
  ) async {
    final box = await _getIndividualBox;
    await box.put(evaluacion.id, evaluacion);
  }

  @override
  Future<void> eliminarEvaluacionIndividual(String id) async {
    final box = await _getIndividualBox;
    await box.delete(id);
  }

  @override
  Future<void> eliminarEvaluacionesIndividualesPorPeriodo(
    String periodoId,
  ) async {
    final box = await _getIndividualBox;
    final evaluacionesAEliminar = box.values
        .where((eval) => eval.evaluacionPeriodoId == periodoId)
        .toList();

    for (final evaluacion in evaluacionesAEliminar) {
      await box.delete(evaluacion.id);
    }
  }

  @override
  Future<EvaluacionIndividual?> obtenerEvaluacionIndividual(String id) async {
    final box = await _getIndividualBox;
    return box.get(id);
  }

  @override
  Future<List<EvaluacionIndividual>> obtenerEvaluacionesPorPeriodo(
    String periodoId,
  ) async {
    final box = await _getIndividualBox;
    return box.values
        .where((eval) => eval.evaluacionPeriodoId == periodoId)
        .toList()
      ..sort((a, b) => b.fechaCreacion.compareTo(a.fechaCreacion));
  }

  @override
  Future<List<EvaluacionIndividual>> obtenerEvaluacionesPorEvaluador(
    String evaluadorId,
    String periodoId,
  ) async {
    final box = await _getIndividualBox;
    return box.values
        .where(
          (eval) =>
              eval.evaluadorId == evaluadorId &&
              eval.evaluacionPeriodoId == periodoId,
        )
        .toList()
      ..sort((a, b) => b.fechaCreacion.compareTo(a.fechaCreacion));
  }

  @override
  Future<List<EvaluacionIndividual>> obtenerEvaluacionesPorEvaluado(
    String evaluadoId,
    String periodoId,
  ) async {
    final box = await _getIndividualBox;
    return box.values
        .where(
          (eval) =>
              eval.evaluadoId == evaluadoId &&
              eval.evaluacionPeriodoId == periodoId,
        )
        .toList()
      ..sort((a, b) => b.fechaCreacion.compareTo(a.fechaCreacion));
  }

  @override
  Future<EvaluacionIndividual?> obtenerEvaluacionEspecifica(
    String evaluadorId,
    String evaluadoId,
    String periodoId,
  ) async {
    final box = await _getIndividualBox;
    return box.values
        .where(
          (eval) =>
              eval.evaluadorId == evaluadorId &&
              eval.evaluadoId == evaluadoId &&
              eval.evaluacionPeriodoId == periodoId,
        )
        .firstOrNull;
  }

  @override
  Future<List<EvaluacionIndividual>> obtenerEvaluacionesPorEquipo(
    String equipoId,
    String periodoId,
  ) async {
    final box = await _getIndividualBox;
    return box.values
        .where(
          (eval) =>
              eval.equipoId == equipoId &&
              eval.evaluacionPeriodoId == periodoId,
        )
        .toList()
      ..sort((a, b) => b.fechaCreacion.compareTo(a.fechaCreacion));
  }

  // ========================== MÉTODOS DE ANÁLISIS ==========================

  @override
  Future<Map<String, double>> obtenerPromediosPorEstudiante(
    String periodoId,
  ) async {
    final evaluaciones = await obtenerEvaluacionesPorPeriodo(periodoId);
    final Map<String, List<double>> calificacionesPorEstudiante = {};

    // Agrupar calificaciones por estudiante evaluado
    for (final evaluacion in evaluaciones) {
      if (evaluacion.completada) {
        calificacionesPorEstudiante.putIfAbsent(
          evaluacion.evaluadoId,
          () => [],
        );
        calificacionesPorEstudiante[evaluacion.evaluadoId]!.add(
          evaluacion.promedioGeneral,
        );
      }
    }

    // Calcular promedio por estudiante
    final Map<String, double> promedios = {};
    calificacionesPorEstudiante.forEach((estudianteId, calificaciones) {
      if (calificaciones.isNotEmpty) {
        final promedio =
            calificaciones.reduce((a, b) => a + b) / calificaciones.length;
        promedios[estudianteId] = promedio;
      }
    });

    return promedios;
  }

  @override
  Future<Map<String, double>> obtenerPromediosPorEquipo(
    String periodoId,
  ) async {
    final evaluaciones = await obtenerEvaluacionesPorPeriodo(periodoId);
    final Map<String, List<double>> calificacionesPorEquipo = {};

    // Agrupar calificaciones por equipo
    for (final evaluacion in evaluaciones) {
      if (evaluacion.completada) {
        calificacionesPorEquipo.putIfAbsent(evaluacion.equipoId, () => []);
        calificacionesPorEquipo[evaluacion.equipoId]!.add(
          evaluacion.promedioGeneral,
        );
      }
    }

    // Calcular promedio por equipo
    final Map<String, double> promedios = {};
    calificacionesPorEquipo.forEach((equipoId, calificaciones) {
      if (calificaciones.isNotEmpty) {
        final promedio =
            calificaciones.reduce((a, b) => a + b) / calificaciones.length;
        promedios[equipoId] = promedio;
      }
    });

    return promedios;
  }

  @override
  Future<int> contarEvaluacionesCompletadas(String periodoId) async {
    final evaluaciones = await obtenerEvaluacionesPorPeriodo(periodoId);
    return evaluaciones.where((eval) => eval.completada).length;
  }

  @override
  Future<int> contarEvaluacionesPendientes(String periodoId) async {
    final evaluaciones = await obtenerEvaluacionesPorPeriodo(periodoId);
    return evaluaciones.where((eval) => !eval.completada).length;
  }
}
