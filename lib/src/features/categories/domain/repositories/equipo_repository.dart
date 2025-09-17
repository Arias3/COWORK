import '../entities/equipo_entity.dart';

abstract class EquipoRepository {
  Future<List<Equipo>> getEquiposPorCategoria(int categoriaId);
  Future<Equipo?> getEquipoById(int id);
  Future<Equipo?> getEquipoPorEstudiante(int estudianteId, int categoriaId);
  Future<int> createEquipo(Equipo equipo);
  Future<void> updateEquipo(Equipo equipo);
  Future<void> deleteEquipo(int id);
  Future<void> deleteEquiposPorCategoria(int categoriaId);
}