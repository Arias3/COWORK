import '../../domain/entities/curso_entity.dart';
import '../../domain/repositories/curso_repository.dart';
import '../../../../../core/data/datasources/roble_api_datasource.dart';
import '../models/roble_curso_dto.dart';

class CursoRepositoryRobleImpl implements CursoRepository {
  final RobleApiDataSource _dataSource = RobleApiDataSource();
  static const String tableName = 'cursos';

  // Mapa para convertir IDs locales a IDs de Roble
  static final Map<int, String> _localToRoble = {};
  static final Map<String, int> _robleToLocal = {};

  // Función para generar ID consistente
  static int _generateConsistentId(String input) {
    int hash = 0;
    for (int i = 0; i < input.length; i++) {
      int char = input.codeUnitAt(i);
      hash = ((hash << 5) - hash + char) & 0x7FFFFFFF;
    }
    return hash == 0 ? 1 : hash;
  }

  // Guardar mapeo de IDs
  void _guardarMapeo(int localId, String robleId) {
    _localToRoble[localId] = robleId;
    _robleToLocal[robleId] = localId;
  }

  String? _obtenerRobleIdOriginal(int localId) {
    return _localToRoble[localId];
  }

  @override
  Future<List<CursoDomain>> getCursos() async {
    try {
      final data = await _dataSource.getAll(tableName);
      return data
          .map((json) => RobleCursoDto.fromJson(json).toEntity())
          .toList();
    } catch (e) {
      print('Error obteniendo cursos de Roble: $e');
      return [];
    }
  }

  @override
  Future<List<CursoDomain>> getCursosPorProfesor(int profesorId) async {
    try {
      final data = await _dataSource.getWhere(
        tableName,
        'profesor_id',
        profesorId,
      );
      return data
          .map((json) => RobleCursoDto.fromJson(json).toEntity())
          .toList();
    } catch (e) {
      print('Error obteniendo cursos por profesor de Roble: $e');
      return [];
    }
  }

  @override
  Future<List<CursoDomain>> getCursosInscritos(int usuarioId) async {
    try {
      // Obtener inscripciones del usuario
      final inscripciones = await _dataSource.getWhere(
        'inscripciones',
        'usuario_id',
        usuarioId,
      );

      // Obtener cursos correspondientes
      final cursos = <CursoDomain>[];
      for (var inscripcion in inscripciones) {
        final cursoData = await _dataSource.getById(
          tableName,
          inscripcion['curso_id'],
        );
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
      print('[ROBLE] getCursoById buscando curso con ID: $id');

      // Primero intentar obtener el ID original de Roble del mapeo
      String? robleIdOriginal = _obtenerRobleIdOriginal(id);

      // Buscar en todos los cursos y comparar ID generado
      print('[ROBLE] Buscando en todos los cursos por ID generado: $id');
      final allCursos = await _dataSource.getAll(tableName);

      for (final cursoData in allCursos) {
        final robleId = cursoData['_id'];
        if (robleId != null) {
          final generatedId = _generateConsistentId(robleId.toString());
          if (generatedId == id) {
            print('[ROBLE] ✅ Curso encontrado con ID: $id (Roble: $robleId)');
            // Guardar mapeo para futuros usos si no existe
            if (robleIdOriginal == null) {
              _guardarMapeo(id, robleId.toString());
            }
            return RobleCursoDto.fromJson(cursoData).toEntity();
          }
        }
      }

      print('[ROBLE] ❌ No se encontró curso con ID: $id');
      return null;
    } catch (e) {
      print('[ROBLE] Error obteniendo curso por ID: $e');
      return null;
    }
  }

  @override
  Future<CursoDomain?> getCursoByCodigoRegistro(String codigo) async {
    try {
      print('[ROBLE] Buscando curso con codigo: "$codigo"');

      // Buscar usando el código exacto como está almacenado
      final data = await _dataSource.getWhere(
        tableName,
        'codigo_registro',
        codigo,
      );

      print('[ROBLE] Resultados encontrados: ${data.length}');

      if (data.isNotEmpty) {
        final cursoData = data.first;
        print('[ROBLE] Curso encontrado en BD: ${cursoData}');

        final cursoEncontrado = RobleCursoDto.fromJson(cursoData).toEntity();
        print(
          '[ROBLE] Curso encontrado: "${cursoEncontrado.nombre}" (ID: ${cursoEncontrado.id})',
        );
        return cursoEncontrado;
      } else {
        print('[ROBLE] No se encontro curso con codigo: "$codigo"');

        // Intentar búsqueda case-insensitive como fallback
        final allCursos = await _dataSource.getAll(tableName);
        for (var cursoData in allCursos) {
          final codigoEnBD = cursoData['codigo_registro']
              ?.toString()
              .toLowerCase();
          if (codigoEnBD == codigo.toLowerCase()) {
            print('[ROBLE] Curso encontrado con busqueda case-insensitive');
            final cursoEncontrado = RobleCursoDto.fromJson(
              cursoData,
            ).toEntity();
            return cursoEncontrado;
          }
        }

        return null;
      }
    } catch (e) {
      print('[ROBLE] Error buscando curso: $e');
      return null;
    }
  }

  @override
  Future<int> createCurso(CursoDomain curso) async {
    try {
      final dto = RobleCursoDto.fromEntity(curso);

      print(
        '[ROBLE] Guardando curso "${curso.nombre}" con codigo: "${curso.codigoRegistro}"',
      );
      print('[ROBLE] DTO JSON: ${dto.toJson()}');

      final response = await _dataSource.create(tableName, dto.toJson());
      print('[ROBLE] Respuesta completa de creacion: $response');

      // Extraer ID de la respuesta según estructura de Roble API
      int nuevoId;
      String? robleIdOriginal;

      // La respuesta tiene estructura: {inserted: [{_id: "...", ...}], skipped: []}
      if (response['inserted'] != null &&
          response['inserted'] is List &&
          response['inserted'].isNotEmpty) {
        final insertedItem = response['inserted'][0];
        robleIdOriginal = insertedItem['_id'];

        print('[ROBLE] ID extraido de inserted[0][_id]: $robleIdOriginal');

        if (robleIdOriginal != null) {
          nuevoId = _generateConsistentId(robleIdOriginal.toString());
          // Guardar mapeo para lookup posterior
          _guardarMapeo(nuevoId, robleIdOriginal);
        } else {
          nuevoId = _generateConsistentId(curso.codigoRegistro);
        }
      } else {
        // Fallback: generar ID consistente basado en código de registro
        nuevoId = _generateConsistentId(curso.codigoRegistro);
        print(
          '[ROBLE] Fallback - ID generado para codigo: ${curso.codigoRegistro}',
        );
      }

      print('[ROBLE] Curso guardado con ID final: $nuevoId');
      print(
        '[ROBLE] Mapeo guardado: Local($nuevoId) -> Roble($robleIdOriginal)',
      );
      return nuevoId;
    } catch (e) {
      print('[ROBLE] ERROR creando curso: $e');
      print('[ROBLE] Stack trace: ${StackTrace.current}');
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
      print('[ROBLE] deleteCurso iniciando para ID: $id');

      // Primero obtener el ID original de Roble
      String? robleIdOriginal = _obtenerRobleIdOriginal(id);

      if (robleIdOriginal == null) {
        // Fallback: buscar en todos los cursos para encontrar el ID de Roble
        print(
          '[ROBLE] ID de Roble no encontrado en mapeo, buscando en todos los cursos...',
        );
        final allCursos = await _dataSource.getAll(tableName);

        for (final cursoData in allCursos) {
          final robleId = cursoData['_id'];
          if (robleId != null) {
            final generatedId = _generateConsistentId(robleId.toString());
            if (generatedId == id) {
              robleIdOriginal = robleId.toString();
              // Guardar mapeo para futuros usos
              _guardarMapeo(id, robleIdOriginal);
              break;
            }
          }
        }
      }

      if (robleIdOriginal == null) {
        print('[ROBLE] ❌ No se encontró curso con ID: $id');
        throw Exception('No se encontró el curso con ID: $id');
      }

      print('[ROBLE] Eliminando curso con ID de Roble: $robleIdOriginal');

      // Eliminar inscripciones relacionadas primero
      print('[ROBLE] Buscando inscripciones del curso...');
      final inscripciones = await _dataSource.getWhere(
        'inscripciones',
        'curso_id',
        id,
      );

      print(
        '[ROBLE] Encontradas ${inscripciones.length} inscripciones para eliminar',
      );
      for (var inscripcion in inscripciones) {
        final inscripcionId = inscripcion['_id'];
        if (inscripcionId != null) {
          print(
            '[ROBLE] Eliminando inscripción con ID de Roble: $inscripcionId',
          );
          await _dataSource.delete('inscripciones', inscripcionId.toString());
          print('[ROBLE] ✅ Inscripción eliminada');
        }
      }

      // Eliminar el curso usando el ID de Roble
      print('[ROBLE] Eliminando curso principal...');
      await _dataSource.delete(tableName, robleIdOriginal);
      print('[ROBLE] ✅ Curso eliminado');

      // Limpiar mapeo
      _localToRoble.remove(id);
      _robleToLocal.remove(robleIdOriginal);

      print('[ROBLE] ✅ Curso eliminado exitosamente');
    } catch (e) {
      print('[ROBLE] Error eliminando curso: $e');
      print('[ROBLE] Stack trace: ${StackTrace.current}');
      throw Exception('No se pudo eliminar el curso: $e');
    }
  }
}
