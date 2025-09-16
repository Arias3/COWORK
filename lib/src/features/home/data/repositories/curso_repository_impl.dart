import '../../domain/entities/curso_entity.dart';
import '../../domain/repositories/curso_repository.dart';
import '../../../../../core/data/database/hive_helper.dart';

class CursoRepositoryImpl implements CursoRepository {
  @override
  Future<List<CursoDomain>> getCursos() async {
    final box = HiveHelper.cursosBoxInstance;
    return box.values.toList();
  }

  @override
  Future<List<CursoDomain>> getCursosPorProfesor(int profesorId) async {
    final box = HiveHelper.cursosBoxInstance;
    return box.values.where((curso) => curso.profesorId == profesorId).toList();
  }

  @override
  Future<List<CursoDomain>> getCursosInscritos(int usuarioId) async {
    final inscripcionesBox = HiveHelper.inscripcionesBoxInstance;
    final cursosBox = HiveHelper.cursosBoxInstance;
    
    final inscripciones = inscripcionesBox.values
        .where((inscripcion) => inscripcion.usuarioId == usuarioId)
        .toList();
    
    final cursos = <CursoDomain>[];
    for (var inscripcion in inscripciones) {
      final curso = cursosBox.get(inscripcion.cursoId);
      if (curso != null) cursos.add(curso);
    }
    
    return cursos;
  }

  @override
  Future<CursoDomain?> getCursoById(int id) async {
    final box = HiveHelper.cursosBoxInstance;
    return box.get(id);
  }

  @override
  Future<CursoDomain?> getCursoByCodigoRegistro(String codigo) async {
    final box = HiveHelper.cursosBoxInstance;
    try {
      return box.values.firstWhere(
        (curso) => curso.codigoRegistro.toLowerCase() == codigo.toLowerCase()
      );
    } catch (e) {
      return null;
    }
  }

  @override
  Future<int> createCurso(CursoDomain curso) async {
    final box = HiveHelper.cursosBoxInstance;
    final id = box.length + 1;
    curso.id = id;
    await box.put(id, curso);
    await box.flush();
    return id;
  }

  @override
  Future<void> updateCurso(CursoDomain curso) async {
    final box = HiveHelper.cursosBoxInstance;
    await box.put(curso.id, curso);
    await box.flush();
  }

  @override
  Future<void> deleteCurso(int id) async {
    final box = HiveHelper.cursosBoxInstance;
    await box.delete(id);
    await box.flush();
    
    // También eliminar inscripciones relacionadas
    final inscripcionesBox = HiveHelper.inscripcionesBoxInstance;
    final inscripcionesAEliminar = inscripcionesBox.values
        .where((inscripcion) => inscripcion.cursoId == id)
        .map((inscripcion) => inscripcion.id)
        .toList();
    
    for (var inscripcionId in inscripcionesAEliminar) {
      await inscripcionesBox.delete(inscripcionId);
      await box.flush();
    }
  }
}