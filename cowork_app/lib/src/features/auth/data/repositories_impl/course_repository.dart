import '../../domain/repositories/i_course_repository.dart';
import '../datasources/i_remote_course_source.dart';
import '../../domain/models/course.dart';

class CourseRepository implements ICourseRepository {
  late ICourseSource userSource;

  CourseRepository(this.userSource);

  @override
  Future<List<Course>> getCourses() async => await userSource.getCourses();

  @override
  Future<bool> addCourse(Course user) async =>
      await userSource.addCourse(user);

  @override
  Future<bool> updateCourse(Course user) async =>
      await userSource.updateCourse(user);

  @override
  Future<bool> deleteCourse(Course user) async =>
      await userSource.deleteCourse(user);

  @override
  Future<bool> deleteCourses() async => await userSource.deleteCourses();
}
