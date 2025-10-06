import '../entities/categoria_equipo_entity.dart';

abstract class CategoriaEquipoRepository {
  Future<List<CategoriaEquipo>> getCategoriasPorCurso(int cursoId);
  Future<CategoriaEquipo?> getCategoriaById(int id);
  Future<int> createCategoria(CategoriaEquipo categoria);
  Future<void> updateCategoria(CategoriaEquipo categoria);
  Future<void> deleteCategoria(int id);
}