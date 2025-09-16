
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loggy/loggy.dart';


//pages
import 'src/features/auth/presentation/pages/login_page.dart';
import 'src/features/auth/presentation/pages/register_page.dart';
import 'src/features/home/presentation/pages/home_page.dart';
import 'src/features/home/presentation/pages/new_course_page.dart';
import 'src/features/home/presentation/pages/enroll_course_page.dart';
import 'package:cowork_app/src/features/activities/presentation/pages/activities_page.dart';
import 'package:cowork_app/src/features/activities/presentation/pages/activityFormPage.dart';
import 'src/features/categories/presentation/pages/category_list_page.dart';

//dependency injection
import 'core/di/dependency_injection.dart'; 
import 'core/data/database/hive_helper.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await HiveHelper.initHive();
  await DependencyInjection.init();
  Loggy.initLoggy(logPrinter: const PrettyPrinter(showColors: true));


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
