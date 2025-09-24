import '../entities/equipo_actividad_entity.dart';

abstract class EquipoActividadRepository {
  Future<List<EquipoActividad>> getAll();
  Future<List<EquipoActividad>> getByEquipoId(int equipoId);
  Future<List<EquipoActividad>> getByActividadId(String actividadId);
  Future<EquipoActividad?> getByEquipoAndActividad(
    int equipoId,
    String actividadId,
  );
  Future<int> create(EquipoActividad asignacion);
  Future<void> update(EquipoActividad asignacion);
  Future<void> delete(int id);
  Future<void> deleteByEquipoId(int equipoId);
  Future<void> deleteByActividadId(String actividadId);
}
