import '../../domain/entities/equipo_actividad_entity.dart';
import '../../domain/repositories/equipo_actividad_repository.dart';
import '../../../../../core/data/datasources/roble_api_datasource.dart';
import '../models/roble_equipo_actividad_dto.dart';
import 'equipo_repository_roble_impl.dart';

class EquipoActividadRepositoryRobleImpl implements EquipoActividadRepository {
  final RobleApiDataSource _dataSource = RobleApiDataSource();
  static const String tableName = 'equipo_actividades';

  // Función auxiliar para convertir DTO a entidad con el equipoId correcto
  EquipoActividad _dtoToEntity(RobleEquipoActividadDto dto, int equipoIdLocal) {
    return EquipoActividad(
      id: dto.id,
      equipoId: equipoIdLocal, // Usamos el ID local en lugar del de Roble
      actividadId: dto.actividadId,
      asignadoEn: DateTime.parse(dto.asignadoEn),
      fechaEntrega: dto.fechaEntrega != null
          ? DateTime.parse(dto.fechaEntrega!)
          : null,
      estado: dto.estado,
      comentarioProfesor: dto.comentarioProfesor,
      calificacion: dto.calificacion,
      fechaCompletada: dto.fechaCompletada != null
          ? DateTime.parse(dto.fechaCompletada!)
          : null,
    );
  }

  @override
  Future<List<EquipoActividad>> getAll() async {
    try {
      final data = await _dataSource.getAll(tableName);
      return data
          .map((json) => RobleEquipoActividadDto.fromJson(json).toEntity())
          .toList();
    } catch (e) {
      print('Error obteniendo equipo_actividades de Roble: $e');
      return [];
    }
  }

  @override
  Future<List<EquipoActividad>> getByEquipoId(int equipoId) async {
    try {
      // Primero, necesitamos obtener el ID de Roble del equipo
      final equipoRepository = EquipoRepositoryRobleImpl();

      // Obtener el ID de Roble del equipo desde el mapeo estático
      final robleEquipoId = equipoRepository.obtenerRobleIdOriginal(equipoId);

      if (robleEquipoId == null) {
        print(
          '❌ [EQUIPO-ACTIVIDAD] No se encontró mapeo Roble para equipo ID: $equipoId',
        );
        return [];
      }

      print(
        '🔍 [EQUIPO-ACTIVIDAD] Consultando actividades para equipo Roble ID: $robleEquipoId (Local ID: $equipoId)',
      );

      final data = await _dataSource.getWhere(
        tableName,
        'equipo_id',
        robleEquipoId,
      );

      print('📊 [EQUIPO-ACTIVIDAD] Actividades encontradas: ${data.length}');

      // Convertir cada JSON a entidad, usando el ID local correcto
      return data.map((json) {
        final dto = RobleEquipoActividadDto.fromJson(json);
        return _dtoToEntity(dto, equipoId); // Usar nuestra función auxiliar
      }).toList();
    } catch (e) {
      print('Error obteniendo actividades por equipo $equipoId: $e');
      return [];
    }
  }

  @override
  Future<List<EquipoActividad>> getByActividadId(String actividadId) async {
    try {
      print(
        '🔍 [EQUIPO-ACTIVIDAD] Buscando equipos para actividad: $actividadId',
      );

      final data = await _dataSource.getWhere(
        tableName,
        'actividad_id',
        actividadId,
      );

      print('📊 [EQUIPO-ACTIVIDAD] Asignaciones encontradas: ${data.length}');

      // Necesitamos convertir los IDs de equipos de Roble a IDs locales
      final equipoRepository = EquipoRepositoryRobleImpl();
      final asignaciones = <EquipoActividad>[];

      for (final json in data) {
        final dto = RobleEquipoActividadDto.fromJson(json);

        // Convertir el ID del equipo de Roble a ID local
        final equipoIdLocal = equipoRepository.obtenerIdLocal(dto.equipoId);

        if (equipoIdLocal != null) {
          final asignacion = _dtoToEntity(dto, equipoIdLocal);
          asignaciones.add(asignacion);
          print(
            '   ✅ Equipo ${dto.equipoId} (Roble) -> $equipoIdLocal (Local)',
          );
        } else {
          print(
            '   ❌ No se encontró mapeo local para equipo Roble: ${dto.equipoId}',
          );
        }
      }

      print(
        '🎯 [EQUIPO-ACTIVIDAD] Asignaciones válidas: ${asignaciones.length}',
      );
      return asignaciones;
    } catch (e) {
      print('Error obteniendo equipos por actividad $actividadId: $e');
      return [];
    }
  }

  @override
  Future<EquipoActividad?> getByEquipoAndActividad(
    int equipoId,
    String actividadId,
  ) async {
    try {
      // Obtener el ID de Roble del equipo
      final equipoRepository = EquipoRepositoryRobleImpl();
      final robleEquipoId = equipoRepository.obtenerRobleIdOriginal(equipoId);

      if (robleEquipoId == null) {
        print(
          '❌ [EQUIPO-ACTIVIDAD] No se encontró mapeo Roble para equipo ID: $equipoId',
        );
        return null;
      }

      // Buscar por equipo_id y después filtrar por actividad_id
      final data = await _dataSource.getWhere(
        tableName,
        'equipo_id',
        robleEquipoId,
      );

      // Filtrar por actividad_id en el resultado
      final filtered = data
          .where((item) => item['actividad_id'] == actividadId)
          .toList();

      if (filtered.isNotEmpty) {
        final dto = RobleEquipoActividadDto.fromJson(filtered.first);
        return _dtoToEntity(dto, equipoId); // Usar nuestra función auxiliar
      }
      return null;
    } catch (e) {
      print(
        'Error buscando asignación equipo $equipoId - actividad $actividadId: $e',
      );
      return null;
    }
  }

  @override
  Future<EquipoActividad> create(EquipoActividad equipoActividad) async {
    try {
      // Obtener el ID de Roble del equipo
      final equipoRepository = EquipoRepositoryRobleImpl();
      final robleEquipoId = equipoRepository.obtenerRobleIdOriginal(
        equipoActividad.equipoId,
      );

      if (robleEquipoId == null) {
        throw Exception(
          'No se encontró mapeo Roble para equipo ID: ${equipoActividad.equipoId}',
        );
      }

      // Crear una copia de la entidad con el ID de Roble
      final equipoActividadParaRoble = EquipoActividad(
        id: equipoActividad.id,
        equipoId:
            equipoActividad.equipoId, // Mantenemos el local para la entidad
        actividadId: equipoActividad.actividadId,
        asignadoEn: equipoActividad.asignadoEn,
        fechaEntrega: equipoActividad.fechaEntrega,
        estado: equipoActividad.estado,
        comentarioProfesor: equipoActividad.comentarioProfesor,
        calificacion: equipoActividad.calificacion,
        fechaCompletada: equipoActividad.fechaCompletada,
      );

      // Crear el DTO pero modificar manualmente el equipoId
      final dto = RobleEquipoActividadDto.fromEntity(equipoActividadParaRoble);
      final jsonData = dto.toJson();
      // Sobrescribir con el ID de Roble
      jsonData['equipo_id'] = robleEquipoId;

      print('🔍 Datos antes de enviar a Roble:');
      print('  Entity.equipoId local: ${equipoActividad.equipoId}');
      print('  Entity.equipoId Roble: $robleEquipoId');
      print('  Entity.asignadoEn: ${equipoActividad.asignadoEn}');
      print('  DTO.asignadoEn: ${dto.asignadoEn}');
      print('  JSON completo: $jsonData');

      final result = await _dataSource.create(tableName, jsonData);

      print('📥 Respuesta de Roble: $result');

      if (result['id'] != null) {
        equipoActividad.id = result['id'];
      }

      return equipoActividad;
    } catch (e) {
      print('Error creando asignación equipo-actividad en Roble: $e');
      throw Exception('No se pudo crear la asignación: $e');
    }
  }

  @override
  Future<EquipoActividad> update(EquipoActividad equipoActividad) async {
    try {
      if (equipoActividad.id == null) {
        throw Exception('ID requerido para actualizar asignación');
      }

      final dto = RobleEquipoActividadDto.fromEntity(equipoActividad);
      await _dataSource.update(tableName, equipoActividad.id!, dto.toJson());

      return equipoActividad;
    } catch (e) {
      print('Error actualizando asignación en Roble: $e');
      throw Exception('No se pudo actualizar la asignación: $e');
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      await _dataSource.delete(tableName, id);
    } catch (e) {
      print('Error eliminando asignación $id de Roble: $e');
      throw Exception('No se pudo eliminar la asignación: $e');
    }
  }

  @override
  Future<void> deleteByEquipoId(int equipoId) async {
    try {
      final asignaciones = await getByEquipoId(equipoId);
      for (final asignacion in asignaciones) {
        if (asignacion.id != null) {
          await delete(asignacion.id!);
        }
      }
    } catch (e) {
      print('Error eliminando asignaciones del equipo $equipoId: $e');
      throw Exception(
        'No se pudieron eliminar las asignaciones del equipo: $e',
      );
    }
  }

  @override
  Future<void> deleteByActividadId(String actividadId) async {
    try {
      final asignaciones = await getByActividadId(actividadId);
      for (final asignacion in asignaciones) {
        if (asignacion.id != null) {
          await delete(asignacion.id!);
        }
      }
    } catch (e) {
      print('Error eliminando asignaciones de la actividad $actividadId: $e');
      throw Exception(
        'No se pudieron eliminar las asignaciones de la actividad: $e',
      );
    }
  }
}
