import '../entities/activity.dart';
import '../repositories/i_activity_repository.dart';

class ActivityUseCase {
  final IActivityRepository _repository;

  ActivityUseCase(this._repository);

  // ===================== OPERACIONES BÁSICAS =====================

  Future<List<Activity>> getAllActivities() async {
    try {
      return await _repository.getAllActivities();
    } catch (e) {
      print('❌ [USECASE] Error obteniendo todas las actividades: $e');
      return [];
    }
  }

  Future<Activity?> getActivityById(int id) async {
    try {
      return await _repository.getActivityById(id);
    } catch (e) {
      print('❌ [USECASE] Error obteniendo actividad por ID: $e');
      return null;
    }
  }

  Future<List<Activity>> getActivitiesByCategoria(int categoriaId) async {
    try {
      return await _repository.getActivitiesByCategoria(categoriaId);
    } catch (e) {
      print('❌ [USECASE] Error obteniendo actividades por categoría: $e');
      return [];
    }
  }

  Future<int> createActivity({
    required int categoriaId,
    required String nombre,
    required String descripcion,
    required DateTime fechaEntrega,
    String? archivoAdjunto,
  }) async {
    try {
      // Validaciones básicas
      if (nombre.trim().isEmpty) {
        throw Exception('El nombre de la actividad es obligatorio');
      }

      if (descripcion.trim().isEmpty) {
        throw Exception('La descripción de la actividad es obligatoria');
      }

      if (fechaEntrega.isBefore(DateTime.now())) {
        throw Exception('La fecha de entrega debe ser futura');
      }

      // Verificar si ya existe una actividad con el mismo nombre en la categoría
      final existeActividad = await _repository.existsActivityInCategory(
        categoriaId,
        nombre.trim(),
      );

      if (existeActividad) {
        throw Exception(
          'Ya existe una actividad con ese nombre en esta categoría',
        );
      }

      final actividad = Activity(
        categoriaId: categoriaId,
        nombre: nombre.trim(),
        descripcion: descripcion.trim(),
        fechaEntrega: fechaEntrega,
        archivoAdjunto: archivoAdjunto?.trim(),
      );

      return await _repository.createActivity(actividad);
    } catch (e) {
      print('❌ [USECASE] Error creando actividad: $e');
      rethrow;
    }
  }

  Future<void> updateActivity({
    required int id,
    String? nombre,
    String? descripcion,
    DateTime? fechaEntrega,
    String? archivoAdjunto,
  }) async {
    try {
      final actividadActual = await _repository.getActivityById(id);
      if (actividadActual == null) {
        throw Exception('Actividad no encontrada');
      }

      // Validaciones si se actualizan
      if (nombre != null && nombre.trim().isEmpty) {
        throw Exception('El nombre de la actividad no puede estar vacío');
      }

      if (descripcion != null && descripcion.trim().isEmpty) {
        throw Exception('La descripción de la actividad no puede estar vacía');
      }

      if (fechaEntrega != null && fechaEntrega.isBefore(DateTime.now())) {
        throw Exception('La fecha de entrega debe ser futura');
      }

      // Verificar nombre duplicado si se cambia el nombre
      if (nombre != null && nombre.trim() != actividadActual.nombre) {
        final existeActividad = await _repository.existsActivityInCategory(
          actividadActual.categoriaId,
          nombre.trim(),
        );

        if (existeActividad) {
          throw Exception(
            'Ya existe una actividad con ese nombre en esta categoría',
          );
        }
      }

      final actividadActualizada = actividadActual.copyWith(
        nombre: nombre?.trim(),
        descripcion: descripcion?.trim(),
        fechaEntrega: fechaEntrega,
        archivoAdjunto: archivoAdjunto?.trim(),
      );

      await _repository.updateActivity(actividadActualizada);
    } catch (e) {
      print('❌ [USECASE] Error actualizando actividad: $e');
      rethrow;
    }
  }

  Future<void> deleteActivity(int id) async {
    try {
      await _repository.deleteActivity(id);
    } catch (e) {
      print('❌ [USECASE] Error eliminando actividad: $e');
      rethrow;
    }
  }

  // ===================== OPERACIONES ESPECÍFICAS =====================

  Future<List<Activity>> getActiveActivities() async {
    try {
      return await _repository.getActiveActivities();
    } catch (e) {
      print('❌ [USECASE] Error obteniendo actividades activas: $e');
      return [];
    }
  }

  Future<List<Activity>> getActivitiesInDateRange(
    DateTime inicio,
    DateTime fin,
  ) async {
    try {
      if (inicio.isAfter(fin)) {
        throw Exception(
          'La fecha de inicio debe ser anterior a la fecha de fin',
        );
      }

      return await _repository.getActivitiesInDateRange(inicio, fin);
    } catch (e) {
      print('❌ [USECASE] Error obteniendo actividades por rango de fechas: $e');
      return [];
    }
  }

  Future<void> deactivateActivity(int id) async {
    try {
      await _repository.deactivateActivity(id);
    } catch (e) {
      print('❌ [USECASE] Error desactivando actividad: $e');
      rethrow;
    }
  }

  Future<void> deleteActivitiesByCategoria(int categoriaId) async {
    try {
      await _repository.deleteActivitiesByCategoria(categoriaId);
    } catch (e) {
      print('❌ [USECASE] Error eliminando actividades por categoría: $e');
      rethrow;
    }
  }

  // ===================== BÚSQUEDAS =====================

  Future<List<Activity>> searchActivitiesByName(String query) async {
    try {
      if (query.trim().isEmpty) {
        return await getAllActivities();
      }

      return await _repository.searchActivitiesByName(query.trim());
    } catch (e) {
      print('❌ [USECASE] Error buscando actividades por nombre: $e');
      return [];
    }
  }

  Future<List<Activity>> getUpcomingActivities({int? days}) async {
    try {
      final ahora = DateTime.now();
      final limite = ahora.add(Duration(days: days ?? 7));

      return await _repository.getActivitiesInDateRange(ahora, limite);
    } catch (e) {
      print('❌ [USECASE] Error obteniendo actividades próximas: $e');
      return [];
    }
  }

  Future<List<Activity>> getOverdueActivities() async {
    try {
      final todasActividades = await _repository.getActiveActivities();
      final ahora = DateTime.now();

      return todasActividades.where((actividad) {
        return actividad.fechaEntrega.isBefore(ahora);
      }).toList();
    } catch (e) {
      print('❌ [USECASE] Error obteniendo actividades vencidas: $e');
      return [];
    }
  }

  // ===================== VALIDACIONES =====================

  Future<bool> canDeleteActivity(int id) async {
    try {
      final actividad = await _repository.getActivityById(id);
      if (actividad == null) return false;

      // Lógica de validación: por ejemplo, no se puede eliminar si ya pasó la fecha de entrega
      final ahora = DateTime.now();
      return actividad.fechaEntrega.isAfter(ahora);
    } catch (e) {
      print('❌ [USECASE] Error validando eliminación de actividad: $e');
      return false;
    }
  }

  Future<bool> isActivityNameAvailable(int categoriaId, String nombre) async {
    try {
      return !(await _repository.existsActivityInCategory(categoriaId, nombre));
    } catch (e) {
      print('❌ [USECASE] Error verificando disponibilidad de nombre: $e');
      return false;
    }
  }

  // ===================== ESTADÍSTICAS =====================

  Future<Map<String, int>> getActivityStats() async {
    try {
      final todasActividades = await _repository.getAllActivities();
      final ahora = DateTime.now();

      final activas = todasActividades.where((a) => a.activo).length;
      final vencidas = todasActividades
          .where((a) => a.activo && a.fechaEntrega.isBefore(ahora))
          .length;
      final proximas = todasActividades
          .where(
            (a) =>
                a.activo &&
                a.fechaEntrega.isAfter(ahora) &&
                a.fechaEntrega.isBefore(ahora.add(Duration(days: 7))),
          )
          .length;

      return {
        'total': todasActividades.length,
        'activas': activas,
        'vencidas': vencidas,
        'proximas': proximas,
      };
    } catch (e) {
      print('❌ [USECASE] Error obteniendo estadísticas: $e');
      return {'total': 0, 'activas': 0, 'vencidas': 0, 'proximas': 0};
    }
  }
}
