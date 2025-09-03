import '../models/activity.dart';
import '../repositories/i_activity_repository.dart';

class ActivityUseCase {
  late IActivityRepository repository;

  ActivityUseCase(this.repository);

  Future<List<Activity>> getActivitys() async => await repository.getActivitys();

  Future<void> addActivity(
          String name, String description, String members) async {
        List<String> membersList = members.split(',').map((e) => e.trim()).toList();
        await repository.addActivity(
          Activity(name: name, description: description, members: membersList),
        );
      }

  Future<void> updateActivity(Activity user) async =>
      await repository.updateActivity(user);

  Future<void> deleteActivity(Activity Activity) async {
  await repository.deleteActivity(Activity);
}

  Future<void> deleteActivitys() async => await repository.deleteActivitys();
}
