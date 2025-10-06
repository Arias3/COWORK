import '../entities/equipo_actividad_entity.dart';
import '../repositories/equipo_actividad_repository.dart';

class EquipoActividadUseCase {
  final EquipoActividadRepository _repository;

  EquipoActividadUseCase(this._repository);

  Future<List<EquipoActividad>> getAllAsignaciones() async {
    return await _repository.getAll();
  }

  Future<List<EquipoActividad>> getAsignacionesByEquipo(int equipoId) async {
    return await _repository.getByEquipoId(equipoId);
  }

  Future<List<EquipoActividad>> getAsignacionesByActividad(
    String actividadId,
  ) async {
    return await _repository.getByActividadId(actividadId);
  }

  Future<EquipoActividad?> getAsignacion(
    int equipoId,
    String actividadId,
  ) async {
    return await _repository.getByEquipoAndActividad(equipoId, actividadId);
  }

  Future<void> asignarActividadAEquipos(
    String actividadId,
    List<int> equipoIds,
    DateTime? fechaEntrega,
  ) async {
    for (int equipoId in equipoIds) {
      // Verificar si ya existe la asignación
      final existente = await _repository.getByEquipoAndActividad(
        equipoId,
        actividadId,
      );
      if (existente == null) {
        final asignacion = EquipoActividad(
          equipoId: equipoId,
          actividadId: actividadId,
          fechaEntrega: fechaEntrega,
          estado: 'pendiente',
        );
        await _repository.create(asignacion);
      }
    }
  }

  Future<void> desasignarActividadDeEquipo(
    int equipoId,
    String actividadId,
  ) async {
    final asignacion = await _repository.getByEquipoAndActividad(
      equipoId,
      actividadId,
    );
    if (asignacion != null && asignacion.id != null) {
      await _repository.delete(asignacion.id!);
    }
  }

  Future<void> actualizarEstadoAsignacion(
    int equipoId,
    String actividadId,
    String nuevoEstado,
  ) async {
    final asignacion = await _repository.getByEquipoAndActividad(
      equipoId,
      actividadId,
    );
    if (asignacion != null) {
      asignacion.estado = nuevoEstado;
      if (nuevoEstado == 'completada') {
        asignacion.fechaCompletada = DateTime.now();
      }
      await _repository.update(asignacion);
    }
  }

  Future<void> calificarAsignacion(
    int equipoId,
    String actividadId,
    double calificacion,
    String? comentario,
  ) async {
    final asignacion = await _repository.getByEquipoAndActividad(
      equipoId,
      actividadId,
    );
    if (asignacion != null) {
      asignacion.calificacion = calificacion;
      asignacion.comentarioProfesor = comentario;
      asignacion.estado = 'completada';
      asignacion.fechaCompletada = DateTime.now();
      await _repository.update(asignacion);
    }
  }

  Future<void> eliminarAsignacionesPorEquipo(int equipoId) async {
    await _repository.deleteByEquipoId(equipoId);
  }

  Future<void> eliminarAsignacionesPorActividad(String actividadId) async {
    await _repository.deleteByActividadId(actividadId);
  }

  // Método para obtener estadísticas de una actividad
  Future<Map<String, int>> getEstadisticasActividad(String actividadId) async {
    final asignaciones = await _repository.getByActividadId(actividadId);

    int pendientes = 0;
    int enProgreso = 0;
    int completadas = 0;
    int vencidas = 0;

    for (final asignacion in asignaciones) {
      switch (asignacion.estado) {
        case 'pendiente':
          if (asignacion.isVencida) {
            vencidas++;
          } else {
            pendientes++;
          }
          break;
        case 'en_progreso':
          enProgreso++;
          break;
        case 'completada':
          completadas++;
          break;
        case 'vencida':
          vencidas++;
          break;
      }
    }

    return {
      'pendientes': pendientes,
      'en_progreso': enProgreso,
      'completadas': completadas,
      'vencidas': vencidas,
      'total': asignaciones.length,
    };
  }
}
