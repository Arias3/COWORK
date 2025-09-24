import 'package:get/get.dart';
import '../../domain/entities/evaluacion_periodo.dart';
import '../../domain/entities/evaluacion_individual.dart';
import '../../domain/entities/criterios_evaluacion.dart';
import '../../domain/usecases/evaluacion_usecase.dart';

class EvaluacionController extends GetxController {
  final EvaluacionUseCase _evaluacionUseCase;

  EvaluacionController(this._evaluacionUseCase);

  // Observables
  final _isLoading = false.obs;
  final _evaluacionesPorActividad = <EvaluacionPeriodo>[].obs;
  final _evaluacionActual = Rx<EvaluacionPeriodo?>(null);
  final _misEvaluacionesPendientes = <EvaluacionIndividual>[].obs;
  final _misEvaluaciones =
      <EvaluacionIndividual>[].obs; // Para todas las evaluaciones
  final _estadisticas = <String, dynamic>{}.obs;
  final _promediosEstudiantes = <String, double>{}.obs;
  final _promediosEquipos = <String, double>{}.obs;

  // Getters
  bool get isLoading => _isLoading.value;
  List<EvaluacionPeriodo> get evaluacionesPorActividad =>
      _evaluacionesPorActividad.toList();
  EvaluacionPeriodo? get evaluacionActual => _evaluacionActual.value;
  List<EvaluacionIndividual> get misEvaluacionesPendientes =>
      _misEvaluacionesPendientes.toList();
  List<EvaluacionIndividual> get misEvaluaciones => _misEvaluaciones.toList();
  Map<String, dynamic> get estadisticas => Map.from(_estadisticas);
  Map<String, double> get promediosEstudiantes =>
      Map.from(_promediosEstudiantes);
  Map<String, double> get promediosEquipos => Map.from(_promediosEquipos);

  // ========================== GESTIÓN DE PERÍODOS ==========================

  Future<void> cargarEvaluacionesPorActividad(String actividadId) async {
    try {
      _isLoading.value = true;
      final evaluaciones = await _evaluacionUseCase
          .obtenerEvaluacionesPorActividad(actividadId);
      _evaluacionesPorActividad.assignAll(evaluaciones);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error al cargar evaluaciones: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> crearNuevaEvaluacion({
    required String actividadId,
    required String titulo,
    String? descripcion,
    required String profesorId,
    int? duracionMaximaHoras,
    bool permitirAutoEvaluacion = false,
    bool iniciarInmediatamente = false, // 🔹 NUEVO parámetro
  }) async {
    try {
      _isLoading.value = true;
      print('🚀 EvaluacionController: Iniciando creación de evaluación');
      print('   - Actividad ID: $actividadId');
      print('   - Título: $titulo');
      print('   - Profesor ID: $profesorId');
      print('   - Iniciar inmediatamente: $iniciarInmediatamente');

      final periodoId = await _evaluacionUseCase.crearPeriodoEvaluacion(
        actividadId: actividadId,
        titulo: titulo,
        descripcion: descripcion,
        profesorId: profesorId,
        duracionMaximaHoras: duracionMaximaHoras,
        permitirAutoEvaluacion: permitirAutoEvaluacion,
      );

      print('✅ Período creado con ID: $periodoId');

      // 🔹 NUEVO: Si se especifica, iniciar automáticamente
      if (iniciarInmediatamente) {
        print('🎯 Iniciando evaluación automáticamente...');
        await _evaluacionUseCase.iniciarEvaluacion(periodoId);

        Get.snackbar(
          'Éxito',
          'Evaluación creada e iniciada. Los estudiantes ya pueden evaluar.',
          snackPosition: SnackPosition.BOTTOM,
        );
        print('✅ Evaluación iniciada exitosamente');
      } else {
        Get.snackbar(
          'Éxito',
          'Evaluación creada correctamente',
          snackPosition: SnackPosition.BOTTOM,
        );
        print('✅ Evaluación creada pero no iniciada');
      }

      // Recargar evaluaciones
      print('🔄 Recargando evaluaciones para actividad: $actividadId');
      await cargarEvaluacionesPorActividad(actividadId);
      print('✅ Evaluaciones recargadas');
    } catch (e) {
      print('❌ Error en EvaluacionController: $e');
      Get.snackbar(
        'Error',
        'Error al crear evaluación: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      rethrow; // Re-lanzar la excepción para que sea manejada en la UI
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> iniciarEvaluacion(String periodoId) async {
    try {
      _isLoading.value = true;
      await _evaluacionUseCase.iniciarEvaluacion(periodoId);

      Get.snackbar(
        'Éxito',
        'Evaluación iniciada. Los estudiantes ya pueden evaluar.',
        snackPosition: SnackPosition.BOTTOM,
      );

      // Recargar el período actual
      await cargarEvaluacionPeriodo(periodoId);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error al iniciar evaluación: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> finalizarEvaluacion(String periodoId) async {
    try {
      _isLoading.value = true;
      await _evaluacionUseCase.finalizarEvaluacion(periodoId);

      Get.snackbar(
        'Éxito',
        'Evaluación finalizada correctamente',
        snackPosition: SnackPosition.BOTTOM,
      );

      // Recargar el período actual
      await cargarEvaluacionPeriodo(periodoId);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error al finalizar evaluación: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> cargarEvaluacionPeriodo(String periodoId) async {
    try {
      _isLoading.value = true;
      final periodo = await _evaluacionUseCase.obtenerEvaluacionPeriodo(
        periodoId,
      );
      _evaluacionActual.value = periodo;

      if (periodo != null) {
        await cargarEstadisticas(periodoId);
        await cargarPromedios(periodoId);
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error al cargar evaluación: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  // ========================== EVALUACIONES INDIVIDUALES ==========================

  Future<void> cargarMisEvaluacionesPendientes(
    String evaluadorId,
    String periodoId,
  ) async {
    try {
      _isLoading.value = true;
      final evaluaciones = await _evaluacionUseCase
          .obtenerMisEvaluacionesPendientes(evaluadorId, periodoId);
      _misEvaluacionesPendientes.assignAll(evaluaciones);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error al cargar evaluaciones pendientes: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> cargarMisEvaluaciones(
    String evaluadorId,
    String periodoId,
  ) async {
    try {
      _isLoading.value = true;
      final evaluaciones = await _evaluacionUseCase.obtenerMisEvaluaciones(
        evaluadorId,
        periodoId,
      );
      _misEvaluaciones.assignAll(evaluaciones);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error al cargar evaluaciones: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> guardarEvaluacion({
    required String periodoId,
    required String evaluadorId,
    required String evaluadoId,
    required String equipoId,
    required Map<CriterioEvaluacion, NivelEvaluacion> calificaciones,
    String? comentarios,
  }) async {
    try {
      _isLoading.value = true;

      await _evaluacionUseCase.guardarEvaluacionIndividual(
        periodoId: periodoId,
        evaluadorId: evaluadorId,
        evaluadoId: evaluadoId,
        equipoId: equipoId,
        calificaciones: calificaciones,
        comentarios: comentarios,
      );

      // No mostrar snackbar aquí, lo maneja la UI

      // Recargar evaluaciones pendientes
      await cargarMisEvaluacionesPendientes(evaluadorId, periodoId);
      // También recargar todas las evaluaciones para reflejar el cambio de estado
      await cargarMisEvaluaciones(evaluadorId, periodoId);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error al guardar evaluación: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  // ========================== ANÁLISIS Y REPORTES ==========================

  Future<void> cargarEstadisticas(String periodoId) async {
    try {
      final stats = await _evaluacionUseCase.obtenerEstadisticasEvaluacion(
        periodoId,
      );
      _estadisticas.assignAll(stats);
    } catch (e) {
      print('Error al cargar estadísticas: $e');
    }
  }

  Future<void> cargarPromedios(String periodoId) async {
    try {
      final promediosEst = await _evaluacionUseCase
          .obtenerPromediosPorEstudiante(periodoId);
      final promediosEq = await _evaluacionUseCase.obtenerPromediosPorEquipo(
        periodoId,
      );

      _promediosEstudiantes.assignAll(promediosEst);
      _promediosEquipos.assignAll(promediosEq);
    } catch (e) {
      print('Error al cargar promedios: $e');
    }
  }

  // ========================== UTILIDADES ==========================

  String formatearPromedio(double promedio) {
    return promedio.toStringAsFixed(2);
  }

  String obtenerNivelPorPromedio(double promedio) {
    if (promedio >= 4.5) return 'Excelente';
    if (promedio >= 3.5) return 'Bueno';
    if (promedio >= 2.5) return 'Adecuado';
    return 'Necesita Mejorar';
  }

  String obtenerColorPorPromedio(double promedio) {
    if (promedio >= 4.5) return '#4CAF50'; // Verde
    if (promedio >= 3.5) return '#2196F3'; // Azul
    if (promedio >= 2.5) return '#FF9800'; // Naranja
    return '#F44336'; // Rojo
  }

  Future<void> eliminarEvaluacion(String periodoId, String actividadId) async {
    try {
      _isLoading.value = true;
      await _evaluacionUseCase.eliminarPeriodoEvaluacion(periodoId);

      Get.snackbar(
        'Éxito',
        'Evaluación eliminada correctamente',
        snackPosition: SnackPosition.BOTTOM,
      );

      // Recargar evaluaciones para la actividad
      await cargarEvaluacionesPorActividad(actividadId);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error al eliminar evaluación: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  void limpiarDatos() {
    _evaluacionesPorActividad.clear();
    _evaluacionActual.value = null;
    _misEvaluacionesPendientes.clear();
    _estadisticas.clear();
    _promediosEstudiantes.clear();
    _promediosEquipos.clear();
  }

  @override
  void onClose() {
    limpiarDatos();
    super.onClose();
  }
}
