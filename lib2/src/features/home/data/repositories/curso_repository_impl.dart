// ========================================================================
// CURSO_REPOSITORY_IMPL.DART CORREGIDO
// ========================================================================

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
    final codigoLimpio = codigo.trim().toLowerCase();
    
    print('🔍 [REPO] Buscando curso con código: "$codigoLimpio"');
    print('📊 [REPO] Total cursos en BD: ${box.length}');
    
    // ✅ CORRECCIÓN: Usar where + firstOrNull en lugar de firstWhere
    try {
      final cursos = box.values.where((curso) => 
        curso.codigoRegistro.trim().toLowerCase() == codigoLimpio
      ).toList();
      
      if (cursos.isNotEmpty) {
        final cursoEncontrado = cursos.first;
        print('✅ [REPO] Curso encontrado: "${cursoEncontrado.nombre}" (ID: ${cursoEncontrado.id})');
        return cursoEncontrado;
      } else {
        print('❌ [REPO] No se encontró curso con código: "$codigo"');
        return null;
      }
    } catch (e) {
      print('💥 [REPO] Error buscando curso: $e');
      return null;
    }
  }

  @override
  Future<int> createCurso(CursoDomain curso) async {
    final box = HiveHelper.cursosBoxInstance;
    
    // ✅ CORRECCIÓN CRÍTICA: Generar ID único correctamente
    int nuevoId;
    if (box.isEmpty) {
      nuevoId = 1;
    } else {
      // Obtener el ID máximo actual y sumar 1
      final maxId = box.keys.cast<int>().reduce((a, b) => a > b ? a : b);
      nuevoId = maxId + 1;
    }
    
    curso.id = nuevoId;
    
    print('💾 [REPO] Guardando curso "${curso.nombre}" con:');
    print('  - ID: ${curso.id}');
    print('  - Código: "${curso.codigoRegistro}"');
    
    await box.put(nuevoId, curso);
    await box.flush();
    
    // Verificar que se guardó correctamente
    final verificacion = box.get(nuevoId);
    if (verificacion != null) {
      print('✅ [REPO] Curso guardado y verificado correctamente');
    } else {
      print('❌ [REPO] ERROR: No se pudo verificar el curso guardado');
    }
    
    return nuevoId;
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
        .map((inscripcion) => inscripcion.id!)
        .toList();
        
    for (var inscripcionId in inscripcionesAEliminar) {
      await inscripcionesBox.delete(inscripcionId);
    }
    await inscripcionesBox.flush();
  }
}