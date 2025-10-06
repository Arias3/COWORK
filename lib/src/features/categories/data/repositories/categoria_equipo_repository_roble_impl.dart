import '../../domain/entities/categoria_equipo_entity.dart';
import '../../domain/repositories/categoria_equipo_repository.dart';
import '../../../../../core/data/datasources/roble_api_datasource.dart';
import '../models/roble_categoria_equipo_dto.dart';

class CategoriaEquipoRepositoryRobleImpl implements CategoriaEquipoRepository {
  final RobleApiDataSource _dataSource = RobleApiDataSource();
  static const String tableName = 'categorias_equipo';

  // ✅ MAPEO DE IDs COMO EN CURSOS
  static final Map<String, int> _robleToLocal = {};
  static final Map<int, String> _localToRoble = {};

  void _guardarMapeoId(String robleId, int localId) {
    try {
      _robleToLocal[robleId] = localId;
      _localToRoble[localId] = robleId;
      print('📋 [CATEGORIA] Mapeo ID guardado: "$robleId" <-> $localId');
    } catch (e) {
      print('⚠️ [CATEGORIA] Error guardando mapeo: $e');
    }
  }

  String? _obtenerRobleIdOriginal(int localId) {
    return _localToRoble[localId];
  }

  @override
  Future<List<CategoriaEquipo>> getCategoriasPorCurso(int cursoId) async {
    try {
      print('🔍 [CATEGORIA] Obteniendo categorías para curso: $cursoId');

      final data = await _dataSource.getWhere(tableName, 'curso_id', cursoId);
      print('📊 [CATEGORIA] Datos recibidos: ${data.length} categorías');

      final categorias = <CategoriaEquipo>[];

      for (var json in data) {
        try {
          final dto = RobleCategoriaEquipoDto.fromJson(json);
          final categoria = dto.toEntity();

          // ✅ GUARDAR MAPEO SI ES NECESARIO
          if (dto.id != null && categoria.id != null) {
            _guardarMapeoId(dto.id!, categoria.id!);
          }

          categorias.add(categoria);
          print(
            '✅ [CATEGORIA] Categoría mapeada: ${categoria.nombre} (ID: ${categoria.id})',
          );
        } catch (e) {
          print('❌ [CATEGORIA] Error mapeando categoría individual: $e');
          print('❌ [CATEGORIA] JSON problemático: $json');
        }
      }

      print('📈 [CATEGORIA] Total categorías procesadas: ${categorias.length}');
      return categorias;
    } catch (e) {
      print('❌ [CATEGORIA] Error obteniendo categorías por curso de Roble: $e');
      return [];
    }
  }

  @override
  Future<CategoriaEquipo?> getCategoriaById(int id) async {
    try {
      print('🔍 [CATEGORIA] Obteniendo categoría por ID local: $id');

      // ✅ INTENTAR OBTENER ID ORIGINAL DE ROBLE
      final robleId = _obtenerRobleIdOriginal(id);

      if (robleId != null) {
        print('🔄 [CATEGORIA] Buscando en Roble con ID original: $robleId');
        final data = await _dataSource.getById(tableName, robleId);

        if (data != null) {
          final dto = RobleCategoriaEquipoDto.fromJson(data);
          final categoria = dto.toEntity();
          print('✅ [CATEGORIA] Categoría encontrada: ${categoria.nombre}');
          return categoria;
        }
      } else {
        print('⚠️ [CATEGORIA] No se encontró mapeo para ID local: $id');
      }

      return null;
    } catch (e) {
      print('❌ [CATEGORIA] Error obteniendo categoría por ID de Roble: $e');
      return null;
    }
  }

  @override
  Future<int> createCategoria(CategoriaEquipo categoria) async {
    try {
      print('🔍 [CATEGORIA] Creando categoría: ${categoria.nombre}');

      final dto = RobleCategoriaEquipoDto.fromEntity(categoria);
      final response = await _dataSource.create(tableName, dto.toJson());

      print('🔵 [CATEGORIA] Respuesta de Roble: $response');

      // ✅ EXTRAER ID DE LA RESPUESTA
      final robleId = _extraerIdDeRespuestaRoble(response);

      if (robleId != null) {
        // Convertir string ID a int usando hashCode
        final localId = _convertirAIdValido(robleId);

        if (localId != null && localId > 0) {
          _guardarMapeoId(robleId, localId);
          print('✅ [CATEGORIA] Categoría creada con ID: $localId');
          return localId;
        }
      }

      throw Exception('No se pudo extraer ID válido de la respuesta');
    } catch (e) {
      print('❌ [CATEGORIA] Error creando categoría en Roble: $e');
      throw Exception('No se pudo crear la categoría: $e');
    }
  }

  @override
  Future<void> updateCategoria(CategoriaEquipo categoria) async {
    try {
      // ✅ OBTENER ID ORIGINAL DE ROBLE
      final robleId = _obtenerRobleIdOriginal(categoria.id!);

      if (robleId != null) {
        final dto = RobleCategoriaEquipoDto.fromEntity(categoria);
        await _dataSource.update(tableName, robleId, dto.toJson());
        print('✅ [CATEGORIA] Categoría actualizada en Roble con ID: $robleId');
      } else {
        throw Exception('No se encontró ID de Roble para la categoría');
      }
    } catch (e) {
      print('❌ [CATEGORIA] Error actualizando categoría en Roble: $e');
      throw Exception('No se pudo actualizar la categoría: $e');
    }
  }

  @override
  Future<void> deleteCategoria(int id) async {
    try {
      print('🗑️ [CATEGORIA] Iniciando eliminación de categoría ID: $id');

      // ✅ OBTENER ID ORIGINAL DE ROBLE
      final robleId = _obtenerRobleIdOriginal(id);

      if (robleId != null) {
        print('🔍 [CATEGORIA] ID de Roble encontrado: $robleId');

        // Eliminar equipos relacionados primero usando el ID local convertido
        print(
          '🔍 [CATEGORIA] Buscando equipos asociados con categoria_id: $id',
        );
        final equipos = await _dataSource.getWhere(
          'equipos',
          'categoria_id',
          id, // Usar el ID local convertido en lugar del robleId
        );

        print('📊 [CATEGORIA] Equipos encontrados: ${equipos.length}');

        for (var equipo in equipos) {
          final equipoId = equipo['_id'] ?? equipo['id'];
          if (equipoId != null) {
            print('🗑️ [CATEGORIA] Eliminando equipo: $equipoId');
            await _dataSource.delete('equipos', equipoId);
          }
        }

        // Eliminar la categoría usando el ID original de Roble
        print('🗑️ [CATEGORIA] Eliminando categoría con ID Roble: $robleId');
        await _dataSource.delete(tableName, robleId);

        // Limpiar mapeos
        _robleToLocal.remove(robleId);
        _localToRoble.remove(id);

        print('✅ [CATEGORIA] Categoría eliminada exitosamente');
      } else {
        print('⚠️ [CATEGORIA] No se encontró mapeo para ID: $id');

        // Intentar eliminar directamente por ID si no hay mapeo
        print('🔄 [CATEGORIA] Intentando eliminación directa...');
        await _dataSource.delete(tableName, id.toString());
      }
    } catch (e) {
      print('❌ [CATEGORIA] Error eliminando categoría: $e');
      throw Exception('No se pudo eliminar la categoría: $e');
    }
  }

  // ✅ MÉTODOS HELPER COMO EN CURSOS
  String? _extraerIdDeRespuestaRoble(dynamic response) {
    try {
      print('🔍 [CATEGORIA] Extrayendo ID de respuesta Roble...');

      if (response == null) return null;

      // Caso 1: Respuesta directa con _id
      if (response is Map<String, dynamic> && response.containsKey('_id')) {
        return response['_id']?.toString();
      }

      // Caso 2: Respuesta con id
      if (response is Map<String, dynamic> && response.containsKey('id')) {
        return response['id']?.toString();
      }

      // Caso 3: Estructura {inserted: [...]}
      if (response is Map<String, dynamic> &&
          response.containsKey('inserted')) {
        final inserted = response['inserted'];

        if (inserted is List && inserted.isNotEmpty) {
          final firstItem = inserted.first;

          if (firstItem is Map<String, dynamic>) {
            final rawId = firstItem['_id'] ?? firstItem['id'];
            return rawId?.toString();
          }
        }
      }

      return response?.toString();
    } catch (e) {
      print('❌ [CATEGORIA] Error extrayendo ID: $e');
      return null;
    }
  }

  int? _convertirAIdValido(String robleId) {
    try {
      if (robleId.isEmpty) return null;

      // Verificar si ya existe mapeo
      final existingLocalId = _robleToLocal[robleId];
      if (existingLocalId != null) {
        return existingLocalId;
      }

      // ✅ SOLUCIONADO: Usar función determinística en lugar de hashCode.abs()
      final validId = _generateConsistentId(robleId);
      final finalId = validId == 0 ? 1 : validId;

      print('✅ [CATEGORIA] String convertido: "$robleId" -> $finalId');
      return finalId;
    } catch (e) {
      print('❌ [CATEGORIA] Error en conversión: $e');
      return null;
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
