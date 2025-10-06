import 'package:get/get.dart';
import '../../domain/entities/evaluacion_periodo.dart';
import '../../domain/usecases/evaluacion_periodo_usecase.dart';

class EvaluacionPeriodoController extends GetxController {
  final EvaluacionPeriodoUseCase _useCase;

  EvaluacionPeriodoController(this._useCase);

  // Estados reactivos
  final _isLoading = false.obs;
  final _evaluacionesPorActividad = <String, List<EvaluacionPeriodo>>{}.obs;
  final _evaluacionesPorProfesor = <String, List<EvaluacionPeriodo>>{}.obs;
  final _evaluacionesActivas = <EvaluacionPeriodo>[].obs;
  final _evaluacionActual = Rxn<EvaluacionPeriodo>();

  // Getters
  bool get isLoading => _isLoading.value;
  Map<String, List<EvaluacionPeriodo>> get evaluacionesPorActividad =>
      _evaluacionesPorActividad;
  Map<String, List<EvaluacionPeriodo>> get evaluacionesPorProfesor =>
      _evaluacionesPorProfesor;
  List<EvaluacionPeriodo> get evaluacionesActivas => _evaluacionesActivas;
  EvaluacionPeriodo? get evaluacionActual => _evaluacionActual.value;

  // Métodos
  Future<void> cargarEvaluacionesPorActividad(String actividadId) async {
    try {
      _isLoading.value = true;
      final evaluaciones = await _useCase.getEvaluacionesPorActividad(
        actividadId,
      );
      _evaluacionesPorActividad[actividadId] = evaluaciones;
    } catch (e) {
      // Solo log de error - no interrumpir UX con mensajes constantes de carga
      print('❌ Error cargando evaluaciones: $e');
      // Mensaje removido para evitar saturación
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> cargarEvaluacionesPorProfesor(String profesorId) async {
    try {
      _isLoading.value = true;
      final evaluaciones = await _useCase.getEvaluacionesPorProfesor(
        profesorId,
      );
      _evaluacionesPorProfesor[profesorId] = evaluaciones;
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudieron cargar las evaluaciones del profesor: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> cargarEvaluacionesActivas() async {
    try {
      _isLoading.value = true;
      final evaluaciones = await _useCase.getEvaluacionesActivas();
      _evaluacionesActivas.value = evaluaciones;
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudieron cargar las evaluaciones activas: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> cargarEvaluacionPorId(String id) async {
    try {
      _isLoading.value = true;
      final evaluacion = await _useCase.getEvaluacionPeriodoById(id);
      _evaluacionActual.value = evaluacion;
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo cargar la evaluación: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<bool> crearEvaluacionPeriodo({
    required String actividadId,
    required String titulo,
    String? descripcion,
    required DateTime fechaInicio,
    DateTime? fechaFin,
    required String profesorId,
    bool evaluacionEntrePares = true,
    bool permitirAutoEvaluacion = false,
    required List<String> criteriosEvaluacion,
    bool habilitarComentarios = true,
    double puntuacionMaxima = 5.0,
  }) async {
    try {
      _isLoading.value = true;

      // Verificar si puede crear la evaluación
      final puedeCrear = await _useCase.puedeCrearEvaluacion(
        actividadId,
        profesorId,
      );
      if (!puedeCrear) {
        Get.snackbar(
          'Error',
          'Ya existe una evaluación activa para esta actividad',
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }

      final evaluacion = await _useCase.crearEvaluacionPeriodo(
        actividadId: actividadId,
        titulo: titulo,
        descripcion: descripcion,
        fechaInicio: fechaInicio,
        fechaFin: fechaFin,
        profesorId: profesorId,
        evaluacionEntrePares: evaluacionEntrePares,
        permitirAutoEvaluacion: permitirAutoEvaluacion,
        criteriosEvaluacion: criteriosEvaluacion,
        habilitarComentarios: habilitarComentarios,
        puntuacionMaxima: puntuacionMaxima,
      );

      _evaluacionActual.value = evaluacion;

      // Actualizar listas locales
      await cargarEvaluacionesPorActividad(actividadId);
      await cargarEvaluacionesPorProfesor(profesorId);

      Get.snackbar(
        'Éxito',
        'Evaluación creada correctamente',
        snackPosition: SnackPosition.BOTTOM,
      );

      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo crear la evaluación: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<bool> activarEvaluacion(String id) async {
    try {
      _isLoading.value = true;
      final evaluacion = await _useCase.activarEvaluacionPeriodo(id);
      _evaluacionActual.value = evaluacion;

      // Actualizar listas
      await cargarEvaluacionesActivas();

      Get.snackbar(
        'Éxito',
        'Evaluación activada correctamente',
        snackPosition: SnackPosition.BOTTOM,
      );

      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo activar la evaluación: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<bool> finalizarEvaluacion(String id) async {
    try {
      _isLoading.value = true;
      final evaluacion = await _useCase.finalizarEvaluacionPeriodo(id);
      _evaluacionActual.value = evaluacion;

      // Actualizar listas
      await cargarEvaluacionesActivas();

      Get.snackbar(
        'Éxito',
        'Evaluación finalizada correctamente',
        snackPosition: SnackPosition.BOTTOM,
      );

      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo finalizar la evaluación: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<bool> eliminarEvaluacion(String id) async {
    try {
      _isLoading.value = true;
      final success = await _useCase.eliminarEvaluacionPeriodo(id);

      if (success) {
        // Limpiar evaluación actual si es la que se eliminó
        if (_evaluacionActual.value?.id == id) {
          _evaluacionActual.value = null;
        }

        // Actualizar listas
        await cargarEvaluacionesActivas();

        Get.snackbar(
          'Éxito',
          'Evaluación eliminada correctamente',
          snackPosition: SnackPosition.BOTTOM,
        );
      }

      return success;
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo eliminar la evaluación: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<Map<String, dynamic>?> getEstadisticasEvaluacion(
    String evaluacionId,
  ) async {
    try {
      return await _useCase.getEstadisticasEvaluacion(evaluacionId);
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudieron cargar las estadísticas: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    }
  }

  List<EvaluacionPeriodo> getEvaluacionesPorActividad(String actividadId) {
    return _evaluacionesPorActividad[actividadId] ?? [];
  }

  List<EvaluacionPeriodo> getEvaluacionesPorProfesorLocal(String profesorId) {
    return _evaluacionesPorProfesor[profesorId] ?? [];
  }

  void limpiarCache() {
    _evaluacionesPorActividad.clear();
    _evaluacionesPorProfesor.clear();
    _evaluacionesActivas.clear();
    _evaluacionActual.value = null;
  }

  @override
  void onClose() {
    limpiarCache();
    super.onClose();
  }
}
