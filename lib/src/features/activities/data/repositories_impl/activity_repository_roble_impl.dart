import '../../domain/entities/activity.dart';
import '../../domain/repositories/i_activity_repository.dart';
import '../../../../../core/data/datasources/roble_api_datasource.dart';
import '../models/roble_activity_dto.dart';

class ActivityRepositoryRobleImpl implements IActivityRepository {
  final RobleApiDataSource _dataSource = RobleApiDataSource();
  static const String tableName = 'activities';

  @override
  Future<List<Activity>> getActivities() async {
    try {
      final data = await _dataSource.getAll(tableName);
      return data.map((json) => RobleActivityDto.fromJson(json).toEntity()).toList();
    } catch (e) {
      print('Error obteniendo activities de Roble: $e');
      return [];
    }
  }

  @override
  Future<void> addActivity(Activity activity) async {
    try {
      final dto = RobleActivityDto.fromEntity(activity);
      await _dataSource.create(tableName, dto.toJson());
    } catch (e) {
      print('Error agregando activity en Roble: $e');
      throw Exception('No se pudo agregar la activity: $e');
    }
  }

  @override
  Future<void> updateActivity(Activity activity) async {
    try {
      final dto = RobleActivityDto.fromEntity(activity);
      await _dataSource.update(tableName, activity.id, dto.toJson());
    } catch (e) {
      print('Error actualizando activity en Roble: $e');
      throw Exception('No se pudo actualizar la activity: $e');
    }
  }

  @override
  Future<void> deleteActivity(Activity activity) async {
    try {
      if (activity.id != null) {
        await _dataSource.delete(tableName, activity.id);
      }
    } catch (e) {
      print('Error eliminando activity de Roble: $e');
      throw Exception('No se pudo eliminar la activity: $e');
    }
  }

  @override
  Future<void> deleteActivities() async {
    try {
      final activities = await getActivities();
      for (var activity in activities) {
        await deleteActivity(activity);
      }
    } catch (e) {
      print('Error eliminando todas las activities de Roble: $e');
      throw Exception('No se pudieron eliminar las activities: $e');
    }
  }
}
