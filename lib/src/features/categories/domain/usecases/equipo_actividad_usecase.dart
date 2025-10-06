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
    try {
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
          print('✅ Actividad $actividadId asignada al equipo $equipoId');
        } else {
          print(
            'ℹ️ Equipo $equipoId ya tiene asignada la actividad $actividadId',
          );
        }
      }
    } catch (e) {
      print('❌ Error asignando actividad a equipos: $e');
      throw Exception('Error al asignar actividad: $e');
    }
  }

  Future<void> removerAsignacion(int equipoId, String actividadId) async {
    try {
      final asignacion = await _repository.getByEquipoAndActividad(
        equipoId,
        actividadId,
      );
      if (asignacion?.id != null) {
        await _repository.delete(asignacion!.id!);
        print(
          '✅ Asignación removida: equipo $equipoId - actividad $actividadId',
        );
      }
    } catch (e) {
      print('❌ Error removiendo asignación: $e');
      throw Exception('Error al remover asignación: $e');
    }
  }

  Future<void> actualizarEstadoAsignacion(
    int equipoId,
    String actividadId,
    String nuevoEstado, {
    double? calificacion,
    String? comentario,
  }) async {
    try {
      final asignacion = await _repository.getByEquipoAndActividad(
        equipoId,
        actividadId,
      );
      if (asignacion != null) {
        final asignacionActualizada = asignacion.copyWith(
          estado: nuevoEstado,
          calificacion: calificacion,
          comentarioProfesor: comentario,
          fechaCompletada: nuevoEstado == 'completada' ? DateTime.now() : null,
        );
        await _repository.update(asignacionActualizada);
        print('✅ Estado actualizado: $nuevoEstado para equipo $equipoId');
      }
    } catch (e) {
      print('❌ Error actualizando estado: $e');
      throw Exception('Error al actualizar estado: $e');
    }
  }

  Future<void> eliminarAsignacionesPorActividad(String actividadId) async {
    try {
      await _repository.deleteByActividadId(actividadId);
      print('✅ Eliminadas todas las asignaciones de la actividad $actividadId');
    } catch (e) {
      print('❌ Error eliminando asignaciones por actividad: $e');
      throw Exception('Error al eliminar asignaciones: $e');
    }
  }

  Future<void> eliminarAsignacionesPorEquipo(int equipoId) async {
    try {
      await _repository.deleteByEquipoId(equipoId);
      print('✅ Eliminadas todas las asignaciones del equipo $equipoId');
    } catch (e) {
      print('❌ Error eliminando asignaciones por equipo: $e');
      throw Exception('Error al eliminar asignaciones: $e');
    }
  }

  Future<List<EquipoActividad>> getAsignacionesPendientes() async {
    try {
      final todas = await _repository.getAll();
      return todas.where((a) => a.estado == 'pendiente').toList();
    } catch (e) {
      print('❌ Error obteniendo asignaciones pendientes: $e');
      return [];
    }
  }

  Future<List<EquipoActividad>> getAsignacionesVencidas() async {
    try {
      final todas = await _repository.getAll();
      final ahora = DateTime.now();
      return todas
          .where(
            (a) =>
                a.estado != 'completada' &&
                a.fechaEntrega != null &&
                a.fechaEntrega!.isBefore(ahora),
          )
          .toList();
    } catch (e) {
      print('❌ Error obteniendo asignaciones vencidas: $e');
      return [];
    }
  }
}
