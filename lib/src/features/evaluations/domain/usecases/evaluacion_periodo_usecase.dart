import '../entities/evaluacion_periodo.dart';
import '../repositories/evaluacion_periodo_repository.dart';

class EvaluacionPeriodoUseCase {
  final EvaluacionPeriodoRepository _repository;

  EvaluacionPeriodoUseCase(this._repository);

  Future<List<EvaluacionPeriodo>> getEvaluacionesPorActividad(
    String actividadId,
  ) async {
    return await _repository.getEvaluacionesPorActividad(actividadId);
  }

  Future<List<EvaluacionPeriodo>> getEvaluacionesPorProfesor(
    String profesorId,
  ) async {
    return await _repository.getEvaluacionesPorProfesor(profesorId);
  }

  Future<EvaluacionPeriodo?> getEvaluacionPeriodoById(String id) async {
    return await _repository.getEvaluacionPeriodoById(id);
  }

  Future<EvaluacionPeriodo> crearEvaluacionPeriodo({
    required String actividadId,
    required String titulo,
    String? descripcion,
    required DateTime fechaInicio,
    DateTime? fechaFin,
    required String profesorId,
    bool evaluacionEntrePares = true,
    required List<String> criteriosEvaluacion,
    bool habilitarComentarios = true,
    double puntuacionMaxima = 5.0,
  }) async {
    final evaluacion = EvaluacionPeriodo(
      id: '', // Se generará automáticamente en el repositorio
      actividadId: actividadId,
      titulo: titulo,
      descripcion: descripcion,
      fechaInicio: fechaInicio,
      fechaFin: fechaFin,
      fechaCreacion: DateTime.now(),
      profesorId: profesorId,
      evaluacionEntrePares: evaluacionEntrePares,
      criteriosEvaluacion: criteriosEvaluacion,
      estado: EstadoEvaluacionPeriodo.pendiente,
      habilitarComentarios: habilitarComentarios,
      puntuacionMaxima: puntuacionMaxima,
    );

    return await _repository.crearEvaluacionPeriodo(evaluacion);
  }

  Future<EvaluacionPeriodo> actualizarEvaluacionPeriodo(
    EvaluacionPeriodo evaluacion,
  ) async {
    return await _repository.actualizarEvaluacionPeriodo(evaluacion);
  }

  Future<EvaluacionPeriodo> activarEvaluacionPeriodo(String id) async {
    final evaluacion = await _repository.getEvaluacionPeriodoById(id);
    if (evaluacion == null) {
      throw Exception('Evaluación no encontrada');
    }

    final evaluacionActualizada = evaluacion.copyWith(
      estado: EstadoEvaluacionPeriodo.activo,
      fechaActualizacion: DateTime.now(),
    );

    return await _repository.actualizarEvaluacionPeriodo(evaluacionActualizada);
  }

  Future<EvaluacionPeriodo> finalizarEvaluacionPeriodo(String id) async {
    final evaluacion = await _repository.getEvaluacionPeriodoById(id);
    if (evaluacion == null) {
      throw Exception('Evaluación no encontrada');
    }

    final evaluacionActualizada = evaluacion.copyWith(
      estado: EstadoEvaluacionPeriodo.finalizado,
      fechaFin: DateTime.now(),
      fechaActualizacion: DateTime.now(),
    );

    return await _repository.actualizarEvaluacionPeriodo(evaluacionActualizada);
  }

  Future<bool> eliminarEvaluacionPeriodo(String id) async {
    return await _repository.eliminarEvaluacionPeriodo(id);
  }

  Future<List<EvaluacionPeriodo>> getEvaluacionesActivas() async {
    return await _repository.getEvaluacionesActivas();
  }

  Future<List<EvaluacionPeriodo>> getEvaluacionesPorEstado(
    EstadoEvaluacionPeriodo estado,
  ) async {
    return await _repository.getEvaluacionesPorEstado(estado);
  }

  Future<bool> puedeCrearEvaluacion(
    String actividadId,
    String profesorId,
  ) async {
    // Verificar si ya existe una evaluación activa para esta actividad
    final evaluacionesActividad = await _repository.getEvaluacionesPorActividad(
      actividadId,
    );
    final evaluacionesActivas = evaluacionesActividad
        .where((eval) => eval.estaActivo || eval.estaPendiente)
        .toList();

    return evaluacionesActivas.isEmpty;
  }

  Future<Map<String, dynamic>> getEstadisticasEvaluacion(
    String evaluacionId,
  ) async {
    final evaluacion = await _repository.getEvaluacionPeriodoById(evaluacionId);
    if (evaluacion == null) {
      return {};
    }

    return {
      'titulo': evaluacion.titulo,
      'estado': evaluacion.estado.name,
      'fechaInicio': evaluacion.fechaInicio,
      'fechaFin': evaluacion.fechaFin,
      'puedeEvaluar': evaluacion.puedeEvaluar,
      'criterios': evaluacion.criteriosEvaluacion.length,
      'puntuacionMaxima': evaluacion.puntuacionMaxima,
    };
  }
}
