import '../../domain/entities/inscripcion_entity.dart';
import '../../domain/repositories/inscripcion_repository.dart';
import '../../../../../core/data/database/hive_helper.dart';

class InscripcionRepositoryImpl implements InscripcionRepository {
  @override
  Future<List<Inscripcion>> getInscripciones() async {
    final box = HiveHelper.inscripcionesBoxInstance;
    return box.values.toList();
  }

  @override
  Future<List<Inscripcion>> getInscripcionesPorUsuario(int usuarioId) async {
    final box = HiveHelper.inscripcionesBoxInstance;
    return box.values
        .where((inscripcion) => inscripcion.usuarioId == usuarioId)
        .toList();
  }

  @override
  Future<List<Inscripcion>> getInscripcionesPorCurso(int cursoId) async {
    final box = HiveHelper.inscripcionesBoxInstance;
    return box.values
        .where((inscripcion) => inscripcion.cursoId == cursoId)
        .toList();
  }

  @override
  Future<Inscripcion?> getInscripcion(int usuarioId, int cursoId) async {
    final box = HiveHelper.inscripcionesBoxInstance;
    try {
      return box.values.firstWhere(
        (inscripcion) =>
            inscripcion.usuarioId == usuarioId &&
            inscripcion.cursoId == cursoId,
      );
    } catch (e) {
      return null;
    }
  }

  @override
  Future<int> createInscripcion(Inscripcion inscripcion) async {
    final box = HiveHelper.inscripcionesBoxInstance;
    final id = box.length + 1;
    inscripcion.id = id;
    await box.put(id, inscripcion);
    await box.flush();
    return id;
  }

  @override
  Future<void> deleteInscripcion(int usuarioId, int cursoId) async {
    final box = HiveHelper.inscripcionesBoxInstance;
    final inscripcion = await getInscripcion(usuarioId, cursoId);
    if (inscripcion != null) {
      await box.delete(inscripcion.id);
      await box.flush();
    }
  }

  @override
  Future<bool> estaInscrito(int usuarioId, int cursoId) async {
    final inscripcion = await getInscripcion(usuarioId, cursoId);
    return inscripcion != null;
  }
}
