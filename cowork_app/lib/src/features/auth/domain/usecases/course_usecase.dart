import '../models/course.dart';
import '../repositories/i_course_repository.dart';

class CourseUseCase {
  late ICourseRepository repository;

  CourseUseCase(this.repository);

  Future<List<Course>> getCourses() async => await repository.getCourses();

  Future<void> addCourse(
          String name, String description, String members) async {
        List<String> membersList = members.split(',').map((e) => e.trim()).toList();
        await repository.addCourse(
          Course(name: name, description: description, members: membersList),
        );
      }

  Future<void> updateCourse(Course user) async =>
      await repository.updateCourse(user);

  Future<void> deleteCourse(Course course) async {
  await repository.deleteCourse(course);
}

  Future<void> deleteCourses() async => await repository.deleteCourses();
}
