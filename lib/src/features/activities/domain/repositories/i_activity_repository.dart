import '../entities/activity.dart';

abstract class IActivityRepository {
  // ✅ OPERACIONES BÁSICAS CRUD
  Future<List<Activity>> getAllActivities();
  Future<Activity?> getActivityById(int id);
  Future<List<Activity>> getActivitiesByCategoria(int categoriaId);
  Future<int> createActivity(Activity activity);
  Future<void> updateActivity(Activity activity);
  Future<void> deleteActivity(int id);

  // ✅ OPERACIONES ESPECÍFICAS
  Future<List<Activity>> getActiveActivities();
  Future<List<Activity>> getActivitiesInDateRange(
    DateTime inicio,
    DateTime fin,
  );
  Future<void> deactivateActivity(int id);
  Future<void> deleteActivitiesByCategoria(int categoriaId);

  // ✅ BÚSQUEDAS
  Future<List<Activity>> searchActivitiesByName(String query);
  Future<bool> existsActivityInCategory(int categoriaId, String nombre);
}
