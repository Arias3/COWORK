import '../../domain/models/course.dart';

abstract class ICourseSource {
  Future<List<Course>> getCourses();

  Future<bool> addCourse(Course user);

  Future<bool> updateCourse(Course user);

  Future<bool> deleteCourse(Course user);

  Future<bool> deleteCourses();
}
