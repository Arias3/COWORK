import '../entities/evaluacion_individual.dart';
import '../entities/criterios_evaluacion.dart';
import '../repositories/evaluacion_individual_repository.dart';
import '../repositories/evaluacion_periodo_repository.dart';

class EvaluacionIndividualUseCase {
  final EvaluacionIndividualRepository _repository;
  final EvaluacionPeriodoRepository _periodoRepository;

  EvaluacionIndividualUseCase(this._repository, this._periodoRepository);

  Future<List<EvaluacionIndividual>> getEvaluacionesPorPeriodo(
    String evaluacionPeriodoId,
  ) async {
    return await _repository.getEvaluacionesPorPeriodo(evaluacionPeriodoId);
  }

  Future<List<EvaluacionIndividual>> getEvaluacionesPorEvaluador(
    String evaluadorId,
  ) async {
    return await _repository.getEvaluacionesPorEvaluador(evaluadorId);
  }

  Future<List<EvaluacionIndividual>> getEvaluacionesPorEvaluado(
    String evaluadoId,
  ) async {
    return await _repository.getEvaluacionesPorEvaluado(evaluadoId);
  }

  Future<List<EvaluacionIndividual>> getEvaluacionesPorEquipo(
    String equipoId,
  ) async {
    return await _repository.getEvaluacionesPorEquipo(equipoId);
  }

  Future<EvaluacionIndividual?> getEvaluacionById(String id) async {
    return await _repository.getEvaluacionById(id);
  }

  Future<EvaluacionIndividual?> getEvaluacionEspecifica(
    String evaluacionPeriodoId,
    String evaluadorId,
    String evaluadoId,
  ) async {
    return await _repository.getEvaluacionEspecifica(
      evaluacionPeriodoId,
      evaluadorId,
      evaluadoId,
    );
  }

  Future<EvaluacionIndividual> crearEvaluacion({
    required String evaluacionPeriodoId,
    required String evaluadorId,
    required String evaluadoId,
    required String equipoId,
    Map<String, double>? calificacionesIniciales,
    String? comentarios,
  }) async {
    try {
      print('🔄 [EVAL-USECASE] Iniciando crearEvaluacion');
      print('🔄 [EVAL-USECASE] Parámetros:');
      print('   - evaluacionPeriodoId: $evaluacionPeriodoId');
      print('   - evaluadorId: $evaluadorId');
      print('   - evaluadoId: $evaluadoId');
      print('   - equipoId: $equipoId');
      print('   - calificacionesIniciales: $calificacionesIniciales');
      print('   - comentarios: $comentarios');

      final evaluacion = EvaluacionIndividual(
        id: '', // Se generará automáticamente en el repositorio
        evaluacionPeriodoId: evaluacionPeriodoId,
        evaluadorId: evaluadorId,
        evaluadoId: evaluadoId,
        equipoId: equipoId,
        calificaciones: calificacionesIniciales ?? {},
        comentarios: comentarios,
        fechaCreacion: DateTime.now(),
        completada: false,
      );

      print(
        '✅ [EVAL-USECASE] Entidad EvaluacionIndividual creada, enviando al repositorio...',
      );
      final resultado = await _repository.crearEvaluacion(evaluacion);
      print(
        '✅ [EVAL-USECASE] Evaluación creada exitosamente en repositorio: ${resultado.id}',
      );

      return resultado;
    } catch (e) {
      print('❌ [EVAL-USECASE] ERROR en crearEvaluacion: $e');
      print('❌ [EVAL-USECASE] TIPO DE ERROR: ${e.runtimeType}');
      print('❌ [EVAL-USECASE] STACK TRACE: ${StackTrace.current}');
      rethrow;
    }
  }

  Future<EvaluacionIndividual> actualizarCalificacion(
    String evaluacionId,
    CriterioEvaluacion criterio,
    double calificacion,
  ) async {
    final evaluacion = await _repository.getEvaluacionById(evaluacionId);
    if (evaluacion == null) {
      throw Exception('Evaluación no encontrada');
    }

    // Validar calificación
    if (calificacion < 1.0 || calificacion > 5.0) {
      throw Exception('La calificación debe estar entre 1.0 y 5.0');
    }

    final nuevasCalificaciones = Map<String, double>.from(
      evaluacion.calificaciones,
    );
    nuevasCalificaciones[criterio.key] = calificacion;

    final evaluacionActualizada = evaluacion.copyWith(
      calificaciones: nuevasCalificaciones,
      fechaActualizacion: DateTime.now(),
    );

    return await _repository.actualizarEvaluacion(evaluacionActualizada);
  }

  Future<EvaluacionIndividual> actualizarComentarios(
    String evaluacionId,
    String comentarios,
  ) async {
    final evaluacion = await _repository.getEvaluacionById(evaluacionId);
    if (evaluacion == null) {
      throw Exception('Evaluación no encontrada');
    }

    final evaluacionActualizada = evaluacion.copyWith(
      comentarios: comentarios,
      fechaActualizacion: DateTime.now(),
    );

    return await _repository.actualizarEvaluacion(evaluacionActualizada);
  }

  Future<EvaluacionIndividual> completarEvaluacion(String evaluacionId) async {
    final evaluacion = await _repository.getEvaluacionById(evaluacionId);
    if (evaluacion == null) {
      throw Exception('Evaluación no encontrada');
    }

    // Verificar que tenga al menos una calificación
    if (evaluacion.calificaciones.isEmpty) {
      throw Exception('La evaluación debe tener al menos una calificación');
    }

    final evaluacionActualizada = evaluacion.copyWith(
      completada: true,
      fechaActualizacion: DateTime.now(),
    );

    return await _repository.actualizarEvaluacion(evaluacionActualizada);
  }

  Future<EvaluacionIndividual> actualizarEvaluacionCompleta({
    required String evaluacionId,
    required Map<CriterioEvaluacion, double> calificaciones,
    String? comentarios,
    bool completar = false,
  }) async {
    final evaluacion = await _repository.getEvaluacionById(evaluacionId);
    if (evaluacion == null) {
      throw Exception('Evaluación no encontrada');
    }

    // Validar calificaciones
    for (final entry in calificaciones.entries) {
      if (entry.value < 1.0 || entry.value > 5.0) {
        throw Exception('Las calificaciones deben estar entre 1.0 y 5.0');
      }
    }

    // Convertir criterios a strings
    final nuevasCalificaciones = <String, double>{};
    calificaciones.forEach((criterio, calificacion) {
      nuevasCalificaciones[criterio.key] = calificacion;
    });

    final evaluacionActualizada = evaluacion.copyWith(
      calificaciones: nuevasCalificaciones,
      comentarios: comentarios,
      completada: completar,
      fechaActualizacion: DateTime.now(),
    );

    return await _repository.actualizarEvaluacion(evaluacionActualizada);
  }

  Future<bool> eliminarEvaluacion(String id) async {
    return await _repository.eliminarEvaluacion(id);
  }

  Future<List<EvaluacionIndividual>> getEvaluacionesCompletadas(
    String evaluacionPeriodoId,
  ) async {
    return await _repository.getEvaluacionesCompletadas(evaluacionPeriodoId);
  }

  Future<List<EvaluacionIndividual>> getEvaluacionesPendientes(
    String evaluadorId,
    String evaluacionPeriodoId,
  ) async {
    return await _repository.getEvaluacionesPendientes(
      evaluadorId,
      evaluacionPeriodoId,
    );
  }

  Future<Map<String, double>> getPromedioEvaluacionesPorUsuario(
    String evaluadoId,
    String evaluacionPeriodoId,
  ) async {
    return await _repository.getPromedioEvaluacionesPorUsuario(
      evaluadoId,
      evaluacionPeriodoId,
    );
  }

  Future<Map<String, dynamic>> getEstadisticasEvaluaciones(
    String evaluacionPeriodoId,
  ) async {
    final todasLasEvaluaciones = await _repository.getEvaluacionesPorPeriodo(
      evaluacionPeriodoId,
    );
    final evaluacionesCompletadas = todasLasEvaluaciones
        .where((e) => e.completada)
        .toList();

    if (todasLasEvaluaciones.isEmpty) {
      return {
        'total': 0,
        'completadas': 0,
        'pendientes': 0,
        'porcentajeCompletado': 0.0,
        'promedioGeneral': 0.0,
      };
    }

    final total = todasLasEvaluaciones.length;
    final completadas = evaluacionesCompletadas.length;
    final pendientes = total - completadas;
    final porcentajeCompletado = (completadas / total) * 100;

    // Calcular promedio general de calificaciones
    double promedioGeneral = 0.0;
    if (evaluacionesCompletadas.isNotEmpty) {
      final promedios = evaluacionesCompletadas
          .map((e) => e.promedioCalificaciones)
          .toList();
      promedioGeneral = promedios.reduce((a, b) => a + b) / promedios.length;
    }

    return {
      'total': total,
      'completadas': completadas,
      'pendientes': pendientes,
      'porcentajeCompletado': porcentajeCompletado,
      'promedioGeneral': promedioGeneral,
    };
  }

  Future<bool> puedeEvaluar(
    String evaluadorId,
    String evaluadoId,
    String evaluacionPeriodoId,
  ) async {
    // Obtener el período de evaluación para verificar la configuración
    final periodo = await _periodoRepository.getEvaluacionPeriodoById(
      evaluacionPeriodoId,
    );
    if (periodo == null) {
      return false;
    }

    // Si el evaluador y evaluado son la misma persona (auto-evaluación)
    if (evaluadorId == evaluadoId) {
      // Solo permitir si está habilitada la auto-evaluación
      return periodo.permitirAutoEvaluacion;
    }

    // Verificar si ya existe una evaluación
    final evaluacionExistente = await _repository.getEvaluacionEspecifica(
      evaluacionPeriodoId,
      evaluadorId,
      evaluadoId,
    );

    // Si existe y está completada, no puede evaluar de nuevo
    if (evaluacionExistente != null && evaluacionExistente.completada) {
      return !evaluacionExistente.puedeSerEditada();
    }

    return true;
  }

  Future<List<String>> getUsuariosPendientesPorEvaluar(
    String evaluadorId,
    String evaluacionPeriodoId,
    List<String> posiblesEvaluados,
  ) async {
    final List<String> pendientes = [];

    for (final evaluadoId in posiblesEvaluados) {
      if (evaluadorId != evaluadoId) {
        final evaluacion = await _repository.getEvaluacionEspecifica(
          evaluacionPeriodoId,
          evaluadorId,
          evaluadoId,
        );

        if (evaluacion == null || !evaluacion.completada) {
          pendientes.add(evaluadoId);
        }
      }
    }

    return pendientes;
  }

  /// Genera automáticamente todas las evaluaciones individuales para un periodo dado
  /// Crea evaluaciones de cada miembro del equipo hacia todos los demás miembros
  Future<List<EvaluacionIndividual>> generarEvaluacionesParaPeriodo({
    required String evaluacionPeriodoId,
    required String equipoId,
    required List<String> miembrosEquipo,
  }) async {
    print(
      '🔄 [EVAL-USECASE] Generando evaluaciones para periodo: $evaluacionPeriodoId',
    );
    print(
      '🔄 [EVAL-USECASE] Equipo: $equipoId, Miembros: ${miembrosEquipo.length}',
    );

    final List<EvaluacionIndividual> evaluacionesGeneradas = [];

    try {
      // Obtener el período de evaluación para verificar configuración
      final periodo = await _periodoRepository.getEvaluacionPeriodoById(
        evaluacionPeriodoId,
      );
      if (periodo == null) {
        print(
          '❌ [EVAL-USECASE] Período de evaluación no encontrado: $evaluacionPeriodoId',
        );
        return evaluacionesGeneradas;
      }

      print('🔍 [EVAL-USECASE] Configuración del período:');
      print('   - Evaluación entre pares: ${periodo.evaluacionEntrePares}');
      print('   - Permitir auto-evaluación: ${periodo.permitirAutoEvaluacion}');

      // Para cada miembro del equipo
      for (final evaluadorId in miembrosEquipo) {
        // Evalúa a todos los miembros según la configuración
        for (final evaluadoId in miembrosEquipo) {
          // Determinar si debe crear esta evaluación
          bool debeCrearEvaluacion = false;

          if (evaluadorId == evaluadoId) {
            // Auto-evaluación: solo si está permitida
            debeCrearEvaluacion = periodo.permitirAutoEvaluacion;
            if (debeCrearEvaluacion) {
              print(
                '✅ [EVAL-USECASE] Auto-evaluación permitida: $evaluadorId → $evaluadoId',
              );
            } else {
              print(
                '⏭️ [EVAL-USECASE] Auto-evaluación NO permitida: $evaluadorId → $evaluadoId',
              );
            }
          } else {
            // Evaluación entre pares: solo si está permitida
            debeCrearEvaluacion = periodo.evaluacionEntrePares;
            if (debeCrearEvaluacion) {
              print(
                '✅ [EVAL-USECASE] Evaluación entre pares permitida: $evaluadorId → $evaluadoId',
              );
            } else {
              print(
                '⏭️ [EVAL-USECASE] Evaluación entre pares NO permitida: $evaluadorId → $evaluadoId',
              );
            }
          }

          if (debeCrearEvaluacion) {
            // Verificar si ya existe la evaluación
            final evaluacionExistente = await _repository
                .getEvaluacionEspecifica(
                  evaluacionPeriodoId,
                  evaluadorId,
                  evaluadoId,
                );

            if (evaluacionExistente == null) {
              print(
                '✅ [EVAL-USECASE] Creando evaluación: $evaluadorId → $evaluadoId',
              );

              // Crear nueva evaluación
              final nuevaEvaluacion = await crearEvaluacion(
                evaluacionPeriodoId: evaluacionPeriodoId,
                evaluadorId: evaluadorId,
                evaluadoId: evaluadoId,
                equipoId: equipoId,
              );

              evaluacionesGeneradas.add(nuevaEvaluacion);
            } else {
              print(
                'ℹ️ [EVAL-USECASE] Evaluación ya existe: $evaluadorId → $evaluadoId',
              );
            }
          }
        }
      }

      print(
        '✅ [EVAL-USECASE] Generadas ${evaluacionesGeneradas.length} nuevas evaluaciones',
      );
      return evaluacionesGeneradas;
    } catch (e) {
      print('❌ [EVAL-USECASE] Error generando evaluaciones: $e');
      throw Exception('Error al generar evaluaciones: $e');
    }
  }
}
