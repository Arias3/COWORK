import '../entities/evaluacion_periodo.dart';
import '../entities/evaluacion_individual.dart';
import '../entities/criterios_evaluacion.dart';
import '../repositories/i_evaluacion_repository.dart';
import '../../../categories/domain/usecases/categoria_equipo_usecase.dart';
import '../../../categories/domain/usecases/equipo_actividad_usecase.dart';
import '../../../auth/domain/repositories/usuario_repository.dart';
import '../../../auth/domain/entities/user_entity.dart';

class EvaluacionUseCase {
  final IEvaluacionRepository _repository;
  final CategoriaEquipoUseCase _equipoUseCase;
  final EquipoActividadUseCase _equipoActividadUseCase;
  final UsuarioRepository _usuarioRepository;

  EvaluacionUseCase(
    this._repository,
    this._equipoUseCase,
    this._equipoActividadUseCase,
    this._usuarioRepository,
  );

  // ========================== PERÍODOS DE EVALUACIÓN ==========================

  Future<String> crearPeriodoEvaluacion({
    required String actividadId,
    required String titulo,
    String? descripcion,
    required String profesorId,
    DateTime? fechaInicio,
    int? duracionMaximaHoras,
    bool permitirAutoEvaluacion = false,
  }) async {
    final periodo = EvaluacionPeriodo.nueva(
      actividadId: actividadId,
      titulo: titulo,
      descripcion: descripcion,
      profesorId: profesorId,
      fechaInicio: fechaInicio,
      duracionMaximaHoras: duracionMaximaHoras,
      permitirAutoEvaluacion: permitirAutoEvaluacion,
    );

    await _repository.guardarEvaluacionPeriodo(periodo);
    return periodo.id;
  }

  Future<void> iniciarEvaluacion(String periodoId) async {
    print('🔥 EvaluacionUseCase: Iniciando evaluación con ID: $periodoId');
    final periodo = await _repository.obtenerEvaluacionPeriodo(periodoId);
    if (periodo != null) {
      print('✅ Período encontrado: ${periodo.titulo}');
      print('   - Estado actual: ${periodo.estado}');
      print('   - Actividad ID: ${periodo.actividadId}');

      periodo.iniciarEvaluacion();
      await _repository.actualizarEvaluacionPeriodo(periodo);
      print('✅ Estado actualizado a: ${periodo.estado}');

      // Crear evaluaciones individuales vacías para todos los estudiantes de los equipos
      print('🔄 Creando evaluaciones individuales...');
      await _crearEvaluacionesIndividualesParaPeriodo(periodo);
      print('✅ Evaluaciones individuales creadas');
    } else {
      print('❌ No se encontró el período con ID: $periodoId');
    }
  }

  Future<void> finalizarEvaluacion(String periodoId) async {
    final periodo = await _repository.obtenerEvaluacionPeriodo(periodoId);
    if (periodo != null) {
      periodo.finalizarEvaluacion();
      await _repository.actualizarEvaluacionPeriodo(periodo);
    }
  }

  Future<void> eliminarPeriodoEvaluacion(String periodoId) async {
    // Primero eliminar todas las evaluaciones individuales relacionadas
    await _repository.eliminarEvaluacionesIndividualesPorPeriodo(periodoId);

    // Luego eliminar el período de evaluación
    await _repository.eliminarEvaluacionPeriodo(periodoId);
  }

  Future<List<EvaluacionPeriodo>> obtenerEvaluacionesPorActividad(
    String actividadId,
  ) {
    return _repository.obtenerEvaluacionesPorActividad(actividadId);
  }

  Future<EvaluacionPeriodo?> obtenerEvaluacionPeriodo(String periodoId) {
    return _repository.obtenerEvaluacionPeriodo(periodoId);
  }

  // ========================== EVALUACIONES INDIVIDUALES ==========================

  Future<List<EvaluacionIndividual>> obtenerEvaluacionesPendientesPorEvaluador(
    String evaluadorId,
    String periodoId,
  ) {
    return _repository.obtenerEvaluacionesPorEvaluador(evaluadorId, periodoId);
  }

  Future<void> guardarEvaluacionIndividual({
    required String periodoId,
    required String evaluadorId,
    required String evaluadoId,
    required String equipoId,
    required Map<CriterioEvaluacion, NivelEvaluacion> calificaciones,
    String? comentarios,
  }) async {
    // Buscar evaluación existente
    var evaluacion = await _repository.obtenerEvaluacionEspecifica(
      evaluadorId,
      evaluadoId,
      periodoId,
    );

    if (evaluacion == null) {
      // Crear nueva evaluación
      evaluacion = EvaluacionIndividual.nueva(
        evaluacionPeriodoId: periodoId,
        evaluadorId: evaluadorId,
        evaluadoId: evaluadoId,
        equipoId: equipoId,
      );
    }

    // Actualizar calificaciones
    calificaciones.forEach((criterio, nivel) {
      evaluacion!.setCalificacionPorCriterio(criterio, nivel);
    });

    // Actualizar comentarios
    if (comentarios != null) {
      evaluacion.comentarios = comentarios;
    }

    // Verificar y marcar como completada si todas las calificaciones están presentes
    if (evaluacion.esCompleta) {
      evaluacion.completarEvaluacion();
    }

    await _repository.actualizarEvaluacionIndividual(evaluacion);
  }

  Future<List<EvaluacionIndividual>> obtenerMisEvaluacionesPendientes(
    String evaluadorId,
    String periodoId,
  ) async {
    final evaluaciones = await _repository.obtenerEvaluacionesPorEvaluador(
      evaluadorId,
      periodoId,
    );
    return evaluaciones.where((eval) => !eval.completada).toList();
  }

  Future<List<EvaluacionIndividual>> obtenerMisEvaluaciones(
    String evaluadorId,
    String periodoId,
  ) async {
    return _repository.obtenerEvaluacionesPorEvaluador(evaluadorId, periodoId);
  }

  // ========================== ANÁLISIS Y REPORTES ==========================

  Future<Map<String, double>> obtenerPromediosPorEstudiante(String periodoId) {
    return _repository.obtenerPromediosPorEstudiante(periodoId);
  }

  Future<Map<String, double>> obtenerPromediosPorEquipo(String periodoId) {
    return _repository.obtenerPromediosPorEquipo(periodoId);
  }

  Future<Map<String, dynamic>> obtenerEstadisticasEvaluacion(
    String periodoId,
  ) async {
    final completadas = await _repository.contarEvaluacionesCompletadas(
      periodoId,
    );
    final pendientes = await _repository.contarEvaluacionesPendientes(
      periodoId,
    );
    final total = completadas + pendientes;

    return {
      'completadas': completadas,
      'pendientes': pendientes,
      'total': total,
      'porcentajeCompletado': total > 0 ? (completadas / total) * 100 : 0.0,
    };
  }

  Future<List<Map<String, dynamic>>> obtenerDetalleEvaluacionesPorEstudiante(
    String periodoId,
    String estudianteId,
  ) async {
    final evaluaciones = await _repository.obtenerEvaluacionesPorEvaluado(
      estudianteId,
      periodoId,
    );

    final List<Map<String, dynamic>> detalles = [];

    for (final evaluacion in evaluaciones) {
      if (evaluacion.completada) {
        final detallesPorCriterio = <String, dynamic>{};

        for (final criterio in CriterioEvaluacion.values) {
          final calificacion = evaluacion.getCalificacionPorCriterio(criterio);
          detallesPorCriterio[criterio.nombre] = {
            'calificacion': calificacion,
            'nivel': _obtenerNivelPorCalificacion(calificacion).nombre,
          };
        }

        detalles.add({
          'evaluadorId': evaluacion.evaluadorId,
          'promedioGeneral': evaluacion.promedioGeneral,
          'criterios': detallesPorCriterio,
          'comentarios': evaluacion.comentarios,
          'fechaEvaluacion':
              evaluacion.fechaActualizacion ?? evaluacion.fechaCreacion,
        });
      }
    }

    return detalles;
  }

  // ========================== MÉTODOS PRIVADOS ==========================

  Future<void> _crearEvaluacionesIndividualesParaPeriodo(
    EvaluacionPeriodo periodo,
  ) async {
    print(
      '📊 Creando evaluaciones individuales para período: ${periodo.titulo}',
    );
    // Obtener asignaciones de equipos a la actividad
    final asignaciones = await _equipoActividadUseCase
        .getAsignacionesByActividad(periodo.actividadId);

    print('   📋 Asignaciones encontradas: ${asignaciones.length}');

    for (final asignacion in asignaciones) {
      print('   🎯 Procesando equipo: ${asignacion.equipoId}');
      // Obtener el equipo completo
      final equipo = await _equipoUseCase.getEquipoById(asignacion.equipoId);
      if (equipo == null) {
        print('   ❌ Equipo no encontrado: ${asignacion.equipoId}');
        continue;
      }

      print(
        '   ✅ Equipo encontrado: ${equipo.nombre} con ${equipo.estudiantesIds.length} estudiantes',
      );

      // Obtener usuarios miembros del equipo
      final miembrosUsuarios = <Usuario>[];
      for (final estudianteId in equipo.estudiantesIds) {
        final usuario = await _usuarioRepository.getUsuarioById(estudianteId);
        if (usuario != null) {
          miembrosUsuarios.add(usuario);
          print(
            '   👤 Miembro encontrado: ${usuario.nombre} (${usuario.email})',
          );
        } else {
          print('   ❌ Usuario no encontrado: $estudianteId');
        }
      }

      print('   👥 Total miembros activos: ${miembrosUsuarios.length}');

      // Crear evaluaciones cruzadas entre todos los miembros del equipo
      int evaluacionesCreadas = 0;
      for (final evaluador in miembrosUsuarios) {
        for (final evaluado in miembrosUsuarios) {
          // Evitar auto-evaluación si no está permitida
          if (evaluador.id == evaluado.id && !periodo.permitirAutoEvaluacion) {
            print(
              '   ⏭️  Saltando auto-evaluación: ${evaluador.nombre} -> ${evaluado.nombre}',
            );
            continue;
          }

          // Verificar que no exista ya una evaluación
          final existente = await _repository.obtenerEvaluacionEspecifica(
            evaluador.id!.toString(),
            evaluado.id!.toString(),
            periodo.id,
          );

          if (existente == null) {
            final evaluacionIndividual = EvaluacionIndividual.nueva(
              evaluacionPeriodoId: periodo.id,
              evaluadorId: evaluador.id!.toString(),
              evaluadoId: evaluado.id!.toString(),
              equipoId: equipo.id.toString(),
            );

            await _repository.guardarEvaluacionIndividual(evaluacionIndividual);
            evaluacionesCreadas++;
            print(
              '   ✅ Evaluación creada: ${evaluador.nombre} -> ${evaluado.nombre}',
            );
          } else {
            print(
              '   ⚠️  Evaluación ya existente: ${evaluador.nombre} -> ${evaluado.nombre}',
            );
          }
        }
      }
      print(
        '   📊 Total evaluaciones creadas para equipo ${equipo.nombre}: $evaluacionesCreadas',
      );
    }
    print('✅ Todas las evaluaciones individuales fueron procesadas');
  }

  NivelEvaluacion _obtenerNivelPorCalificacion(double calificacion) {
    if (calificacion >= 5.0) return NivelEvaluacion.excelente;
    if (calificacion >= 4.0) return NivelEvaluacion.bueno;
    if (calificacion >= 3.0) return NivelEvaluacion.adecuado;
    return NivelEvaluacion.necesitaMejorar;
  }
}
