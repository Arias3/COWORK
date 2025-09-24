import '../../domain/entities/inscripcion_entity.dart';
import '../../domain/repositories/inscripcion_repository.dart';
import '../../../../../core/data/datasources/roble_api_datasource.dart';
import '../models/roble_inscripcion_dto.dart';

class InscripcionRepositoryRobleImpl implements InscripcionRepository {
  final RobleApiDataSource _dataSource = RobleApiDataSource();
  static const String tableName = 'inscripciones';

  @override
  Future<List<Inscripcion>> getInscripciones() async {
    try {
      final data = await _dataSource.getAll(tableName);
      return data
          .map((json) => RobleInscripcionDto.fromJson(json).toEntity())
          .toList();
    } catch (e) {
      print('Error obteniendo inscripciones de Roble: $e');
      return [];
    }
  }

  @override
  Future<List<Inscripcion>> getInscripcionesPorUsuario(int usuarioId) async {
    try {
      final data = await _dataSource.getWhere(
        tableName,
        'usuario_id',
        usuarioId,
      );
      return data
          .map((json) => RobleInscripcionDto.fromJson(json).toEntity())
          .toList();
    } catch (e) {
      print('Error obteniendo inscripciones por usuario de Roble: $e');
      return [];
    }
  }

  @override
  Future<List<Inscripcion>> getInscripcionesPorCurso(int cursoId) async {
    try {
      final data = await _dataSource.getWhere(tableName, 'curso_id', cursoId);
      return data
          .map((json) => RobleInscripcionDto.fromJson(json).toEntity())
          .toList();
    } catch (e) {
      print('Error obteniendo inscripciones por curso de Roble: $e');
      return [];
    }
  }

  @override
  Future<Inscripcion?> getInscripcion(int usuarioId, int cursoId) async {
    try {
      final data = await _dataSource.getAll(tableName);
      final inscripciones = data
          .where(
            (item) =>
                item['usuario_id'] == usuarioId && item['curso_id'] == cursoId,
          )
          .toList();

      return inscripciones.isNotEmpty
          ? RobleInscripcionDto.fromJson(inscripciones.first).toEntity()
          : null;
    } catch (e) {
      print('Error obteniendo inscripción específica de Roble: $e');
      return null;
    }
  }

  @override
  Future<int> createInscripcion(Inscripcion inscripcion) async {
    try {
      final dto = RobleInscripcionDto.fromEntity(inscripcion);

      print('📝 [ROBLE] Creando inscripción:');
      print('  - Usuario ID: ${inscripcion.usuarioId}');
      print('  - Curso ID: ${inscripcion.cursoId}');

      final response = await _dataSource.create(tableName, dto.toJson());
      final nuevoId = response['id'] ?? 0;

      print('✅ [ROBLE] Inscripción creada con ID: $nuevoId');
      return nuevoId;
    } catch (e) {
      print('Error creando inscripción en Roble: $e');
      throw Exception('No se pudo crear la inscripción: $e');
    }
  }

  @override
  Future<void> deleteInscripcion(int usuarioId, int cursoId) async {
    try {
      final inscripcion = await getInscripcion(usuarioId, cursoId);
      if (inscripcion?.id != null) {
        await _dataSource.delete(tableName, inscripcion!.id);
      }
    } catch (e) {
      print('Error eliminando inscripción de Roble: $e');
      throw Exception('No se pudo eliminar la inscripción: $e');
    }
  }

  @override
  Future<bool> estaInscrito(int usuarioId, int cursoId) async {
    try {
      final inscripcion = await getInscripcion(usuarioId, cursoId);
      return inscripcion != null;
    } catch (e) {
      print('Error verificando inscripción en Roble: $e');
      return false;
    }
  }
}
