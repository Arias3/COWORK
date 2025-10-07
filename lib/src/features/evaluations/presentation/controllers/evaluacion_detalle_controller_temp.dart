import 'package:get/get.dart';
import '../../domain/entities/evaluacion_individual.dart';
import '../../domain/usecases/evaluacion_periodo_usecase.dart';
import '../../domain/usecases/evaluacion_individual_usecase.dart';

/// Controlador temporal para funcionalidades de detalle de evaluación
/// Combina las capacidades de EvaluacionPeriodoController y EvaluacionIndividualController
/// para proporcionar estadísticas y análisis detallados
class EvaluacionDetalleControllerTemp extends GetxController {
  final EvaluacionPeriodoUseCase _periodoUseCase; // ignore: unused_field
  final EvaluacionIndividualUseCase _individualUseCase;

  EvaluacionDetalleControllerTemp(
    this._periodoUseCase,
    this._individualUseCase,
  );

  // Estados reactivos para estadísticas
  final _isLoadingStats = false.obs;
  final _estadisticas = <String, dynamic>{}.obs;
  final _promediosEstudiantes = <String, double>{}.obs;
  final _promediosEquipos = <String, double>{}.obs;
  final _evaluacionesPorEstudiante = <String, List<EvaluacionIndividual>>{}.obs;
  final _evaluacionesPorEquipo = <String, List<EvaluacionIndividual>>{}.obs;
  final _promediosPorCriterio = <String, double>{}.obs;

  // Getters
  bool get isLoadingStats => _isLoadingStats.value;
  Map<String, dynamic> get estadisticas => Map.from(_estadisticas);
  Map<String, double> get promediosEstudiantes =>
      Map.from(_promediosEstudiantes);
  Map<String, double> get promediosEquipos => Map.from(_promediosEquipos);
  Map<String, List<EvaluacionIndividual>> get evaluacionesPorEstudiante =>
      Map.from(_evaluacionesPorEstudiante);
  Map<String, List<EvaluacionIndividual>> get evaluacionesPorEquipo =>
      Map.from(_evaluacionesPorEquipo);
  Map<String, double> get promediosPorCriterio =>
      Map.from(_promediosPorCriterio);

  /// Carga todas las estadísticas para una evaluación específica
  Future<void> cargarEstadisticasCompletas(String periodoId) async {
    try {
      _isLoadingStats.value = true;

      print('📊 [STATS] Cargando estadísticas para período: $periodoId');

      // Cargar evaluaciones individuales del período
      final evaluaciones = await _individualUseCase.getEvaluacionesPorPeriodo(
        periodoId,
      );
      print('📊 [STATS] Evaluaciones encontradas: ${evaluaciones.length}');

      // Calcular estadísticas generales
      await _calcularEstadisticasGenerales(evaluaciones);

      // Calcular promedios por estudiante
      await _calcularPromediosPorEstudiante(evaluaciones);

      // Calcular promedios por equipo
      await _calcularPromediosPorEquipo(evaluaciones);

      // Calcular promedios por criterio
      await _calcularPromediosPorCriterio(evaluaciones);

      print('✅ [STATS] Estadísticas cargadas correctamente');
    } catch (e) {
      print('❌ [STATS] Error cargando estadísticas: $e');
      Get.snackbar(
        'Error',
        'Error al cargar estadísticas: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoadingStats.value = false;
    }
  }

  /// Calcula estadísticas generales de la evaluación
  Future<void> _calcularEstadisticasGenerales(
    List<EvaluacionIndividual> evaluaciones,
  ) async {
    final total = evaluaciones.length;
    final completadas = evaluaciones.where((e) => e.completada).length;
    final pendientes = total - completadas;
    final porcentajeCompletado = total > 0 ? (completadas / total) * 100 : 0.0;

    // Calcular promedio general
    final evaluacionesCompletadas = evaluaciones
        .where((e) => e.completada)
        .toList();
    double promedioGeneral = 0.0;

    if (evaluacionesCompletadas.isNotEmpty) {
      final sumatoriaPromedios = evaluacionesCompletadas
          .map((e) => _calcularPromedioEvaluacion(e))
          .reduce((a, b) => a + b);
      promedioGeneral = sumatoriaPromedios / evaluacionesCompletadas.length;
    }

    _estadisticas.assignAll({
      'total': total,
      'completadas': completadas,
      'pendientes': pendientes,
      'porcentajeCompletado': porcentajeCompletado,
      'promedioGeneral': promedioGeneral,
    });

    print('📊 [STATS] Estadísticas generales: ${_estadisticas}');
  }

  /// Calcula promedios individuales por estudiante (como evaluado)
  Future<void> _calcularPromediosPorEstudiante(
    List<EvaluacionIndividual> evaluaciones,
  ) async {
    final Map<String, List<double>> calificacionesPorEstudiante = {};

    // Agrupar calificaciones por estudiante evaluado
    for (final evaluacion in evaluaciones.where((e) => e.completada)) {
      final evaluadoId = evaluacion.evaluadoId;
      final promedio = _calcularPromedioEvaluacion(evaluacion);

      if (!calificacionesPorEstudiante.containsKey(evaluadoId)) {
        calificacionesPorEstudiante[evaluadoId] = [];
      }
      calificacionesPorEstudiante[evaluadoId]!.add(promedio);

      // También guardar las evaluaciones por estudiante
      if (!_evaluacionesPorEstudiante.containsKey(evaluadoId)) {
        _evaluacionesPorEstudiante[evaluadoId] = [];
      }
      _evaluacionesPorEstudiante[evaluadoId]!.add(evaluacion);
    }

    // Calcular promedio final por estudiante
    final Map<String, double> promedios = {};
    calificacionesPorEstudiante.forEach((estudianteId, calificaciones) {
      if (calificaciones.isNotEmpty) {
        final promedio =
            calificaciones.reduce((a, b) => a + b) / calificaciones.length;
        promedios[estudianteId] = promedio;
      }
    });

    _promediosEstudiantes.assignAll(promedios);
    print(
      '📊 [STATS] Promedios por estudiante: ${promedios.length} estudiantes',
    );
  }

  /// Calcula promedios por equipo
  Future<void> _calcularPromediosPorEquipo(
    List<EvaluacionIndividual> evaluaciones,
  ) async {
    final Map<String, List<double>> calificacionesPorEquipo = {};

    // Agrupar calificaciones por equipo
    for (final evaluacion in evaluaciones.where((e) => e.completada)) {
      final equipoId = evaluacion.equipoId;
      final promedio = _calcularPromedioEvaluacion(evaluacion);

      if (!calificacionesPorEquipo.containsKey(equipoId)) {
        calificacionesPorEquipo[equipoId] = [];
      }
      calificacionesPorEquipo[equipoId]!.add(promedio);

      // También guardar las evaluaciones por equipo
      if (!_evaluacionesPorEquipo.containsKey(equipoId)) {
        _evaluacionesPorEquipo[equipoId] = [];
      }
      _evaluacionesPorEquipo[equipoId]!.add(evaluacion);
    }

    // Calcular promedio final por equipo
    final Map<String, double> promedios = {};
    calificacionesPorEquipo.forEach((equipoId, calificaciones) {
      if (calificaciones.isNotEmpty) {
        final promedio =
            calificaciones.reduce((a, b) => a + b) / calificaciones.length;
        promedios[equipoId] = promedio;
      }
    });

    _promediosEquipos.assignAll(promedios);
    print('📊 [STATS] Promedios por equipo: ${promedios.length} equipos');
  }

  /// Calcula promedios por criterio de evaluación
  Future<void> _calcularPromediosPorCriterio(
    List<EvaluacionIndividual> evaluaciones,
  ) async {
    final Map<String, List<double>> calificacionesPorCriterio = {};

    // Agrupar calificaciones por criterio
    for (final evaluacion in evaluaciones.where((e) => e.completada)) {
      evaluacion.calificaciones.forEach((criterioKey, calificacion) {
        if (!calificacionesPorCriterio.containsKey(criterioKey)) {
          calificacionesPorCriterio[criterioKey] = [];
        }
        calificacionesPorCriterio[criterioKey]!.add(calificacion);
      });
    }

    // Calcular promedio final por criterio
    final Map<String, double> promedios = {};
    calificacionesPorCriterio.forEach((criterio, calificaciones) {
      if (calificaciones.isNotEmpty) {
        final promedio =
            calificaciones.reduce((a, b) => a + b) / calificaciones.length;
        promedios[criterio] = promedio;
      }
    });

    _promediosPorCriterio.assignAll(promedios);
    print('📊 [STATS] Promedios por criterio: ${promedios}');
  }

  /// Calcula el promedio de una evaluación individual
  double _calcularPromedioEvaluacion(EvaluacionIndividual evaluacion) {
    if (evaluacion.calificaciones.isEmpty) return 0.0;

    final calificaciones = evaluacion.calificaciones.values.toList();
    final suma = calificaciones.reduce((a, b) => a + b);
    return suma / calificaciones.length;
  }

  /// Obtiene estadísticas detalladas de un estudiante específico
  Map<String, dynamic> getEstadisticasEstudiante(String estudianteId) {
    final evaluaciones = _evaluacionesPorEstudiante[estudianteId] ?? [];
    final promedio = _promediosEstudiantes[estudianteId] ?? 0.0;

    if (evaluaciones.isEmpty) {
      return {
        'promedio': 0.0,
        'totalEvaluaciones': 0,
        'evaluacionesRecibidas': 0,
        'porCriterio': <String, double>{},
      };
    }

    // Calcular promedios por criterio para este estudiante
    final Map<String, List<double>> calificacionesPorCriterio = {};
    for (final evaluacion in evaluaciones) {
      evaluacion.calificaciones.forEach((criterio, calificacion) {
        if (!calificacionesPorCriterio.containsKey(criterio)) {
          calificacionesPorCriterio[criterio] = [];
        }
        calificacionesPorCriterio[criterio]!.add(calificacion);
      });
    }

    final Map<String, double> promediosPorCriterio = {};
    calificacionesPorCriterio.forEach((criterio, calificaciones) {
      final promedioCriterio =
          calificaciones.reduce((a, b) => a + b) / calificaciones.length;
      promediosPorCriterio[criterio] = promedioCriterio;
    });

    return {
      'promedio': promedio,
      'totalEvaluaciones': evaluaciones.length,
      'evaluacionesRecibidas': evaluaciones.length,
      'porCriterio': promediosPorCriterio,
    };
  }

  /// Obtiene estadísticas detalladas de un equipo específico
  Map<String, dynamic> getEstadisticasEquipo(String equipoId) {
    final evaluaciones = _evaluacionesPorEquipo[equipoId] ?? [];
    final promedio = _promediosEquipos[equipoId] ?? 0.0;

    if (evaluaciones.isEmpty) {
      return {
        'promedio': 0.0,
        'totalEvaluaciones': 0,
        'miembrosEvaluados': <String>{},
        'porCriterio': <String, double>{},
      };
    }

    // Obtener miembros únicos evaluados en este equipo
    final miembrosEvaluados = evaluaciones.map((e) => e.evaluadoId).toSet();

    // Calcular promedios por criterio para este equipo
    final Map<String, List<double>> calificacionesPorCriterio = {};
    for (final evaluacion in evaluaciones) {
      evaluacion.calificaciones.forEach((criterio, calificacion) {
        if (!calificacionesPorCriterio.containsKey(criterio)) {
          calificacionesPorCriterio[criterio] = [];
        }
        calificacionesPorCriterio[criterio]!.add(calificacion);
      });
    }

    final Map<String, double> promediosPorCriterio = {};
    calificacionesPorCriterio.forEach((criterio, calificaciones) {
      final promedioCriterio =
          calificaciones.reduce((a, b) => a + b) / calificaciones.length;
      promediosPorCriterio[criterio] = promedioCriterio;
    });

    return {
      'promedio': promedio,
      'totalEvaluaciones': evaluaciones.length,
      'miembrosEvaluados': miembrosEvaluados,
      'porCriterio': promediosPorCriterio,
    };
  }

  /// Obtiene el top de estudiantes por promedio
  List<Map<String, dynamic>> getTopEstudiantes({int limite = 10}) {
    final estudiantesOrdenados = _promediosEstudiantes.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return estudiantesOrdenados.take(limite).map((entry) {
      final estadisticas = getEstadisticasEstudiante(entry.key);
      return {
        'estudianteId': entry.key,
        'promedio': entry.value,
        'estadisticas': estadisticas,
      };
    }).toList();
  }

  /// Obtiene el ranking de equipos por promedio
  List<Map<String, dynamic>> getRankingEquipos() {
    final equiposOrdenados = _promediosEquipos.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return equiposOrdenados.map((entry) {
      final estadisticas = getEstadisticasEquipo(entry.key);
      return {
        'equipoId': entry.key,
        'promedio': entry.value,
        'estadisticas': estadisticas,
      };
    }).toList();
  }

  /// Utilidades para formateo y visualización
  String formatearPromedio(double promedio) {
    return promedio.toStringAsFixed(2);
  }

  String obtenerNivelPorPromedio(double promedio) {
    if (promedio >= 4.5) return 'Excelente';
    if (promedio >= 3.5) return 'Bueno';
    if (promedio >= 2.5) return 'Adecuado';
    return 'Necesita Mejorar';
  }

  /// Limpia todos los datos cargados
  void limpiarDatos() {
    _estadisticas.clear();
    _promediosEstudiantes.clear();
    _promediosEquipos.clear();
    _evaluacionesPorEstudiante.clear();
    _evaluacionesPorEquipo.clear();
    _promediosPorCriterio.clear();
  }

  @override
  void onClose() {
    limpiarDatos();
    super.onClose();
  }
}
