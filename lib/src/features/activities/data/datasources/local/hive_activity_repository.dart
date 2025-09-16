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
    await activity.save(); // HiveObject lo permite directamente
  }

  @override
  Future<void> deleteActivity(Activity activity) async {
    await activity.delete();
  }

  @override
  Future<void> deleteActivities() async {
    await box.clear();
  }
}
