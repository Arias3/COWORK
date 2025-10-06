import '../../../domain/entities/activity.dart';

abstract class IActivitySource {
  Future<List<Activity>> getActivitys();

  Future<bool> addActivity(Activity user);

  Future<bool> updateActivity(Activity user);

  Future<bool> deleteActivity(Activity user);

  Future<bool> deleteActivitys();
}
