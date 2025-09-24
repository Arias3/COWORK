import 'package:hive/hive.dart';
import '../../domain/entities/equipo_actividad_entity.dart';
import '../../domain/repositories/equipo_actividad_repository.dart';

class EquipoActividadRepositoryImpl implements EquipoActividadRepository {
  static const String boxName = 'equipo_actividad_box';
  Box<EquipoActividad>? _box;

  Future<Box<EquipoActividad>> get box async {
    _box ??= await Hive.openBox<EquipoActividad>(boxName);
    return _box!;
  }

  @override
  Future<List<EquipoActividad>> getAll() async {
    final b = await box;
    return b.values.toList();
  }

  @override
  Future<List<EquipoActividad>> getByEquipoId(int equipoId) async {
    final b = await box;
    return b.values
        .where((asignacion) => asignacion.equipoId == equipoId)
        .toList();
  }

  @override
  Future<List<EquipoActividad>> getByActividadId(String actividadId) async {
    final b = await box;
    return b.values
        .where((asignacion) => asignacion.actividadId == actividadId)
        .toList();
  }

  @override
  Future<EquipoActividad?> getByEquipoAndActividad(
    int equipoId,
    String actividadId,
  ) async {
    final b = await box;
    try {
      return b.values.firstWhere(
        (asignacion) =>
            asignacion.equipoId == equipoId &&
            asignacion.actividadId == actividadId,
      );
    } catch (e) {
      return null;
    }
  }

  @override
  Future<int> create(EquipoActividad asignacion) async {
    final b = await box;
    final id = await b.add(asignacion);
    asignacion.id = id;
    await asignacion.save();
    return id;
  }

  @override
  Future<void> update(EquipoActividad asignacion) async {
    await asignacion.save();
  }

  @override
  Future<void> delete(int id) async {
    final b = await box;
    await b.delete(id);
  }

  @override
  Future<void> deleteByEquipoId(int equipoId) async {
    final b = await box;
    final asignaciones = await getByEquipoId(equipoId);
    for (final asignacion in asignaciones) {
      if (asignacion.id != null) {
        await b.delete(asignacion.id);
      }
    }
  }

  @override
  Future<void> deleteByActividadId(String actividadId) async {
    final b = await box;
    final asignaciones = await getByActividadId(actividadId);
    for (final asignacion in asignaciones) {
      if (asignacion.id != null) {
        await b.delete(asignacion.id);
      }
    }
  }
}
