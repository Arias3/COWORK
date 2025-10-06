import '../entities/evaluacion_individual.dart';

abstract class EvaluacionIndividualRepository {
  Future<List<EvaluacionIndividual>> getEvaluacionesPorPeriodo(
    String evaluacionPeriodoId,
  );
  Future<List<EvaluacionIndividual>> getEvaluacionesPorEvaluador(
    String evaluadorId,
  );
  Future<List<EvaluacionIndividual>> getEvaluacionesPorEvaluado(
    String evaluadoId,
  );
  Future<List<EvaluacionIndividual>> getEvaluacionesPorEquipo(String equipoId);
  Future<EvaluacionIndividual?> getEvaluacionById(String id);
  Future<EvaluacionIndividual?> getEvaluacionEspecifica(
    String evaluacionPeriodoId,
    String evaluadorId,
    String evaluadoId,
  );
  Future<EvaluacionIndividual> crearEvaluacion(EvaluacionIndividual evaluacion);
  Future<EvaluacionIndividual> actualizarEvaluacion(
    EvaluacionIndividual evaluacion,
  );
  Future<bool> eliminarEvaluacion(String id);
  Future<List<EvaluacionIndividual>> getEvaluacionesCompletadas(
    String evaluacionPeriodoId,
  );
  Future<List<EvaluacionIndividual>> getEvaluacionesPendientes(
    String evaluadorId,
    String evaluacionPeriodoId,
  );
  Future<Map<String, double>> getPromedioEvaluacionesPorUsuario(
    String evaluadoId,
    String evaluacionPeriodoId,
  );
}
