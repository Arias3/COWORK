import 'package:get/get.dart';
import 'package:flutter/material.dart';

// Import pages
import '../../src/features/auth/presentation/pages/login_page.dart';
import '../../src/features/auth/presentation/pages/register_page.dart';
import '../../src/features/auth/presentation/pages/local_login_page.dart';
import '../../src/features/auth/presentation/pages/local_register_page.dart';
import '../../src/features/home/presentation/pages/home_page.dart';
import '../../src/features/home/presentation/pages/new_course_page.dart';
import '../../src/features/home/presentation/pages/enroll_course_page.dart';
import '../../src/features/categories/presentation/pages/categorias_equipos_page.dart';
import '../../src/features/activities/presentation/pages/activities_page.dart';
import '../../src/features/activities/presentation/pages/activityFormPage.dart';

// Import entities
import '../../src/features/home/domain/entities/curso_entity.dart';
import '../../src/features/activities/domain/entities/activity.dart';

// Import routes
import 'app_routes.dart';

class AppPages {
  static final List<GetPage> pages = [
    // Auth pages
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginPage(),
      transition: Transition.circularReveal,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: AppRoutes.register,
      page: () => const RegisterPage(),
      transition: Transition.circularReveal,
      transitionDuration: const Duration(milliseconds: 500),
    ),

    // Local Auth pages
    GetPage(
      name: AppRoutes.localLogin,
      page: () => const LocalLoginPage(),
      transition: Transition.circularReveal,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: AppRoutes.localRegister,
      page: () => const LocalRegisterPage(),
      transition: Transition.circularReveal,
      transitionDuration: const Duration(milliseconds: 500),
    ),

    // Home pages
    GetPage(name: AppRoutes.home, page: () => const HomePage()),
    GetPage(name: AppRoutes.newCourse, page: () => NewCoursePage()),
    GetPage(name: AppRoutes.enrollCourse, page: () => const EnrollCoursePage()),

    // Categories pages
    GetPage(
      name: AppRoutes.categoriaEquipos,
      page: () {
        final CursoDomain curso = Get.arguments;
        return CategoriasEquiposPage(curso: curso);
      },
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    // Activities pages
    GetPage(
      name: AppRoutes.activities,
      page: () => const ActivityPage(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    // Activity Form page (handles both add and edit)
    GetPage(
      name: AppRoutes.addActivity,
      page: () => _buildActivityFormPage(),
      transition: Transition.downToUp,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    GetPage(
      name: AppRoutes.editActivity,
      page: () => _buildActivityFormPage(isEdit: true),
      transition: Transition.downToUp,
      transitionDuration: const Duration(milliseconds: 300),
    ),
  ];

  /// Helper method to build ActivityFormPage with proper argument handling
  static Widget _buildActivityFormPage({bool isEdit = false}) {
    final args = Get.arguments;

    if (isEdit) {
      // Edit mode: expect a list with Activity as first element
      if (args is List && args.isNotEmpty) {
        final activity = args[0] as Activity;
        return ActivityFormPage(
          categoryId: activity.categoryId,
          activity: activity,
        );
      }
      // Fallback for edit mode
      return const ActivityFormPage(categoryId: 0);
    } else {
      // Add mode: expect a map with 'categoria' key
      int categoryId = 0;

      if (args is Map && args.containsKey('categoria')) {
        final categoria = args['categoria'];
        if (categoria != null && categoria.id != null) {
          categoryId = categoria.id!;
        }
      }

      return ActivityFormPage(categoryId: categoryId);
    }
  }
}
