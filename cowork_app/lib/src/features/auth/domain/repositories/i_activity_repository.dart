import '../models/activity.dart';

abstract class IActivityRepository {
  Future<List<Activity>> getActivitys();

  Future<bool> addActivity(Activity p);

  Future<bool> updateActivity(Activity p);

  Future<bool> deleteActivity(Activity p);

  Future<bool> deleteActivitys();
}
