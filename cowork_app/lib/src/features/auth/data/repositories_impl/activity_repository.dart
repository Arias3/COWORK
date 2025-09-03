import '../../domain/repositories/i_activity_repository.dart';
import '../datasources/i_remote_activity_source.dart';
import '../../domain/models/activity.dart';

class ActivityRepository implements IActivityRepository {
  late IActivitySource userSource;

  ActivityRepository(this.userSource);

  @override
  Future<List<Activity>> getActivitys() async => await userSource.getActivitys();

  @override
  Future<bool> addActivity(Activity user) async =>
      await userSource.addActivity(user);

  @override
  Future<bool> updateActivity(Activity user) async =>
      await userSource.updateActivity(user);

  @override
  Future<bool> deleteActivity(Activity user) async =>
      await userSource.deleteActivity(user);

  @override
  Future<bool> deleteActivitys() async => await userSource.deleteActivitys();
}
