import '../entities/activity.dart';
import '../repositories/i_activity_repository.dart';

class ActivityUseCase {
  final IActivityRepository repository;

  ActivityUseCase(this.repository);

  Future<List<Activity>> getActivities({int? categoryId}) async {
    final activities = await repository.getActivities();
    // 🔹 Si se pasa un categoryId, filtramos
    if (categoryId != null) {
      return activities.where((a) => a.categoryId == categoryId).toList();
    }
    return activities;
  }

  Future<void> addActivity(
    int categoryId, // 🔹 agregado
    String name,
    String description,
    DateTime deliveryDate,
  ) async {
    // Generar ID único basado en timestamp
    final id = DateTime.now().millisecondsSinceEpoch.toString();

    await repository.addActivity(
      Activity(
        id: id, // 🔹 Asignar ID único
        categoryId: categoryId, // 🔹 necesario
        name: name,
        description: description,
        deliveryDate: deliveryDate,
      ),
    );
  }

  Future<void> updateActivity(Activity activity) async =>
      await repository.updateActivity(activity);

  Future<void> deleteActivity(Activity activity) async =>
      await repository.deleteActivity(activity);

  Future<void> deleteActivities() async => await repository.deleteActivities();
}
