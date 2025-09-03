import 'package:get/get.dart';
import 'package:loggy/loggy.dart';

import '../../domain/models/course.dart';
import '../../domain/usecases/course_usecase.dart';

class CourseController extends GetxController {
  final RxList<Course> _courses = <Course>[].obs;
  final CourseUseCase courseUseCase = Get.find();
  final RxBool isLoading = false.obs;
  List<Course> get courses => _courses;

  @override
  void onInit() {
    getCourses();
    super.onInit();
  }

  getCourses() async {
    logInfo("CourseController: Getting Courses");
    isLoading.value = true;
    final result = await courseUseCase.getCourses();
    _courses.assignAll(result);
    isLoading.value = false;
  }

  addCourse(String name, String desc, List<String> members) async {
    logInfo("CourseController: Add Course");
    await courseUseCase.addCourse(name, desc, members.join(','));
    getCourses();
  }

  updateCourse(Course course) async {
    logInfo("CourseController: Update Course");
    await courseUseCase.updateCourse(course);
    await getCourses();
  }

  Future<void> deleteCourse(Course course) async {
    await courseUseCase.deleteCourse(course);
    getCourses();
  }

  void deleteCourses() async {
    logInfo("CourseController: Delete all Courses");
    isLoading.value = true;
    await courseUseCase.deleteCourses();
    await getCourses();
    isLoading.value = false;
  }
}
