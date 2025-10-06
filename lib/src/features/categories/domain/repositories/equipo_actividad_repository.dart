import '../entities/equipo_actividad_entity.dart';

abstract class EquipoActividadRepository {
  Future<List<EquipoActividad>> getAll();
  Future<List<EquipoActividad>> getByEquipoId(int equipoId);
  Future<List<EquipoActividad>> getByActividadId(String actividadId);
  Future<EquipoActividad?> getByEquipoAndActividad(
    int equipoId,
    String actividadId,
  );
  Future<EquipoActividad> create(EquipoActividad equipoActividad);
  Future<EquipoActividad> update(EquipoActividad equipoActividad);
  Future<void> delete(String id); // String para Roble ObjectId
  Future<void> deleteByEquipoId(int equipoId);
  Future<void> deleteByActividadId(String actividadId);
}
