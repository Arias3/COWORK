import '../../domain/entities/categoria_equipo_entity.dart';
import '../../domain/repositories/categoria_equipo_repository.dart';
import '../../../../../core/data/database/hive_helper.dart';

class CategoriaEquipoRepositoryImpl implements CategoriaEquipoRepository {
  @override
  Future<List<CategoriaEquipo>> getCategoriasPorCurso(int cursoId) async {
    final box = HiveHelper.categoriasEquipoBoxInstance;
    return box.values.where((categoria) => categoria.cursoId == cursoId).toList();
  }

  @override
  Future<CategoriaEquipo?> getCategoriaById(int id) async {
    final box = HiveHelper.categoriasEquipoBoxInstance;
    return box.get(id);
  }

  @override
  Future<int> createCategoria(CategoriaEquipo categoria) async {
    final box = HiveHelper.categoriasEquipoBoxInstance;
    final id = box.length + 1;
    categoria.id = id;
    await box.put(id, categoria);
    await box.flush();
    return id;
  }

  @override
  Future<void> updateCategoria(CategoriaEquipo categoria) async {
    final box = HiveHelper.categoriasEquipoBoxInstance;
    await box.put(categoria.id, categoria);
    await box.flush();
  }

  @override
  Future<void> deleteCategoria(int id) async {
    final box = HiveHelper.categoriasEquipoBoxInstance;
    await box.delete(id);
    await box.flush();
    
    // Eliminar equipos relacionados
    final equiposBox = HiveHelper.equiposBoxInstance;
    final equiposAEliminar = equiposBox.values
        .where((equipo) => equipo.categoriaId == id)
        .map((equipo) => equipo.id)
        .toList();
    
    for (var equipoId in equiposAEliminar) {
      await equiposBox.delete(equipoId);
    }
    await equiposBox.flush();
  }
}