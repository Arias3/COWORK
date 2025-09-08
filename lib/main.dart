import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'src/features/auth/presentation/pages/login_page.dart';
import 'src/features/auth/presentation/pages/register_page.dart';

import 'src/features/home/presentation/pages/home_page.dart';
import 'src/features/home/presentation/pages/new_course_page.dart';
import 'src/features/home/presentation/pages/enroll_course_page.dart';
import 'src/features/home/presentation/controllers/enroll_course_controller.dart';

void main() {
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
