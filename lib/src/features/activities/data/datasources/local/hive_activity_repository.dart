import 'package:hive/hive.dart';
import '../../../domain/models/activity.dart';
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
    await box.add(activity);
  }

  @override
  Future<void> updateActivity(Activity activity) async {
    // ✅ Opción 1: Guardar objeto inmutable usando su clave
    if (activity.key != null) {
      await box.put(activity.key, activity);
    } else {
      throw HiveError(
          "❌ No se puede actualizar: el objeto no tiene una clave en Hive");
    }
  }

  @override
  Future<void> deleteActivity(Activity activity) async {
    if (activity.key != null) {
      await box.delete(activity.key);
    } else {
      throw HiveError(
          "❌ No se puede eliminar: el objeto no tiene una clave en Hive");
    }
  }

  @override
  Future<void> deleteActivities() async {
    await box.clear();
  }
}
