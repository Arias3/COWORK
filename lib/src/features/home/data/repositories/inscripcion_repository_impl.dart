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
    return box.values.where((inscripcion) => inscripcion.usuarioId == usuarioId).toList();
  }

  @override
  Future<List<Inscripcion>> getInscripcionesPorCurso(int cursoId) async {
    final box = HiveHelper.inscripcionesBoxInstance;
    return box.values.where((inscripcion) => inscripcion.cursoId == cursoId).toList();
  }

  @override
  Future<Inscripcion?> getInscripcion(int usuarioId, int cursoId) async {
    final box = HiveHelper.inscripcionesBoxInstance;
    
    // ✅ CORRECCIÓN: Usar where + firstOrNull en lugar de firstWhere
    try {
      final inscripciones = box.values.where(
        (inscripcion) => inscripcion.usuarioId == usuarioId && inscripcion.cursoId == cursoId
      ).toList();
      
      return inscripciones.isNotEmpty ? inscripciones.first : null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<int> createInscripcion(Inscripcion inscripcion) async {
    final box = HiveHelper.inscripcionesBoxInstance;
    
    // ✅ CORRECCIÓN CRÍTICA: Generar ID único correctamente
    int nuevoId;
    if (box.isEmpty) {
      nuevoId = 1;
    } else {
      // Obtener el ID máximo actual y sumar 1
      final maxId = box.keys.cast<int>().reduce((a, b) => a > b ? a : b);
      nuevoId = maxId + 1;
    }
    
    inscripcion.id = nuevoId;
    
    print('📝 [INSCRIPCION] Creando inscripción:');
    print('  - ID: ${inscripcion.id}');
    print('  - Usuario ID: ${inscripcion.usuarioId}');
    print('  - Curso ID: ${inscripcion.cursoId}');
    
    await box.put(nuevoId, inscripcion);
    await box.flush();
    
    return nuevoId;
  }

  @override
  Future<void> deleteInscripcion(int usuarioId, int cursoId) async {
    final box = HiveHelper.inscripcionesBoxInstance;
    final inscripcion = await getInscripcion(usuarioId, cursoId);
    if (inscripcion != null && inscripcion.id != null) {
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