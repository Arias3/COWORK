import '../../domain/entities/activity.dart';
import '../../domain/repositories/i_activity_repository.dart';
import '../../../../../core/data/datasources/roble_api_datasource.dart';
import '../models/roble_activity_dto.dart';

class ActivityRepositoryRobleImpl implements IActivityRepository {
  final RobleApiDataSource _dataSource = RobleApiDataSource();
  static const String tableName = 'actividades';

  // ✅ MAPEO DE IDs COMO EN OTROS REPOSITORIOS
  static final Map<String, int> _robleToLocal = {};
  static final Map<int, String> _localToRoble = {};

  void _guardarMapeoId(String robleId, int localId) {
    try {
      _robleToLocal[robleId] = localId;
      _localToRoble[localId] = robleId;
      print('📋 [ACTIVIDAD] Mapeo ID guardado: "$robleId" <-> $localId');
    } catch (e) {
      print('⚠️ [ACTIVIDAD] Error guardando mapeo: $e');
    }
  }

  String? _obtenerRobleIdOriginal(int localId) {
    return _localToRoble[localId];
  }

  @override
  Future<List<Activity>> getAllActivities() async {
    try {
      print('🔍 [ACTIVIDAD] Obteniendo todas las actividades');

      final data = await _dataSource.getAll(tableName);
      print('📊 [ACTIVIDAD] Datos recibidos: ${data.length} actividades');

      final actividades = <Activity>[];

      for (var json in data) {
        try {
          final dto = RobleActivityDto.fromJson(json);
          final actividad = dto.toEntity();

          // ✅ GUARDAR MAPEO SI ES NECESARIO
          if (dto.id != null && actividad.id != null) {
            _guardarMapeoId(dto.id!, actividad.id!);
          }

          actividades.add(actividad);
          print(
            '✅ [ACTIVIDAD] Actividad mapeada: ${actividad.nombre} (ID: ${actividad.id})',
          );
        } catch (e) {
          print('❌ [ACTIVIDAD] Error mapeando actividad individual: $e');
          print('❌ [ACTIVIDAD] JSON problemático: $json');
        }
      }

      print(
        '📈 [ACTIVIDAD] Total actividades procesadas: ${actividades.length}',
      );
      return actividades;
    } catch (e) {
      print('❌ [ACTIVIDAD] Error obteniendo actividades de Roble: $e');
      return [];
    }
  }

  @override
  Future<Activity?> getActivityById(int id) async {
    try {
      print('🔍 [ACTIVIDAD] Obteniendo actividad por ID local: $id');

      // ✅ INTENTAR OBTENER ID ORIGINAL DE ROBLE
      final robleId = _obtenerRobleIdOriginal(id);

      if (robleId != null) {
        print('🔄 [ACTIVIDAD] Buscando en Roble con ID original: $robleId');
        final data = await _dataSource.getById(tableName, robleId);

        if (data != null) {
          final dto = RobleActivityDto.fromJson(data);
          final actividad = dto.toEntity();
          print('✅ [ACTIVIDAD] Actividad encontrada: ${actividad.nombre}');
          return actividad;
        }
      } else {
        print('⚠️ [ACTIVIDAD] No se encontró mapeo para ID local: $id');
      }

      return null;
    } catch (e) {
      print('❌ [ACTIVIDAD] Error obteniendo actividad por ID de Roble: $e');
      return null;
    }
  }

  @override
  Future<List<Activity>> getActivitiesByCategoria(int categoriaId) async {
    try {
      print(
        '🔍 [ACTIVIDAD] Obteniendo actividades para categoría: $categoriaId',
      );

      final data = await _dataSource.getWhere(
        tableName,
        'categoria_id',
        categoriaId,
      );
      print('📊 [ACTIVIDAD] Datos recibidos: ${data.length} actividades');

      final actividades = <Activity>[];

      for (var json in data) {
        try {
          final dto = RobleActivityDto.fromJson(json);
          final actividad = dto.toEntity();

          // ✅ GUARDAR MAPEO SI ES NECESARIO
          if (dto.id != null && actividad.id != null) {
            _guardarMapeoId(dto.id!, actividad.id!);
          }

          actividades.add(actividad);
          print(
            '✅ [ACTIVIDAD] Actividad mapeada: ${actividad.nombre} (ID: ${actividad.id})',
          );
        } catch (e) {
          print('❌ [ACTIVIDAD] Error mapeando actividad individual: $e');
          print('❌ [ACTIVIDAD] JSON problemático: $json');
        }
      }

      print(
        '📈 [ACTIVIDAD] Total actividades procesadas: ${actividades.length}',
      );
      return actividades;
    } catch (e) {
      print(
        '❌ [ACTIVIDAD] Error obteniendo actividades por categoría de Roble: $e',
      );
      return [];
    }
  }

  @override
  Future<int> createActivity(Activity activity) async {
    try {
      print('🔍 [ACTIVIDAD] Creando actividad: ${activity.nombre}');

      final dto = RobleActivityDto.fromEntity(activity);
      final response = await _dataSource.create(tableName, dto.toJson());

      final robleId = _extraerIdDeRespuestaRoble(response);
      if (robleId != null) {
        final localId = _convertirAIdValido(robleId);
        if (localId != null) {
          _guardarMapeoId(robleId, localId);
          print('✅ [ACTIVIDAD] Actividad creada con ID: $localId');
          return localId;
        }
      }

      throw Exception('No se pudo obtener ID válido de la respuesta');
    } catch (e) {
      print('❌ [ACTIVIDAD] Error creando actividad en Roble: $e');
      throw Exception('No se pudo crear la actividad: $e');
    }
  }

  @override
  Future<void> updateActivity(Activity activity) async {
    try {
      print('🔄 [ACTIVIDAD] Actualizando actividad: ${activity.nombre}');

      // ✅ OBTENER ID ORIGINAL DE ROBLE
      String? robleId = activity.robleId;
      if (robleId == null && activity.id != null) {
        robleId = _obtenerRobleIdOriginal(activity.id!);
      }

      if (robleId != null) {
        final dto = RobleActivityDto.fromEntity(activity);
        await _dataSource.update(tableName, robleId, dto.toJson());
        print('✅ [ACTIVIDAD] Actividad actualizada exitosamente');
      } else {
        throw Exception('No se encontró ID de Roble para actualizar');
      }
    } catch (e) {
      print('❌ [ACTIVIDAD] Error actualizando actividad en Roble: $e');
      throw Exception('No se pudo actualizar la actividad: $e');
    }
  }

  @override
  Future<void> deleteActivity(int id) async {
    try {
      print('🗑️ [ACTIVIDAD] Iniciando eliminación de actividad ID: $id');

      // ✅ OBTENER ID ORIGINAL DE ROBLE
      final robleId = _obtenerRobleIdOriginal(id);

      if (robleId != null) {
        print('🗑️ [ACTIVIDAD] Eliminando actividad con ID Roble: $robleId');
        await _dataSource.delete(tableName, robleId);

        // Limpiar mapeos
        _robleToLocal.remove(robleId);
        _localToRoble.remove(id);

        print('✅ [ACTIVIDAD] Actividad eliminada exitosamente');
      } else {
        print('⚠️ [ACTIVIDAD] No se encontró mapeo para ID: $id');

        // Intentar eliminar directamente por ID si no hay mapeo
        print('🔄 [ACTIVIDAD] Intentando eliminación directa...');
        await _dataSource.delete(tableName, id.toString());
      }
    } catch (e) {
      print('❌ [ACTIVIDAD] Error eliminando actividad: $e');
      throw Exception('No se pudo eliminar la actividad: $e');
    }
  }

  @override
  Future<List<Activity>> getActiveActivities() async {
    try {
      print('🔍 [ACTIVIDAD] Obteniendo actividades activas');

      final data = await _dataSource.getWhere(tableName, 'activo', true);
      print(
        '📊 [ACTIVIDAD] Datos recibidos: ${data.length} actividades activas',
      );

      final actividades = <Activity>[];

      for (var json in data) {
        try {
          final dto = RobleActivityDto.fromJson(json);
          final actividad = dto.toEntity();

          // ✅ GUARDAR MAPEO SI ES NECESARIO
          if (dto.id != null && actividad.id != null) {
            _guardarMapeoId(dto.id!, actividad.id!);
          }

          actividades.add(actividad);
        } catch (e) {
          print('❌ [ACTIVIDAD] Error mapeando actividad activa: $e');
        }
      }

      print(
        '📈 [ACTIVIDAD] Total actividades activas procesadas: ${actividades.length}',
      );
      return actividades;
    } catch (e) {
      print('❌ [ACTIVIDAD] Error obteniendo actividades activas de Roble: $e');
      return [];
    }
  }

  @override
  Future<List<Activity>> getActivitiesInDateRange(
    DateTime inicio,
    DateTime fin,
  ) async {
    try {
      // Por simplicidad, obtenemos todas y filtramos localmente
      // En una implementación más optimizada, se podría hacer la consulta directamente en Roble
      final todasActividades = await getAllActivities();

      return todasActividades.where((actividad) {
        return actividad.fechaEntrega.isAfter(inicio) &&
            actividad.fechaEntrega.isBefore(fin);
      }).toList();
    } catch (e) {
      print(
        '❌ [ACTIVIDAD] Error obteniendo actividades por rango de fechas: $e',
      );
      return [];
    }
  }

  @override
  Future<void> deactivateActivity(int id) async {
    try {
      final actividad = await getActivityById(id);
      if (actividad != null) {
        final actividadDesactivada = actividad.copyWith(activo: false);
        await updateActivity(actividadDesactivada);
        print('✅ [ACTIVIDAD] Actividad desactivada: ${actividad.nombre}');
      }
    } catch (e) {
      print('❌ [ACTIVIDAD] Error desactivando actividad: $e');
      throw Exception('No se pudo desactivar la actividad: $e');
    }
  }

  @override
  Future<void> deleteActivitiesByCategoria(int categoriaId) async {
    try {
      print(
        '🗑️ [ACTIVIDAD] Eliminando actividades de categoría: $categoriaId',
      );

      final actividades = await getActivitiesByCategoria(categoriaId);

      for (final actividad in actividades) {
        if (actividad.id != null) {
          await deleteActivity(actividad.id!);
        }
      }

      print(
        '✅ [ACTIVIDAD] Todas las actividades de la categoría $categoriaId eliminadas',
      );
    } catch (e) {
      print('❌ [ACTIVIDAD] Error eliminando actividades por categoría: $e');
      throw Exception('No se pudieron eliminar las actividades: $e');
    }
  }

  @override
  Future<List<Activity>> searchActivitiesByName(String query) async {
    try {
      // Por simplicidad, obtenemos todas y filtramos localmente
      final todasActividades = await getAllActivities();

      return todasActividades.where((actividad) {
        return actividad.nombre.toLowerCase().contains(query.toLowerCase());
      }).toList();
    } catch (e) {
      print('❌ [ACTIVIDAD] Error buscando actividades por nombre: $e');
      return [];
    }
  }

  @override
  Future<bool> existsActivityInCategory(int categoriaId, String nombre) async {
    try {
      final actividades = await getActivitiesByCategoria(categoriaId);

      return actividades.any(
        (actividad) => actividad.nombre.toLowerCase() == nombre.toLowerCase(),
      );
    } catch (e) {
      print('❌ [ACTIVIDAD] Error verificando existencia de actividad: $e');
      return false;
    }
  }

  // ========================================================================
  // MÉTODOS HELPER
  // ========================================================================
  String? _extraerIdDeRespuestaRoble(dynamic response) {
    try {
      if (response == null) return null;

      // Caso 1: Response directo es String
      if (response is String) return response;

      // Caso 2: Response es Map con _id
      if (response is Map<String, dynamic>) {
        final id = response['_id'] ?? response['id'];
        if (id != null) return id.toString();
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
      print('❌ [ACTIVIDAD] Error extrayendo ID: $e');
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

      // ✅ GENERAR ID DETERMINÍSTICO
      final validId = _generateConsistentId(robleId);
      final finalId = validId == 0 ? 1 : validId;

      print('✅ [ACTIVIDAD] String convertido: "$robleId" -> $finalId');
      return finalId;
    } catch (e) {
      print('❌ [ACTIVIDAD] Error en conversión: $e');
      return null;
    }
  }

  // ========================================================================
  // FUNCIÓN DETERMINÍSTICA PARA IDs CONSISTENTES
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
