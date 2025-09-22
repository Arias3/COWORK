import '../entities/activity.dart';

abstract class IActivityRepository {
  Future<List<Activity>> getActivities();
  Future<void> addActivity(Activity activity);
  Future<void> updateActivity(Activity activity);
  Future<void> deleteActivity(Activity activity);
  Future<void> deleteActivities();
}
