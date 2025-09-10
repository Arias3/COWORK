import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loggy/loggy.dart';

// Auth
import 'src/features/auth/domain/use_case/authentication_usecase.dart';
import 'src/features/auth/domain/repositories/i_auth_repository.dart';
import 'src/features/auth/data/repositories/dummy_auth_repository.dart'; // 👈 Dummy local
import 'src/features/auth/presentation/controllers/login_controller.dart';

// Auth pages
import 'src/features/auth/presentation/pages/login_page.dart';
import 'src/features/auth/presentation/pages/register_page.dart';

// Home
import 'src/features/home/presentation/pages/home_page.dart';
import 'src/features/home/presentation/pages/new_course_page.dart';
import 'src/features/home/presentation/pages/enroll_course_page.dart';
import 'src/features/home/presentation/controllers/enroll_course_controller.dart';

void main() {
  Loggy.initLoggy(logPrinter: const PrettyPrinter(showColors: true));

  // --- AUTH ---
  // Usamos un repo dummy (con admin/admin) para pruebas locales
  Get.put<IAuthRepository>(AuthRepositoryLocal());
  Get.put(AuthenticationUseCase(Get.find<IAuthRepository>()));
  Get.put(AuthenticationController(Get.find<AuthenticationUseCase>()));

  // --- HOME / ENROLL ---
  Get.put(EnrollCourseController());

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
      debugShowCheckedModeBanner: false,
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
      ],
    );
  }
}
