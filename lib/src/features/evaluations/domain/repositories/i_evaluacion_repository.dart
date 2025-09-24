import '../entities/evaluacion_periodo.dart';
import '../entities/evaluacion_individual.dart';

abstract class IEvaluacionRepository {
  // Períodos de evaluación
  Future<void> guardarEvaluacionPeriodo(EvaluacionPeriodo periodo);
  Future<void> actualizarEvaluacionPeriodo(EvaluacionPeriodo periodo);
  Future<void> eliminarEvaluacionPeriodo(String id);
  Future<EvaluacionPeriodo?> obtenerEvaluacionPeriodo(String id);
  Future<List<EvaluacionPeriodo>> obtenerEvaluacionesPorActividad(
    String actividadId,
  );
  Future<List<EvaluacionPeriodo>> obtenerEvaluacionesPorProfesor(
    String profesorId,
  );
  Future<List<EvaluacionPeriodo>> obtenerEvaluacionesActivas();

  // Evaluaciones individuales
  Future<void> guardarEvaluacionIndividual(EvaluacionIndividual evaluacion);
  Future<void> actualizarEvaluacionIndividual(EvaluacionIndividual evaluacion);
  Future<void> eliminarEvaluacionIndividual(String id);
  Future<void> eliminarEvaluacionesIndividualesPorPeriodo(String periodoId);
  Future<EvaluacionIndividual?> obtenerEvaluacionIndividual(String id);
  Future<List<EvaluacionIndividual>> obtenerEvaluacionesPorPeriodo(
    String periodoId,
  );
  Future<List<EvaluacionIndividual>> obtenerEvaluacionesPorEvaluador(
    String evaluadorId,
    String periodoId,
  );
  Future<List<EvaluacionIndividual>> obtenerEvaluacionesPorEvaluado(
    String evaluadoId,
    String periodoId,
  );
  Future<EvaluacionIndividual?> obtenerEvaluacionEspecifica(
    String evaluadorId,
    String evaluadoId,
    String periodoId,
  );
  Future<List<EvaluacionIndividual>> obtenerEvaluacionesPorEquipo(
    String equipoId,
    String periodoId,
  );

  // Métodos de análisis
  Future<Map<String, double>> obtenerPromediosPorEstudiante(String periodoId);
  Future<Map<String, double>> obtenerPromediosPorEquipo(String periodoId);
  Future<int> contarEvaluacionesCompletadas(String periodoId);
  Future<int> contarEvaluacionesPendientes(String periodoId);
}
