import 'package:get/get.dart';
import 'package:loggy/loggy.dart';

import '../../domain/models/activity.dart';
import '../../domain/usecases/activity_usecase.dart';

class ActivityController extends GetxController {
  final RxList<Activity> _activitys = <Activity>[].obs;
  final ActivityUseCase activityUseCase = Get.find();
  final RxBool isLoading = false.obs;
  List<Activity> get activitys => _activitys;

  @override
  void onInit() {
    getActivitys();
    super.onInit();
  }

  getActivitys() async {
    logInfo("ActivityController: Getting Activitys");
    isLoading.value = true;
    final result = await activityUseCase.getActivitys();
    _activitys.assignAll(result);
    isLoading.value = false;
  }

  addActivity(String name, String desc, List<String> members) async {
    logInfo("ActivityController: Add Activity");
    await activityUseCase.addActivity(name, desc, members.join(','));
    getActivitys();
  }

  updateActivity(Activity Activity) async {
    logInfo("ActivityController: Update Activity");
    await activityUseCase.updateActivity(Activity);
    await getActivitys();
  }

  Future<void> deleteActivity(Activity Activity) async {
    await activityUseCase.deleteActivity(Activity);
    getActivitys();
  }

  void deleteActivitys() async {
    logInfo("ActivityController: Delete all Activitys");
    isLoading.value = true;
    await activityUseCase.deleteActivitys();
    await getActivitys();
    isLoading.value = false;
  }
}
