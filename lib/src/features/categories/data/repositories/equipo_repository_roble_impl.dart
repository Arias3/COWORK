import '../../domain/entities/equipo_entity.dart';
import '../../domain/repositories/equipo_repository.dart';
import '../../../../../core/data/datasources/roble_api_datasource.dart';
import '../models/roble_equipo_dto.dart';

class EquipoRepositoryRobleImpl implements EquipoRepository {
  final RobleApiDataSource _dataSource = RobleApiDataSource();
  static const String tableName = 'equipos';

  static final Map<String, int> _robleToLocal = {};
  static final Map<int, String> _localToRoble = {};

  void _guardarMapeoId(String robleId, int localId) {
    try {
      _robleToLocal[robleId] = localId;
      _localToRoble[localId] = robleId;
      print('Mapeo ID guardado: "$robleId" <-> $localId');
    } catch (e) {
      print('Error guardando mapeo: $e');
    }
  }

  String? _obtenerRobleIdOriginal(int localId) {
    return _localToRoble[localId];
  }

  String? obtenerRobleIdOriginal(int localId) {
    return _localToRoble[localId];
  }

  int? obtenerIdLocal(String robleId) {
    return _robleToLocal[robleId];
  }

  @override
  Future<List<Equipo>> getEquiposPorCategoria(int categoriaId) async {
    try {
      final data = await _dataSource.getWhere(
        tableName,
        'categoria_id',
        categoriaId,
      );
      final equipos = <Equipo>[];

      for (var json in data) {
        try {
          final dto = RobleEquipoDto.fromJson(json);
          final equipo = dto.toEntity();

          if (dto.id != null && equipo.id != null) {
            _guardarMapeoId(dto.id!, equipo.id!);
          }

          equipos.add(equipo);
        } catch (e) {
          print('Error mapeando equipo: $e');
        }
      }

      return equipos;
    } catch (e) {
      print('Error obteniendo equipos: $e');
      return [];
    }
  }

  @override
  Future<Equipo?> getEquipoById(int id) async {
    try {
      final robleId = _obtenerRobleIdOriginal(id);

      if (robleId != null) {
        final data = await _dataSource.getById(tableName, robleId);

        if (data != null) {
          final dto = RobleEquipoDto.fromJson(data);
          return dto.toEntity();
        }
      }

      return null;
    } catch (e) {
      print('Error obteniendo equipo: $e');
      return null;
    }
  }

  @override
  Future<Equipo?> getEquipoByStringId(String equipoId) async {
    try {
      print('=== DEBUG MAPEO ===');
      print('Buscando equipo con ID: $equipoId');
      print('Mapeos actuales _localToRoble: $_localToRoble');
      print('Mapeos actuales _robleToLocal: $_robleToLocal');

      // PASO 1: Intentar como ID local convertido a Roble ID
      try {
        final intId = int.parse(equipoId);
        final robleId = _obtenerRobleIdOriginal(intId);

        print('DEBUG: intId = $intId, robleId = $robleId');

        if (robleId != null) {
          print('🔄 [EQUIPO] Buscando en Roble con ID: $robleId');
          final data = await _dataSource.getById(tableName, robleId);

          print('DEBUG: data recibido = $data');

          if (data != null) {
            print('✅ [EQUIPO] Data encontrado, creando DTO...');
            final dto = RobleEquipoDto.fromJson(data);
            final equipo = dto.toEntity();
            print('✅ [EQUIPO] Equipo creado: ${equipo.nombre}');
            return equipo;
          } else {
            print('❌ [EQUIPO] Data es null para Roble ID: $robleId');
          }
        } else {
          print('❌ [EQUIPO] robleId es null para intId: $intId');
        }
      } catch (e) {
        print('❌ [EQUIPO] Error en conversión/mapeo: $e');
      }

      // PASO 2: Intentar buscar directamente como Roble ID
      try {
        print('🔄 [EQUIPO] Intentando búsqueda directa con ID: $equipoId');
        final data = await _dataSource.getById(tableName, equipoId);

        if (data != null) {
          final dto = RobleEquipoDto.fromJson(data);
          final equipo = dto.toEntity();
          print('✅ [EQUIPO] Encontrado por búsqueda directa: ${equipo.nombre}');
          return equipo;
        }
      } catch (e) {
        print('❌ [EQUIPO] Error en búsqueda directa: $e');
      }

      print('❌ [EQUIPO] No se encontró el equipo con ningún método');
      return null;
    } catch (e) {
      print('❌ [EQUIPO] Error general: $e');
      return null;
    }
  }

  @override
  Future<Equipo?> getEquipoPorEstudiante(
    int estudianteId,
    int categoriaId,
  ) async {
    try {
      final equipos = await getEquiposPorCategoria(categoriaId);

      for (final equipo in equipos) {
        if (equipo.estudiantesIds.contains(estudianteId)) {
          return equipo;
        }
      }

      return null;
    } catch (e) {
      print('Error buscando equipo por estudiante: $e');
      return null;
    }
  }

  @override
  Future<String> createEquipo(Equipo equipo) async {
    try {
      final dto = RobleEquipoDto.fromEntity(equipo);
      final response = await _dataSource.create(tableName, dto.toJson());

      final robleId = _extraerIdDeRespuestaRoble(response);

      if (robleId != null) {
        final localId = _convertirAIdValido(robleId);

        if (localId != null && localId > 0) {
          _guardarMapeoId(robleId, localId);
          return robleId;
        }
      }

      throw Exception('No se pudo extraer ID válido');
    } catch (e) {
      print('Error creando equipo: $e');
      throw Exception('No se pudo crear el equipo: $e');
    }
  }

  @override
  Future<void> updateEquipo(Equipo equipo) async {
    try {
      final robleId = _obtenerRobleIdOriginal(equipo.id!);

      if (robleId != null) {
        final dto = RobleEquipoDto.fromEntity(equipo);
        await _dataSource.update(tableName, robleId, dto.toJson());
      } else {
        throw Exception('No se encontró ID de Roble');
      }
    } catch (e) {
      print('Error actualizando equipo: $e');
      throw Exception('No se pudo actualizar: $e');
    }
  }

  @override
  Future<void> deleteEquipo(int id) async {
    try {
      final robleId = _obtenerRobleIdOriginal(id);

      if (robleId != null) {
        await _dataSource.delete(tableName, robleId);
        _robleToLocal.remove(robleId);
        _localToRoble.remove(id);
        print('✅ [EQUIPO] Equipo eliminado de Roble con ID: $robleId');
      } else {
        print(
          '⚠️ [EQUIPO] No se encontró ID de Roble para equipo $id, eliminando solo de Roble',
        );
      }
    } catch (e) {
      print('❌ [EQUIPO] Error eliminando equipo de Roble: $e');
      throw Exception('No se pudo eliminar el equipo: $e');
    }
  }

  @override
  Future<void> deleteEquiposPorCategoria(int categoriaId) async {
    try {
      final equipos = await getEquiposPorCategoria(categoriaId);

      for (final equipo in equipos) {
        if (equipo.id != null) {
          await deleteEquipo(equipo.id!);
        }
      }

      print(
        '✅ Todos los equipos de la categoría $categoriaId han sido eliminados',
      );
    } catch (e) {
      print('❌ Error eliminando equipos por categoría: $e');
      throw Exception('No se pudieron eliminar los equipos: $e');
    }
  }

  String? _extraerIdDeRespuestaRoble(dynamic response) {
    try {
      if (response == null) return null;

      if (response is Map<String, dynamic> && response.containsKey('_id')) {
        return response['_id']?.toString();
      }

      if (response is Map<String, dynamic> && response.containsKey('id')) {
        return response['id']?.toString();
      }

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
      print('Error extrayendo ID: $e');
      return null;
    }
  }

  int? _convertirAIdValido(String robleId) {
    try {
      if (robleId.isEmpty) return null;

      final existingLocalId = _robleToLocal[robleId];
      if (existingLocalId != null) {
        return existingLocalId;
      }

      // ✅ SOLUCIONADO: Usar función determinística en lugar de hashCode.abs()
      final validId = _generateConsistentId(robleId);
      final finalId = validId == 0 ? 1 : validId;

      return finalId;
    } catch (e) {
      print('Error en conversión: $e');
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
