import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'src/features/auth/presentation/pages/login_page.dart';
import 'src/features/auth/presentation/pages/register_page.dart';
import 'src/features/activities/presentation/pages/activities_page.dart';
import 'src/features/activities/presentation/pages/activityFormPage.dart';
import 'src/features/home/presentation/pages/home_page.dart';
import 'src/features/home/presentation/controllers/enroll_course_controller.dart';
import 'src/features/home/presentation/pages/enroll_course_page.dart';
import 'src/features/home/presentation/pages/new_course_page.dart';
import 'src/features/activities/data/datasources/local/local_activity_source.dart ';
import 'src/features/activities/domain/repositories/i_activity_repository.dart';
import 'src/features/activities/data/repositories_impl/activity_repository.dart';
import 'src/features/activities/domain/usecases/activity_usecase.dart';
import 'src/features/activities/presentation/controllers/activity_controller.dart';
import 'src/features/activities/data/datasources/local/i_remote_activity_source.dart';
import 'src/features/categories/presentation/controllers/category_controller.dart';
import 'src/features/categories/data/repositories/category_repository_mock.dart';
import 'src/features/categories/domain/usecases/category_usecases.dart';
import 'src/features/categories/presentation/pages/category_list_page.dart';

void main() {
  Get.put(EnrollCourseController());

  //Activities

  Get.put<IActivitySource>(LocalActivitySource());
  Get.put<IActivityRepository>(ActivityRepository(Get.find()));
  Get.put(ActivityUseCase(Get.find()));
  Get.put(ActivityController());

  //Categories
  final repo = CategoryRepositoryMock();

  final useCases = CategoryUseCases(
    createCategory: CreateCategory(repo),
    getCategories: GetCategories(repo),
    updateCategory: UpdateCategory(repo),
    deleteCategory: DeleteCategory(repo),
  );

  Get.put(CategoryController(useCases));

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Cowork App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/login',
      getPages: [
        GetPage(
          name: '/login',
          page: () => const LoginPage(),
          transition: Transition.circularReveal,
          transitionDuration: const Duration(milliseconds: 500),
        ),
        GetPage(
          name: '/register',
          page: () => const RegisterPage(),
          transition: Transition.circularReveal,
          transitionDuration: const Duration(milliseconds: 500),
        ),
        GetPage(name: '/home', page: () => HomePage()),
        GetPage(name: '/new-course', page: () => NewCoursePage()),
        GetPage(name: '/enroll-course', page: () => EnrollCoursePage()),
        GetPage(
          name: '/categories',
          page: () => const CategoryListPage(),
          transition: Transition.circularReveal,
          transitionDuration: const Duration(milliseconds: 500),
        ),
        GetPage(
          name: '/activities',
          page: () => const ActivityPage(),
          transition: Transition.circularReveal,
          transitionDuration: const Duration(milliseconds: 500),
        ),
        GetPage(
          name: '/addactivity',
          page: () {
            final args = Get.arguments as Map<String, dynamic>;
            return ActivityFormPage(
              categoryId: args["categoryId"],
              activity: args["activity"], // puede ser null
            );
          },
          transition: Transition.circularReveal,
          transitionDuration: const Duration(milliseconds: 500),
        ),
      ],
    );
  }
}
