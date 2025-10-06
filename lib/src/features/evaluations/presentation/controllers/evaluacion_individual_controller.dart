import 'package:get/get.dart';
import '../../domain/entities/evaluacion_individual.dart';
import '../../domain/entities/criterios_evaluacion.dart';
import '../../domain/usecases/evaluacion_individual_usecase.dart';

class EvaluacionIndividualController extends GetxController {
  final EvaluacionIndividualUseCase _useCase;

  EvaluacionIndividualController(this._useCase);

  // Estados reactivos
  final _isLoading = false.obs;
  final _isSaving = false.obs;
  final _evaluacionesPorPeriodo = <String, List<EvaluacionIndividual>>{}.obs;
  final _evaluacionesPorEvaluador = <String, List<EvaluacionIndividual>>{}.obs;
  final _evaluacionesPorEvaluado = <String, List<EvaluacionIndividual>>{}.obs;
  final _evaluacionActual = Rxn<EvaluacionIndividual>();
  final _calificacionesTemporales = <CriterioEvaluacion, double>{}.obs;
  final _comentariosTemporales = ''.obs;

  // Getters
  bool get isLoading => _isLoading.value;
  bool get isSaving => _isSaving.value;
  Map<String, List<EvaluacionIndividual>> get evaluacionesPorPeriodo =>
      _evaluacionesPorPeriodo;
  Map<String, List<EvaluacionIndividual>> get evaluacionesPorEvaluador =>
      _evaluacionesPorEvaluador;
  Map<String, List<EvaluacionIndividual>> get evaluacionesPorEvaluado =>
      _evaluacionesPorEvaluado;
  EvaluacionIndividual? get evaluacionActual => _evaluacionActual.value;
  Map<CriterioEvaluacion, double> get calificacionesTemporales =>
      _calificacionesTemporales;
  String get comentariosTemporales => _comentariosTemporales.value;

  // Métodos de carga
  Future<void> cargarEvaluacionesPorPeriodo(String evaluacionPeriodoId) async {
    try {
      _isLoading.value = true;
      final evaluaciones = await _useCase.getEvaluacionesPorPeriodo(
        evaluacionPeriodoId,
      );
      _evaluacionesPorPeriodo[evaluacionPeriodoId] = evaluaciones;
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudieron cargar las evaluaciones del período: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> cargarEvaluacionesPorEvaluador(String evaluadorId) async {
    try {
      _isLoading.value = true;
      final evaluaciones = await _useCase.getEvaluacionesPorEvaluador(
        evaluadorId,
      );
      _evaluacionesPorEvaluador[evaluadorId] = evaluaciones;
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudieron cargar las evaluaciones del evaluador: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> cargarEvaluacionesPorEvaluado(String evaluadoId) async {
    try {
      _isLoading.value = true;
      final evaluaciones = await _useCase.getEvaluacionesPorEvaluado(
        evaluadoId,
      );
      _evaluacionesPorEvaluado[evaluadoId] = evaluaciones;
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudieron cargar las evaluaciones del evaluado: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> cargarEvaluacionEspecifica(
    String evaluacionPeriodoId,
    String evaluadorId,
    String evaluadoId,
  ) async {
    try {
      _isLoading.value = true;
      final evaluacion = await _useCase.getEvaluacionEspecifica(
        evaluacionPeriodoId,
        evaluadorId,
        evaluadoId,
      );
      _evaluacionActual.value = evaluacion;

      // Cargar calificaciones temporales si existe la evaluación
      if (evaluacion != null) {
        _cargarCalificacionesTemporales(evaluacion);
        _comentariosTemporales.value = evaluacion.comentarios ?? '';
      } else {
        // Solo limpiar si no hay calificaciones temporales ya establecidas
        if (_calificacionesTemporales.isEmpty) {
          _limpiarCalificacionesTemporales();
        }
      }
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

  // Métodos de evaluación
  Future<bool> crearOActualizarEvaluacion({
    required String evaluacionPeriodoId,
    required String evaluadorId,
    required String evaluadoId,
    required String equipoId,
    bool completar = false,
  }) async {
    try {
      print('🔄 [EVAL-CONTROLLER] Iniciando crearOActualizarEvaluacion');
      print('🔄 [EVAL-CONTROLLER] Parámetros:');
      print('   - evaluacionPeriodoId: $evaluacionPeriodoId');
      print('   - evaluadorId: $evaluadorId');
      print('   - evaluadoId: $evaluadoId');
      print('   - equipoId: $equipoId');
      print('   - completar: $completar');

      _isSaving.value = true;

      // Verificar si puede evaluar
      print('🔍 [EVAL-CONTROLLER] Verificando si puede evaluar...');
      final puedeEvaluar = await _useCase.puedeEvaluar(
        evaluadorId,
        evaluadoId,
        evaluacionPeriodoId,
      );
      print('🔍 [EVAL-CONTROLLER] Resultado puedeEvaluar: $puedeEvaluar');

      if (!puedeEvaluar) {
        print('❌ [EVAL-CONTROLLER] No puede evaluar - mostrando snackbar');
        Get.snackbar(
          'Error',
          'No puedes evaluar a este usuario en este momento',
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }

      EvaluacionIndividual evaluacion;

      print(
        '🔍 [EVAL-CONTROLLER] Verificando evaluación actual: ${_evaluacionActual.value}',
      );

      if (_evaluacionActual.value == null) {
        print('🔄 [EVAL-CONTROLLER] Creando nueva evaluación...');
        print(
          '🔍 [EVAL-CONTROLLER] Estado actual _calificacionesTemporales: $_calificacionesTemporales',
        );
        print(
          '🔍 [EVAL-CONTROLLER] Cantidad de calificaciones temporales: ${_calificacionesTemporales.length}',
        );

        // Crear nueva evaluación
        evaluacion = await _useCase.crearEvaluacion(
          evaluacionPeriodoId: evaluacionPeriodoId,
          evaluadorId: evaluadorId,
          evaluadoId: evaluadoId,
          equipoId: equipoId,
          calificacionesIniciales: _convertirCalificacionesAString(
            _calificacionesTemporales,
          ),
          comentarios: _comentariosTemporales.value.isNotEmpty
              ? _comentariosTemporales.value
              : null,
        );
        print('✅ [EVAL-CONTROLLER] Nueva evaluación creada: ${evaluacion.id}');
      } else {
        print('🔄 [EVAL-CONTROLLER] Actualizando evaluación existente...');
        // Actualizar evaluación existente
        evaluacion = await _useCase.actualizarEvaluacionCompleta(
          evaluacionId: _evaluacionActual.value!.id,
          calificaciones: _calificacionesTemporales,
          comentarios: _comentariosTemporales.value.isNotEmpty
              ? _comentariosTemporales.value
              : null,
          completar: completar,
        );
        print('✅ [EVAL-CONTROLLER] Evaluación actualizada: ${evaluacion.id}');
      }

      _evaluacionActual.value = evaluacion;

      print('✅ [EVAL-CONTROLLER] Evaluación guardada exitosamente');
      Get.snackbar(
        'Éxito',
        completar
            ? 'Evaluación completada correctamente'
            : 'Evaluación guardada correctamente',
        snackPosition: SnackPosition.BOTTOM,
      );

      return true;
    } catch (e) {
      print('❌ [EVAL-CONTROLLER] ERROR COMPLETO: $e');
      print('❌ [EVAL-CONTROLLER] TIPO DE ERROR: ${e.runtimeType}');
      print('❌ [EVAL-CONTROLLER] STACK TRACE: ${StackTrace.current}');

      // Capturar el mensaje específico del error
      String errorMessage = 'No se pudo guardar la evaluación';
      if (e.toString().contains('actividad')) {
        errorMessage = e.toString();
        print(
          '🔍 [EVAL-CONTROLLER] Error relacionado con actividad detectado: $errorMessage',
        );
      }

      Get.snackbar('Error', errorMessage, snackPosition: SnackPosition.BOTTOM);
      return false;
    } finally {
      _isSaving.value = false;
    }
  }

  Future<bool> completarEvaluacion() async {
    if (_evaluacionActual.value == null) {
      Get.snackbar(
        'Error',
        'No hay evaluación para completar',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    if (_calificacionesTemporales.isEmpty) {
      Get.snackbar(
        'Error',
        'Debes completar al menos una calificación',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    try {
      _isSaving.value = true;

      final evaluacion = await _useCase.actualizarEvaluacionCompleta(
        evaluacionId: _evaluacionActual.value!.id,
        calificaciones: _calificacionesTemporales,
        comentarios: _comentariosTemporales.value.isNotEmpty
            ? _comentariosTemporales.value
            : null,
        completar: true,
      );

      _evaluacionActual.value = evaluacion;

      Get.snackbar(
        'Éxito',
        'Evaluación completada correctamente',
        snackPosition: SnackPosition.BOTTOM,
      );

      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo completar la evaluación: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      _isSaving.value = false;
    }
  }

  // Métodos para manejo de calificaciones temporales
  void actualizarCalificacionTemporal(
    CriterioEvaluacion criterio,
    double calificacion,
  ) {
    print('🔄 [TEMPORAL] Actualizando calificación temporal:');
    print('   - Criterio: $criterio (${criterio.key})');
    print('   - Calificación: $calificacion');
    print('   - Estado anterior: $_calificacionesTemporales');

    if (calificacion >= 1.0 && calificacion <= 5.0) {
      _calificacionesTemporales[criterio] = calificacion;
      print(
        '   ✅ Calificación aceptada. Nuevo estado: $_calificacionesTemporales',
      );
    } else {
      print('   ❌ Calificación rechazada (fuera de rango 1.0-5.0)');
    }
  }

  void actualizarComentariosTemporal(String comentarios) {
    _comentariosTemporales.value = comentarios;
  }

  // Método para crear/actualizar evaluación con calificaciones específicas (sin usar estado temporal)
  Future<bool> crearOActualizarEvaluacionConCalificaciones({
    required String evaluacionPeriodoId,
    required String evaluadorId,
    required String evaluadoId,
    required String equipoId,
    required Map<String, double> calificaciones,
    String? comentarios,
    bool completar = false,
  }) async {
    try {
      print(
        '🔄 [EVAL-CONTROLLER] Iniciando crearOActualizarEvaluacionConCalificaciones',
      );
      print('🔄 [EVAL-CONTROLLER] Parámetros:');
      print('   - evaluacionPeriodoId: $evaluacionPeriodoId');
      print('   - evaluadorId: $evaluadorId');
      print('   - evaluadoId: $evaluadoId');
      print('   - equipoId: $equipoId');
      print('   - calificaciones: $calificaciones');
      print('   - comentarios: $comentarios');
      print('   - completar: $completar');

      _isSaving.value = true;

      // Verificar si puede evaluar
      print('🔍 [EVAL-CONTROLLER] Verificando si puede evaluar...');
      final puedeEvaluar = await _useCase.puedeEvaluar(
        evaluadorId,
        evaluadoId,
        evaluacionPeriodoId,
      );
      print('🔍 [EVAL-CONTROLLER] Resultado puedeEvaluar: $puedeEvaluar');

      if (!puedeEvaluar) {
        print('❌ [EVAL-CONTROLLER] No puede evaluar - mostrando snackbar');
        Get.snackbar(
          'Error',
          'No puedes evaluar a este usuario en este momento',
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }

      // Obtener evaluación existente
      final evaluacionExistente = await _useCase.getEvaluacionEspecifica(
        evaluacionPeriodoId,
        evaluadorId,
        evaluadoId,
      );

      EvaluacionIndividual evaluacion;

      if (evaluacionExistente == null) {
        print('🔄 [EVAL-CONTROLLER] Creando nueva evaluación...');
        print('🔍 [EVAL-CONTROLLER] Calificaciones a guardar: $calificaciones');

        // Crear nueva evaluación
        evaluacion = await _useCase.crearEvaluacion(
          evaluacionPeriodoId: evaluacionPeriodoId,
          evaluadorId: evaluadorId,
          evaluadoId: evaluadoId,
          equipoId: equipoId,
          calificacionesIniciales: calificaciones,
          comentarios: comentarios,
        );
        print('✅ [EVAL-CONTROLLER] Nueva evaluación creada: ${evaluacion.id}');
      } else {
        print('🔄 [EVAL-CONTROLLER] Actualizando evaluación existente...');

        // Convertir calificaciones string a criterios
        final calificacionesPorCriterio = <CriterioEvaluacion, double>{};
        calificaciones.forEach((key, value) {
          switch (key) {
            case 'puntualidad':
              calificacionesPorCriterio[CriterioEvaluacion.puntualidad] = value;
              break;
            case 'contribuciones':
              calificacionesPorCriterio[CriterioEvaluacion.contribuciones] =
                  value;
              break;
            case 'compromiso':
              calificacionesPorCriterio[CriterioEvaluacion.compromiso] = value;
              break;
            case 'actitud':
              calificacionesPorCriterio[CriterioEvaluacion.actitud] = value;
              break;
          }
        });

        // Actualizar evaluación existente
        evaluacion = await _useCase.actualizarEvaluacionCompleta(
          evaluacionId: evaluacionExistente.id,
          calificaciones: calificacionesPorCriterio,
          comentarios: comentarios,
          completar: completar,
        );
        print('✅ [EVAL-CONTROLLER] Evaluación actualizada: ${evaluacion.id}');
      }

      _evaluacionActual.value = evaluacion;
      print('✅ [EVAL-CONTROLLER] Evaluación guardada exitosamente');

      // No limpiar calificaciones temporales aquí para no interferir con otras evaluaciones
      return true;
    } catch (e) {
      print(
        '❌ [EVAL-CONTROLLER] Error en crearOActualizarEvaluacionConCalificaciones: $e',
      );
      Get.snackbar(
        'Error',
        'No se pudo guardar la evaluación: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      _isSaving.value = false;
    }
  }

  void _cargarCalificacionesTemporales(EvaluacionIndividual evaluacion) {
    _calificacionesTemporales.clear();
    final calificacionesPorCriterio = evaluacion.calificacionesPorCriterio;
    _calificacionesTemporales.addAll(calificacionesPorCriterio);
  }

  void _limpiarCalificacionesTemporales() {
    _calificacionesTemporales.clear();
    _comentariosTemporales.value = '';
  }

  Map<String, double> _convertirCalificacionesAString(
    Map<CriterioEvaluacion, double> calificaciones,
  ) {
    print('🔍 [CONVERT] === CONVERSIÓN DE CALIFICACIONES ===');
    print('🔍 [CONVERT] Mapa recibido: $calificaciones');
    print('🔍 [CONVERT] Tamaño del mapa: ${calificaciones.length}');

    final resultado = <String, double>{};
    calificaciones.forEach((criterio, calificacion) {
      print(
        '🔍 [CONVERT] Convirtiendo: $criterio (${criterio.key}) -> $calificacion',
      );
      resultado[criterio.key] = calificacion;
    });

    print('🔍 [CONVERT] Resultado final: $resultado');
    return resultado;
  }

  // Métodos de estadísticas
  Future<Map<String, dynamic>?> getEstadisticasEvaluaciones(
    String evaluacionPeriodoId,
  ) async {
    try {
      return await _useCase.getEstadisticasEvaluaciones(evaluacionPeriodoId);
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudieron cargar las estadísticas: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    }
  }

  Future<Map<String, double>?> getPromedioUsuario(
    String evaluadoId,
    String evaluacionPeriodoId,
  ) async {
    try {
      return await _useCase.getPromedioEvaluacionesPorUsuario(
        evaluadoId,
        evaluacionPeriodoId,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo cargar el promedio del usuario: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    }
  }

  Future<List<String>> getUsuariosPendientesPorEvaluar(
    String evaluadorId,
    String evaluacionPeriodoId,
    List<String> posiblesEvaluados,
  ) async {
    try {
      return await _useCase.getUsuariosPendientesPorEvaluar(
        evaluadorId,
        evaluacionPeriodoId,
        posiblesEvaluados,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudieron cargar los usuarios pendientes: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      return [];
    }
  }

  // Getters de conveniencia
  List<EvaluacionIndividual> getEvaluacionesPorPeriodoLocal(
    String evaluacionPeriodoId,
  ) {
    return _evaluacionesPorPeriodo[evaluacionPeriodoId] ?? [];
  }

  List<EvaluacionIndividual> getEvaluacionesPorEvaluadorLocal(
    String evaluadorId,
  ) {
    return _evaluacionesPorEvaluador[evaluadorId] ?? [];
  }

  List<EvaluacionIndividual> getEvaluacionesPorEvaluadoLocal(
    String evaluadoId,
  ) {
    return _evaluacionesPorEvaluado[evaluadoId] ?? [];
  }

  double? getCalificacionTemporal(CriterioEvaluacion criterio) {
    return _calificacionesTemporales[criterio];
  }

  bool get tieneCalificacionesTemporales =>
      _calificacionesTemporales.isNotEmpty;

  bool get puedeCompletar => _calificacionesTemporales.isNotEmpty;

  /// Genera automáticamente evaluaciones individuales para un periodo activo
  Future<List<EvaluacionIndividual>> generarEvaluacionesParaPeriodo({
    required String evaluacionPeriodoId,
    required String equipoId,
    required List<String> miembrosEquipo,
  }) async {
    try {
      _isLoading.value = true;
      print('🔄 [EVAL-CONTROLLER] Iniciando generación de evaluaciones');
      print('🔄 [EVAL-CONTROLLER] Periodo: $evaluacionPeriodoId');
      print('🔄 [EVAL-CONTROLLER] Equipo: $equipoId');
      print('🔄 [EVAL-CONTROLLER] Miembros: $miembrosEquipo');

      final evaluacionesGeneradas = await _useCase
          .generarEvaluacionesParaPeriodo(
            evaluacionPeriodoId: evaluacionPeriodoId,
            equipoId: equipoId,
            miembrosEquipo: miembrosEquipo,
          );

      // Actualizar cache local
      if (_evaluacionesPorPeriodo.containsKey(evaluacionPeriodoId)) {
        final evaluacionesExistentes =
            _evaluacionesPorPeriodo[evaluacionPeriodoId] ?? [];
        _evaluacionesPorPeriodo[evaluacionPeriodoId] = [
          ...evaluacionesExistentes,
          ...evaluacionesGeneradas,
        ];
      } else {
        _evaluacionesPorPeriodo[evaluacionPeriodoId] = evaluacionesGeneradas;
      }

      print(
        '✅ [EVAL-CONTROLLER] Generadas ${evaluacionesGeneradas.length} evaluaciones',
      );
      return evaluacionesGeneradas;
    } catch (e) {
      print('❌ [EVAL-CONTROLLER] Error generando evaluaciones: $e');
      Get.snackbar(
        'Error',
        'No se pudieron generar las evaluaciones: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      return [];
    } finally {
      _isLoading.value = false;
    }
  }

  void limpiarCache() {
    _evaluacionesPorPeriodo.clear();
    _evaluacionesPorEvaluador.clear();
    _evaluacionesPorEvaluado.clear();
    _evaluacionActual.value = null;
    _limpiarCalificacionesTemporales();
  }

  // Método para verificar si puede evaluar (incluye auto-evaluación)
  Future<bool> puedeEvaluar(
    String evaluadorId,
    String evaluadoId,
    String evaluacionPeriodoId,
  ) async {
    try {
      return await _useCase.puedeEvaluar(
        evaluadorId,
        evaluadoId,
        evaluacionPeriodoId,
      );
    } catch (e) {
      print('❌ Error verificando si puede evaluar: $e');
      return false;
    }
  }

  @override
  void onClose() {
    limpiarCache();
    super.onClose();
  }
}
