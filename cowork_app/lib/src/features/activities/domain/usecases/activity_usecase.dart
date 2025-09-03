import '../../../activities/domain/models/activity.dart';
import '../repositories/i_activity_repository.dart';

class ActivityUseCase {
  late IActivityRepository repository;

  ActivityUseCase(this.repository);

  Future<List<Activity>> getActivitys() async =>
      await repository.getActivitys();

  Future<void> addActivity(
    String name,
    String description,
    List<String> members,
    DateTime deliveryDate,
  ) async {
    await repository.addActivity(
      Activity(
        name: name,
        description: description,
        members: members,
        delivery_date: deliveryDate,
      ),
    );
  }

  Future<void> updateActivity(Activity activity) async =>
      await repository.updateActivity(activity);

  Future<void> deleteActivity(Activity activity) async {
    await repository.deleteActivity(activity);
  }

  Future<void> deleteActivitys() async => await repository.deleteActivitys();
}
