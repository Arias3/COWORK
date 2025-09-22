import '../../../domain/entities/activity.dart';
import 'i_remote_activity_source.dart';

class LocalActivitySource implements IActivitySource {
  final List<Activity> _activitys = <Activity>[];

  LocalActivitySource();

  @override
  Future<bool> addActivity(Activity activity) {
    activity.id = DateTime.now().millisecondsSinceEpoch.toString();
    _activitys.add(activity);
    return Future.value(true);
  }

  @override
  Future<bool> deleteActivity(Activity activity) {
    _activitys.remove(activity);
    return Future.value(true);
  }

  @override
  Future<bool> deleteActivitys() {
    _activitys.clear();
    return Future.value(true);
  }

  @override
  Future<List<Activity>> getActivitys() {
    return Future.value(_activitys);
  }

  @override
  Future<bool> updateActivity(Activity activity) {
    var index = _activitys.indexWhere((p) => p.id == activity.id);
    if (index != -1) {
      _activitys[index] = activity;
      return Future.value(true);
    }
    return Future.value(false);
  }
}
