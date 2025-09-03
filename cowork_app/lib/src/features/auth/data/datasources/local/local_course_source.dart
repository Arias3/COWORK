import '../../../domain/models/course.dart';
import '../i_remote_course_source.dart';

class LocalCourseSource implements ICourseSource {
  final List<Course> _courses = <Course>[];

  LocalCourseSource();

  @override
  Future<bool> addCourse(Course course) {
    course.id = DateTime.now().millisecondsSinceEpoch.toString();
    _courses.add(course);
    return Future.value(true);
  }

  @override
  Future<bool> deleteCourse(Course course) {
    _courses.remove(course);
    return Future.value(true);
  }

  @override
  Future<bool> deleteCourses() {
    _courses.clear();
    return Future.value(true);
  }

  @override
  Future<List<Course>> getCourses() {
    return Future.value(_courses);
  }

  @override
  Future<bool> updateCourse(Course course) {
    var index = _courses.indexWhere((p) => p.id == course.id);
    if (index != -1) {
      _courses[index] = course;
      return Future.value(true);
    }
    return Future.value(false);
  }
}
