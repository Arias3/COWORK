import 'package:hive/hive.dart';
import '../../../domain/entities/activity.dart';
import '../../../domain/repositories/i_activity_repository.dart';

class ActivityHiveRepository implements IActivityRepository {
  final Box<Activity> box;

  ActivityHiveRepository(this.box);

  @override
  Future<List<Activity>> getActivities() async {
    return box.values.toList();
  }

  @override
  Future<void> addActivity(Activity activity) async {
    // Usar el ID como clave en lugar de generación automática
    if (activity.id != null) {
      await box.put(activity.id, activity);
    } else {
      // Si no tiene ID, generar uno único
      final newId = DateTime.now().millisecondsSinceEpoch.toString();
      final activityWithId = activity.copyWith(id: newId);
      await box.put(newId, activityWithId);
    }
  }

  @override
  Future<void> updateActivity(Activity activity) async {
    // Usar el ID como clave para actualizar
    if (activity.id != null) {
      await box.put(activity.id, activity);
    } else {
      throw HiveError(
        "❌ No se puede actualizar: el objeto no tiene un ID válido",
      );
    }
  }

  @override
  Future<void> deleteActivity(Activity activity) async {
    // Usar el ID como clave para eliminar
    if (activity.id != null) {
      await box.delete(activity.id);
    } else {
      throw HiveError(
        "❌ No se puede eliminar: el objeto no tiene un ID válido",
      );
    }
  }

  @override
  Future<void> deleteActivities() async {
    await box.clear();
  }
}
