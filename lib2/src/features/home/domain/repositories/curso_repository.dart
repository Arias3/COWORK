import '../entities/curso_entity.dart';

abstract class CursoRepository {
  Future<List<CursoDomain>> getCursos();
  Future<List<CursoDomain>> getCursosPorProfesor(int profesorId);
  Future<List<CursoDomain>> getCursosInscritos(int usuarioId);
  Future<CursoDomain?> getCursoById(int id);
  Future<CursoDomain?> getCursoByCodigoRegistro(String codigo);
  Future<int> createCurso(CursoDomain curso);
  Future<void> updateCurso(CursoDomain curso);
  Future<void> deleteCurso(int id);
}