import '../../domain/entities/equipo_entity.dart';
import '../../domain/repositories/equipo_repository.dart';
import '../../../../../core/data/database/hive_helper.dart';

class EquipoRepositoryImpl implements EquipoRepository {
  @override
  Future<List<Equipo>> getEquiposPorCategoria(int categoriaId) async {
    final box = HiveHelper.equiposBoxInstance;
    return box.values.where((equipo) => equipo.categoriaId == categoriaId).toList();
  }

  @override
  Future<Equipo?> getEquipoById(int id) async {
    final box = HiveHelper.equiposBoxInstance;
    return box.get(id);
  }

  @override
  Future<Equipo?> getEquipoPorEstudiante(int estudianteId, int categoriaId) async {
    final box = HiveHelper.equiposBoxInstance;
    try {
      return box.values.firstWhere(
        (equipo) => equipo.categoriaId == categoriaId && 
                   equipo.estudiantesIds.contains(estudianteId)
      );
    } catch (e) {
      return null;
    }
  }

  @override
  Future<int> createEquipo(Equipo equipo) async {
    final box = HiveHelper.equiposBoxInstance;
    final id = box.length + 1;
    equipo.id = id;
    await box.put(id, equipo);
    await box.flush();
    return id;
  }

  @override
  Future<void> updateEquipo(Equipo equipo) async {
    final box = HiveHelper.equiposBoxInstance;
    await box.put(equipo.id, equipo);
    await box.flush();
  }

  @override
  Future<void> deleteEquipo(int id) async {
    final box = HiveHelper.equiposBoxInstance;
    await box.delete(id);
    await box.flush();
  }

  @override
  Future<void> deleteEquiposPorCategoria(int categoriaId) async {
    final box = HiveHelper.equiposBoxInstance;
    final equiposAEliminar = box.values
        .where((equipo) => equipo.categoriaId == categoriaId)
        .map((equipo) => equipo.id)
        .toList();
    
    for (var equipoId in equiposAEliminar) {
      await box.delete(equipoId);
    }
    await box.flush();
  }
}