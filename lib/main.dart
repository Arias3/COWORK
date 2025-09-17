import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Import pages
import 'src/features/auth/presentation/pages/login_page.dart';
import 'src/features/auth/presentation/pages/register_page.dart';
import 'src/features/home/presentation/pages/home_page.dart';
import 'src/features/home/presentation/pages/new_course_page.dart';
import 'src/features/home/presentation/pages/enroll_course_page.dart';
import 'src/features/categories/presentation/pages/categorias_equipos_page.dart'; // NUEVA IMPORTACIÓN

// Import dependency injection
import 'core/di/dependency_injection.dart'; 
import 'core/data/database/hive_helper.dart';
import 'src/features/home/domain/entities/curso_entity.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveHelper.initHive();
  await DependencyInjection.init();
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
        GetPage(name: '/home', page: () => const HomePage()),
        GetPage(name: '/new-course', page: () => NewCoursePage()),
        GetPage(name: '/enroll-course', page: () => const EnrollCoursePage()),
        
        // NUEVA RUTA PARA CATEGORÍAS Y EQUIPOS
        GetPage(
          name: '/categoria-equipos',
          page: () {
            final CursoDomain curso = Get.arguments;
            return CategoriasEquiposPage(curso: curso);
          },
          transition: Transition.rightToLeft,
          transitionDuration: const Duration(milliseconds: 300),
        ),
      ],
    );
  }
}