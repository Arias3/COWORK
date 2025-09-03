import '../models/course.dart';

abstract class ICourseRepository {
  Future<List<Course>> getCourses();

  Future<bool> addCourse(Course p);

  Future<bool> updateCourse(Course p);

  Future<bool> deleteCourse(Course p);

  Future<bool> deleteCourses();
}
