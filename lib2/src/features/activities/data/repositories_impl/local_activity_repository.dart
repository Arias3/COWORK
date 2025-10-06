import '../../domain/entities/activity.dart';
import '../../domain/repositories/i_activity_repository.dart';

class LocalActivityRepository implements IActivityRepository {
  final List<Activity> _activitys = [];

  @override
  Future<List<Activity>> getActivities() async => _activitys;

  @override
  Future<bool> addActivity(Activity activity) async {
    _activitys.add(activity);
    return true;
  }

  @override
  Future<bool> updateActivity(Activity activity) async {
    int index = _activitys.indexWhere((c) => c.id == activity.id);
    if (index != -1) {
      _activitys[index] = activity;
      return true;
    }
    return false;
  }

  @override
  Future<bool> deleteActivity(Activity activity) async {
    _activitys.removeWhere((c) => c.id == activity.id);
    return true;
  }

  @override
  Future<bool> deleteActivities() async {
    _activitys.clear();
    return true;
  }
}
