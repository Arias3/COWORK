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

      print('[ROBLE] Creando inscripcion:');
      print('  - Usuario ID: ${inscripcion.usuarioId}');
      print('  - Curso ID: ${inscripcion.cursoId}');
      print('  - Fecha: ${inscripcion.fechaInscripcion}');
      print('  - DTO JSON: ${dto.toJson()}');

      final response = await _dataSource.create(tableName, dto.toJson());
      print('[ROBLE] Respuesta de la API: $response');
      print('[ROBLE] Tipo de respuesta: ${response.runtimeType}');

      // Extraer ID de la respuesta según la estructura de Roble
      final idValue =
          response['id'] ?? response['_id'] ?? response['insertedId'];
      int nuevoId;

      if (idValue != null) {
        nuevoId = idValue is int
            ? idValue
            : int.tryParse(idValue.toString()) ??
                  _generateConsistentId(idValue.toString());
      } else {
        // Si no hay ID explícito, generar uno consistente basado en los datos
        final dataForId =
            '${inscripcion.usuarioId}_${inscripcion.cursoId}_${DateTime.now().millisecondsSinceEpoch}';
        nuevoId = _generateConsistentId(dataForId);
        print(
          '[ROBLE] ID generado automaticamente: $nuevoId para datos: $dataForId',
        );
      }

      print('[ROBLE] Inscripcion creada con ID: $nuevoId');
      return nuevoId;
    } catch (e) {
      print('[ROBLE] ERROR creando inscripcion: $e');
      print('[ROBLE] Stack trace: ${StackTrace.current}');
      throw Exception('No se pudo crear la inscripcion: $e');
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

  // ========================================================================
  // FUNCIÓN DETERMINÍSTICA PARA IDs CONSISTENTES CROSS-PLATFORM
  // ========================================================================
  static int _generateConsistentId(String input) {
    int hash = 0;
    for (int i = 0; i < input.length; i++) {
      int char = input.codeUnitAt(i);
      hash = ((hash << 5) - hash + char) & 0x7FFFFFFF;
    }
    return hash == 0 ? 1 : hash; // Evitar 0
  }
}
