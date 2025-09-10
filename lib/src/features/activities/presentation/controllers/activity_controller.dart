// ignore_for_file: unnecessary_overrides

import 'package:get/get.dart';
import 'package:loggy/loggy.dart';

import '../../../activities/domain/models/activity.dart';
import '../../domain/usecases/activity_usecase.dart';

class ActivityController extends GetxController {
  final RxList<Activity> _activities = <Activity>[].obs;
  final ActivityUseCase activityUseCase = Get.find();
  final RxBool isLoading = false.obs;

  List<Activity> get activities => _activities;

  /// Guardamos el categoryId actual para filtrar actividades
  int? currentCategoryId;

  @override
  void onInit() {
    super.onInit();
    // ⚠️ No cargamos nada aún hasta que tengamos un categoryId
  }

  /// Cargar actividades, opcionalmente filtradas por categoría
  Future<void> getActivities({int? categoryId}) async {
    logInfo("ActivityController: Getting activities");
    isLoading.value = true;

    currentCategoryId = categoryId ?? currentCategoryId;

    final result = await activityUseCase.getActivities(
      categoryId: currentCategoryId,
    );

    _activities.assignAll(result);
    isLoading.value = false;
  }

  Future<void> addActivity(
    int categoryId, // 🔹 obligatorio ahora
    String name,
    String desc,
    DateTime deliveryDate,
  ) async {
    logInfo("ActivityController: Add Activity");
    await activityUseCase.addActivity(categoryId, name, desc, deliveryDate);
    await getActivities(
      categoryId: categoryId,
    ); // 🔹 refresca solo esa categoría
  }

  Future<void> updateActivity(Activity activity) async {
    logInfo("ActivityController: Update Activity");
    await activityUseCase.updateActivity(activity);
    await getActivities(categoryId: activity.categoryId);
  }

  Future<void> deleteActivity(Activity activity) async {
    logInfo("ActivityController: Delete Activity");
    await activityUseCase.deleteActivity(activity);
    await getActivities(categoryId: activity.categoryId);
  }

  Future<void> deleteActivities({int? categoryId}) async {
    logInfo("ActivityController: Delete all activities");
    isLoading.value = true;
    await activityUseCase.deleteActivities();
    await getActivities(categoryId: categoryId);
    isLoading.value = false;
  }
}
