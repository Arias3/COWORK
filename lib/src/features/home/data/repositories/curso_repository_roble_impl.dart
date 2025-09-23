import '../../domain/entities/curso_entity.dart';
import '../../domain/repositories/curso_repository.dart';
import '../../../../../core/data/datasources/roble_api_datasource.dart';
import '../models/roble_curso_dto.dart';

class CursoRepositoryRobleImpl implements CursoRepository {
  final RobleApiDataSource _dataSource = RobleApiDataSource();
  static const String tableName = 'cursos';

  @override
  Future<List<CursoDomain>> getCursos() async {
    try {
      final data = await _dataSource.getAll(tableName);
      return data.map((json) => RobleCursoDto.fromJson(json).toEntity()).toList();
    } catch (e) {
      print('Error obteniendo cursos de Roble: $e');
      return [];
    }
  }

  @override
  Future<List<CursoDomain>> getCursosPorProfesor(int profesorId) async {
    try {
      final data = await _dataSource.getWhere(tableName, 'profesor_id', profesorId);
      return data.map((json) => RobleCursoDto.fromJson(json).toEntity()).toList();
    } catch (e) {
      print('Error obteniendo cursos por profesor de Roble: $e');
      return [];
    }
  }

  @override
  Future<List<CursoDomain>> getCursosInscritos(int usuarioId) async {
    try {
      // Obtener inscripciones del usuario
      final inscripciones = await _dataSource.getWhere('inscripciones', 'usuario_id', usuarioId);
      
      // Obtener cursos correspondientes
      final cursos = <CursoDomain>[];
      for (var inscripcion in inscripciones) {
        final cursoData = await _dataSource.getById(tableName, inscripcion['curso_id']);
        if (cursoData != null) {
          cursos.add(RobleCursoDto.fromJson(cursoData).toEntity());
        }
      }
      return cursos;
    } catch (e) {
      print('Error obteniendo cursos inscritos de Roble: $e');
      return [];
    }
  }

  @override
  Future<CursoDomain?> getCursoById(int id) async {
    try {
      final data = await _dataSource.getById(tableName, id);
      return data != null ? RobleCursoDto.fromJson(data).toEntity() : null;
    } catch (e) {
      print('Error obteniendo curso por ID de Roble: $e');
      return null;
    }
  }

  @override
  Future<CursoDomain?> getCursoByCodigoRegistro(String codigo) async {
    try {
      final codigoLimpio = codigo.trim().toLowerCase();
      final data = await _dataSource.getWhere(tableName, 'codigo_registro', codigoLimpio);
      
      if (data.isNotEmpty) {
        final cursoEncontrado = RobleCursoDto.fromJson(data.first).toEntity();
        print('✅ [ROBLE] Curso encontrado: "${cursoEncontrado.nombre}" (ID: ${cursoEncontrado.id})');
        return cursoEncontrado;
      } else {
        print('❌ [ROBLE] No se encontró curso con código: "$codigo"');
        return null;
      }
    } catch (e) {
      print('💥 [ROBLE] Error buscando curso: $e');
      return null;
    }
  }

  @override
  Future<int> createCurso(CursoDomain curso) async {
    try {
      final dto = RobleCursoDto.fromEntity(curso);
      
      print('💾 [ROBLE] Guardando curso "${curso.nombre}" con código: "${curso.codigoRegistro}"');
      
      final response = await _dataSource.create(tableName, dto.toJson());
      final nuevoId = response['id'] ?? 0;
      
      print('✅ [ROBLE] Curso guardado con ID: $nuevoId');
      return nuevoId;
    } catch (e) {
      print('❌ [ROBLE] Error creando curso: $e');
      throw Exception('No se pudo crear el curso: $e');
    }
  }

  @override
  Future<void> updateCurso(CursoDomain curso) async {
    try {
      final dto = RobleCursoDto.fromEntity(curso);
      await _dataSource.update(tableName, curso.id, dto.toJson());
    } catch (e) {
      print('Error actualizando curso en Roble: $e');
      throw Exception('No se pudo actualizar el curso: $e');
    }
  }

  @override
  Future<void> deleteCurso(int id) async {
    try {
      // Eliminar inscripciones relacionadas primero
      final inscripciones = await _dataSource.getWhere('inscripciones', 'curso_id', id);
      for (var inscripcion in inscripciones) {
        await _dataSource.delete('inscripciones', inscripcion['id']);
      }
      
      // Eliminar el curso
      await _dataSource.delete(tableName, id);
    } catch (e) {
      print('Error eliminando curso de Roble: $e');
      throw Exception('No se pudo eliminar el curso: $e');
    }
  }

  
}