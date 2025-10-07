import '../entities/evaluacion_individual.dart';
import '../repositories/evaluacion_periodo_repository.dart';
import '../repositories/evaluacion_individual_repository.dart';
import '../../../categories/domain/usecases/categoria_equipo_usecase.dart';
import '../../../categories/domain/usecases/equipo_actividad_usecase.dart';
import '../../../auth/domain/repositories/usuario_repository.dart';

/// UseCase temporal para análisis y estadísticas de evaluaciones
/// Proporciona métodos avanzados de análisis sin afectar los usecases existentes
class EvaluacionAnalisisUseCaseTemp {
  final EvaluacionPeriodoRepository _periodoRepository;
  final EvaluacionIndividualRepository _individualRepository;
  final CategoriaEquipoUseCase _equipoUseCase;
  final EquipoActividadUseCase _equipoActividadUseCase;
  final UsuarioRepository _usuarioRepository;

  EvaluacionAnalisisUseCaseTemp(
    this._periodoRepository,
    this._individualRepository,
    this._equipoUseCase,
    this._equipoActividadUseCase,
    this._usuarioRepository,
  );

  /// Obtiene un análisis completo de una evaluación
  Future<Map<String, dynamic>> obtenerAnalisisCompleto(String periodoId) async {
    try {
      print(
        '📊 [ANALISIS] Iniciando análisis completo para período: $periodoId',
      );

      // Obtener período de evaluación
      final periodo = await _periodoRepository.getEvaluacionPeriodoById(
        periodoId,
      );
      if (periodo == null) {
        throw Exception('Período de evaluación no encontrado');
      }

      // Obtener todas las evaluaciones del período
      final evaluaciones = await _individualRepository
          .getEvaluacionesPorPeriodo(periodoId);
      print('📊 [ANALISIS] Evaluaciones encontradas: ${evaluaciones.length}');

      // Obtener información de equipos de la actividad
      final equiposInfo = await _obtenerInformacionEquipos(periodo.actividadId);
      print('📊 [ANALISIS] Equipos en actividad: ${equiposInfo.length}');

      // Calcular métricas principales
      final metricas = await _calcularMetricasPrincipales(
        evaluaciones,
        equiposInfo,
      );

      // Calcular distribución de calificaciones
      final distribucion = _calcularDistribucionCalificaciones(evaluaciones);

      // Calcular tendencias por criterio
      final tendenciasCriterios = _calcularTendenciasPorCriterio(evaluaciones);

      // Detectar outliers
      final outliers = _detectarOutliers(evaluaciones);

      return {
        'periodo': {
          'id': periodo.id,
          'titulo': periodo.titulo,
          'descripcion': periodo.descripcion,
          'estado': periodo.estado.toString(),
          'fechaInicio': periodo.fechaInicio.toIso8601String(),
          'fechaFin': periodo.fechaFin?.toIso8601String(),
          'permitirAutoEvaluacion': periodo.permitirAutoEvaluacion,
        },
        'metricas': metricas,
        'distribucion': distribucion,
        'tendenciasCriterios': tendenciasCriterios,
        'outliers': outliers,
        'equipos': equiposInfo,
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      print('❌ [ANALISIS] Error en análisis completo: $e');
      rethrow;
    }
  }

  /// Obtiene información detallada de equipos para una actividad
  Future<List<Map<String, dynamic>>> _obtenerInformacionEquipos(
    String actividadId,
  ) async {
    final equiposInfo = <Map<String, dynamic>>[];

    try {
      // Obtener asignaciones de equipos para la actividad
      final asignaciones = await _equipoActividadUseCase
          .getAsignacionesByActividad(actividadId);

      for (final asignacion in asignaciones) {
        final equipo = await _equipoUseCase.getEquipoById(
          asignacion.equipoId.toString(),
        );

        if (equipo != null) {
          // Obtener información de estudiantes
          final estudiantes = <Map<String, dynamic>>[];
          for (final estudianteId in equipo.estudiantesIds) {
            final usuario = await _usuarioRepository.getUsuarioById(
              estudianteId,
            );
            if (usuario != null) {
              estudiantes.add({
                'id': estudianteId,
                'nombre': usuario.nombre,
                'email': usuario.email,
              });
            }
          }

          equiposInfo.add({
            'id': equipo.id.toString(),
            'nombre': equipo.nombre,
            'descripcion': equipo.descripcion,
            'estudiantes': estudiantes,
            'totalEstudiantes': estudiantes.length,
          });
        }
      }
    } catch (e) {
      print('❌ [ANALISIS] Error obteniendo información de equipos: $e');
    }

    return equiposInfo;
  }

  /// Calcula métricas principales de la evaluación
  Future<Map<String, dynamic>> _calcularMetricasPrincipales(
    List<EvaluacionIndividual> evaluaciones,
    List<Map<String, dynamic>> equiposInfo,
  ) async {
    final evaluacionesCompletadas = evaluaciones
        .where((e) => e.completada)
        .toList();
    final totalEvaluaciones = evaluaciones.length;
    final completadas = evaluacionesCompletadas.length;
    final pendientes = totalEvaluaciones - completadas;

    // Calcular tasas de participación
    final estudiantesUnicos = evaluaciones.map((e) => e.evaluadorId).toSet();
    final estudiantesTotales = equiposInfo.fold<int>(
      0,
      (total, equipo) => total + (equipo['totalEstudiantes'] as int),
    );

    final tasaParticipacion = estudiantesTotales > 0
        ? (estudiantesUnicos.length / estudiantesTotales) * 100
        : 0.0;

    // Calcular promedios
    double promedioGeneral = 0.0;
    if (evaluacionesCompletadas.isNotEmpty) {
      final sumaPromedios = evaluacionesCompletadas
          .map((e) => _calcularPromedioEvaluacion(e))
          .fold<double>(0.0, (sum, promedio) => sum + promedio);
      promedioGeneral = sumaPromedios / evaluacionesCompletadas.length;
    }

    // Calcular desviación estándar
    double desviacionEstandar = 0.0;
    if (evaluacionesCompletadas.length > 1) {
      final promedios = evaluacionesCompletadas
          .map((e) => _calcularPromedioEvaluacion(e))
          .toList();
      final varianza =
          promedios
              .map((p) => (p - promedioGeneral) * (p - promedioGeneral))
              .fold<double>(0.0, (sum, val) => sum + val) /
          promedios.length;
      desviacionEstandar = varianza > 0 ? varianza : 0.0; // Aproximación simple
    }

    return {
      'totalEvaluaciones': totalEvaluaciones,
      'completadas': completadas,
      'pendientes': pendientes,
      'porcentajeCompletado': totalEvaluaciones > 0
          ? (completadas / totalEvaluaciones) * 100
          : 0.0,
      'estudiantesParticipantes': estudiantesUnicos.length,
      'estudiantesTotales': estudiantesTotales,
      'tasaParticipacion': tasaParticipacion,
      'promedioGeneral': promedioGeneral,
      'desviacionEstandar': desviacionEstandar,
      'calificacionMinima': evaluacionesCompletadas.isNotEmpty
          ? evaluacionesCompletadas
                .map((e) => _calcularPromedioEvaluacion(e))
                .reduce((a, b) => a < b ? a : b)
          : 0.0,
      'calificacionMaxima': evaluacionesCompletadas.isNotEmpty
          ? evaluacionesCompletadas
                .map((e) => _calcularPromedioEvaluacion(e))
                .reduce((a, b) => a > b ? a : b)
          : 0.0,
    };
  }

  /// Calcula la distribución de calificaciones
  Map<String, dynamic> _calcularDistribucionCalificaciones(
    List<EvaluacionIndividual> evaluaciones,
  ) {
    final evaluacionesCompletadas = evaluaciones
        .where((e) => e.completada)
        .toList();

    if (evaluacionesCompletadas.isEmpty) {
      return {
        'excelente': 0,
        'bueno': 0,
        'adecuado': 0,
        'necesitaMejorar': 0,
        'porcentajes': {
          'excelente': 0.0,
          'bueno': 0.0,
          'adecuado': 0.0,
          'necesitaMejorar': 0.0,
        },
      };
    }

    int excelente = 0, bueno = 0, adecuado = 0, necesitaMejorar = 0;

    for (final evaluacion in evaluacionesCompletadas) {
      final promedio = _calcularPromedioEvaluacion(evaluacion);

      if (promedio >= 4.5) {
        excelente++;
      } else if (promedio >= 3.5) {
        bueno++;
      } else if (promedio >= 2.5) {
        adecuado++;
      } else {
        necesitaMejorar++;
      }
    }

    final total = evaluacionesCompletadas.length;

    return {
      'excelente': excelente,
      'bueno': bueno,
      'adecuado': adecuado,
      'necesitaMejorar': necesitaMejorar,
      'porcentajes': {
        'excelente': total > 0 ? (excelente / total) * 100 : 0.0,
        'bueno': total > 0 ? (bueno / total) * 100 : 0.0,
        'adecuado': total > 0 ? (adecuado / total) * 100 : 0.0,
        'necesitaMejorar': total > 0 ? (necesitaMejorar / total) * 100 : 0.0,
      },
    };
  }

  /// Calcula tendencias por criterio de evaluación
  Map<String, dynamic> _calcularTendenciasPorCriterio(
    List<EvaluacionIndividual> evaluaciones,
  ) {
    final evaluacionesCompletadas = evaluaciones
        .where((e) => e.completada)
        .toList();
    final Map<String, List<double>> calificacionesPorCriterio = {};

    // Recopilar calificaciones por criterio
    for (final evaluacion in evaluacionesCompletadas) {
      evaluacion.calificaciones.forEach((criterio, calificacion) {
        if (!calificacionesPorCriterio.containsKey(criterio)) {
          calificacionesPorCriterio[criterio] = [];
        }
        calificacionesPorCriterio[criterio]!.add(calificacion);
      });
    }

    // Calcular estadísticas por criterio
    final Map<String, Map<String, dynamic>> estadisticasPorCriterio = {};

    calificacionesPorCriterio.forEach((criterio, calificaciones) {
      if (calificaciones.isNotEmpty) {
        final promedio =
            calificaciones.reduce((a, b) => a + b) / calificaciones.length;
        final minimo = calificaciones.reduce((a, b) => a < b ? a : b);
        final maximo = calificaciones.reduce((a, b) => a > b ? a : b);

        // Calcular mediana
        final ordenadas = [...calificaciones]..sort();
        final mediana = ordenadas.length % 2 == 0
            ? (ordenadas[ordenadas.length ~/ 2 - 1] +
                      ordenadas[ordenadas.length ~/ 2]) /
                  2
            : ordenadas[ordenadas.length ~/ 2];

        estadisticasPorCriterio[criterio] = {
          'promedio': promedio,
          'mediana': mediana,
          'minimo': minimo,
          'maximo': maximo,
          'totalEvaluaciones': calificaciones.length,
          'nivel': _obtenerNivelPorPromedio(promedio),
        };
      }
    });

    return estadisticasPorCriterio;
  }

  /// Detecta valores atípicos (outliers) en las evaluaciones
  List<Map<String, dynamic>> _detectarOutliers(
    List<EvaluacionIndividual> evaluaciones,
  ) {
    final evaluacionesCompletadas = evaluaciones
        .where((e) => e.completada)
        .toList();
    final outliers = <Map<String, dynamic>>[];

    if (evaluacionesCompletadas.length < 3)
      return outliers; // Necesitamos datos suficientes

    // Calcular promedios
    final promedios = evaluacionesCompletadas
        .map((e) => _calcularPromedioEvaluacion(e))
        .toList();
    final promedioGeneral =
        promedios.reduce((a, b) => a + b) / promedios.length;

    // Calcular desviación estándar simple
    final varianza =
        promedios
            .map((p) => (p - promedioGeneral) * (p - promedioGeneral))
            .reduce((a, b) => a + b) /
        promedios.length;
    final desviacionEstandar = varianza > 0 ? varianza : 0.0;

    // Identificar outliers (valores que están a más de 2 desviaciones estándar)
    for (int i = 0; i < evaluacionesCompletadas.length; i++) {
      final evaluacion = evaluacionesCompletadas[i];
      final promedio = promedios[i];
      final diferencia = (promedio - promedioGeneral).abs();

      if (desviacionEstandar > 0 && diferencia > 2 * desviacionEstandar) {
        outliers.add({
          'evaluacionId': evaluacion.id,
          'evaluadorId': evaluacion.evaluadorId,
          'evaluadoId': evaluacion.evaluadoId,
          'equipoId': evaluacion.equipoId,
          'promedio': promedio,
          'promedioGeneral': promedioGeneral,
          'diferencia': diferencia,
          'tipo': promedio > promedioGeneral ? 'alto' : 'bajo',
        });
      }
    }

    return outliers;
  }

  /// Calcula el promedio de una evaluación individual
  double _calcularPromedioEvaluacion(EvaluacionIndividual evaluacion) {
    if (evaluacion.calificaciones.isEmpty) return 0.0;

    final calificaciones = evaluacion.calificaciones.values.toList();
    final suma = calificaciones.reduce((a, b) => a + b);
    return suma / calificaciones.length;
  }

  /// Obtiene el nivel descriptivo basado en el promedio
  String _obtenerNivelPorPromedio(double promedio) {
    if (promedio >= 4.5) return 'Excelente';
    if (promedio >= 3.5) return 'Bueno';
    if (promedio >= 2.5) return 'Adecuado';
    return 'Necesita Mejorar';
  }

  /// Obtiene un resumen de participación por equipo
  Future<List<Map<String, dynamic>>> obtenerParticipacionPorEquipo(
    String periodoId,
    String actividadId,
  ) async {
    try {
      final evaluaciones = await _individualRepository
          .getEvaluacionesPorPeriodo(periodoId);
      final equiposInfo = await _obtenerInformacionEquipos(actividadId);

      final participacionPorEquipo = <Map<String, dynamic>>[];

      for (final equipoInfo in equiposInfo) {
        final equipoId = equipoInfo['id'] as String;
        final estudiantes =
            equipoInfo['estudiantes'] as List<Map<String, dynamic>>;

        // Contar evaluaciones del equipo
        final evaluacionesEquipo = evaluaciones
            .where((e) => e.equipoId == equipoId)
            .toList();
        final evaluacionesCompletadas = evaluacionesEquipo
            .where((e) => e.completada)
            .length;

        // Contar estudiantes que han evaluado
        final estudiantesQueEvaluaron = evaluacionesEquipo
            .where((e) => e.completada)
            .map((e) => e.evaluadorId)
            .toSet()
            .length;

        final porcentajeParticipacion = estudiantes.isNotEmpty
            ? (estudiantesQueEvaluaron / estudiantes.length) * 100
            : 0.0;

        participacionPorEquipo.add({
          'equipoId': equipoId,
          'equipoNombre': equipoInfo['nombre'],
          'totalEstudiantes': estudiantes.length,
          'estudiantesQueEvaluaron': estudiantesQueEvaluaron,
          'totalEvaluaciones': evaluacionesEquipo.length,
          'evaluacionesCompletadas': evaluacionesCompletadas,
          'porcentajeParticipacion': porcentajeParticipacion,
        });
      }

      return participacionPorEquipo;
    } catch (e) {
      print('❌ [ANALISIS] Error obteniendo participación por equipo: $e');
      return [];
    }
  }

  /// Genera un reporte de comparación entre equipos
  Future<Map<String, dynamic>> generarReporteComparacion(
    String periodoId,
    String actividadId,
  ) async {
    try {
      final evaluaciones = await _individualRepository
          .getEvaluacionesPorPeriodo(periodoId);
      final equiposInfo = await _obtenerInformacionEquipos(actividadId);
      final participacion = await obtenerParticipacionPorEquipo(
        periodoId,
        actividadId,
      );

      // Calcular promedios por equipo
      final promediosPorEquipo = <String, double>{};
      for (final equipoInfo in equiposInfo) {
        final equipoId = equipoInfo['id'] as String;
        final evaluacionesEquipo = evaluaciones
            .where((e) => e.equipoId == equipoId && e.completada)
            .toList();

        if (evaluacionesEquipo.isNotEmpty) {
          final promedios = evaluacionesEquipo
              .map((e) => _calcularPromedioEvaluacion(e))
              .toList();
          final promedioEquipo =
              promedios.reduce((a, b) => a + b) / promedios.length;
          promediosPorEquipo[equipoId] = promedioEquipo;
        } else {
          promediosPorEquipo[equipoId] = 0.0;
        }
      }

      // Ranking de equipos
      final ranking = promediosPorEquipo.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      return {
        'equipos': equiposInfo,
        'promediosPorEquipo': promediosPorEquipo,
        'participacion': participacion,
        'ranking': ranking.map((entry) {
          final equipoInfo = equiposInfo.firstWhere(
            (equipo) => equipo['id'] == entry.key,
            orElse: () => {'nombre': 'Equipo desconocido'},
          );
          return {
            'equipoId': entry.key,
            'equipoNombre': equipoInfo['nombre'],
            'promedio': entry.value,
            'nivel': _obtenerNivelPorPromedio(entry.value),
          };
        }).toList(),
      };
    } catch (e) {
      print('❌ [ANALISIS] Error generando reporte de comparación: $e');
      rethrow;
    }
  }
}
