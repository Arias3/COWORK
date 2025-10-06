import '../entities/evaluacion_periodo.dart';

abstract class EvaluacionPeriodoRepository {
  Future<List<EvaluacionPeriodo>> getEvaluacionesPorActividad(
    String actividadId,
  );
  Future<List<EvaluacionPeriodo>> getEvaluacionesPorProfesor(String profesorId);
  Future<EvaluacionPeriodo?> getEvaluacionPeriodoById(String id);
  Future<EvaluacionPeriodo> crearEvaluacionPeriodo(
    EvaluacionPeriodo evaluacion,
  );
  Future<EvaluacionPeriodo> actualizarEvaluacionPeriodo(
    EvaluacionPeriodo evaluacion,
  );
  Future<bool> eliminarEvaluacionPeriodo(String id);
  Future<List<EvaluacionPeriodo>> getEvaluacionesActivas();
  Future<List<EvaluacionPeriodo>> getEvaluacionesPorEstado(
    EstadoEvaluacionPeriodo estado,
  );
}
