import 'package:get/get.dart';
import 'package:hive/hive.dart';

import 'package:cowork_app/src/features/categories/data/repositories/hive_category_repository.dart';
import 'package:cowork_app/src/features/categories/domain/entities/category.dart';

import '../../../src/features/auth/data/repositories/usuario_repository_impl.dart';
import '../../../src/features/home/data/repositories/curso_repository_impl.dart';
import '../../../src/features/home/data/repositories/inscripcion_repository_impl.dart';
import '../../../src/features/auth/domain/repositories/usuario_repository.dart';
import '../../../src/features/home/domain/repositories/curso_repository.dart';
import '../../../src/features/home/domain/repositories/inscripcion_repository.dart';
import '../../../src/features/auth/domain/use_case/usuario_usecase.dart';
import '../../../src/features/home/domain/use_case/curso_usecase.dart';
import '../../../src/features/auth/presentation/controllers/login_controller.dart';
import '../../../src/features/home/presentation/controllers/home_controller.dart';
import '../../../src/features/home/presentation/controllers/enroll_course_controller.dart';
import '../../../src/features/home/presentation/controllers/new_course_controller.dart';

import '../../../src/features/activities/domain/models/activity.dart';
import '../../../src/features/activities/domain/repositories/i_activity_repository.dart';
import '../../../src/features/activities/data/datasources/local/hive_activity_repository.dart';
import '../../../src/features/activities/domain/usecases/activity_usecase.dart';
import '../../../src/features/activities/presentation/controllers/activity_controller.dart';

import '../../../src/features/categories/presentation/controllers/category_controller.dart';
import '../../../src/features/categories/domain/usecases/category_usecases.dart';

class DependencyInjection {
  static Future<void> init() async {
    // ==========================
    // 🔹 Repositorios base
    // ==========================
    Get.lazyPut<UsuarioRepository>(() => UsuarioRepositoryImpl());
    Get.lazyPut<CursoRepository>(() => CursoRepositoryImpl());
    Get.lazyPut<InscripcionRepository>(() => InscripcionRepositoryImpl());

    // ==========================
    // 🔹 Activities con Hive
    // ==========================

    final activityBox = await Hive.openBox<Activity>('activities');
    final activityRepo = ActivityHiveRepository(activityBox);
    Get.put<IActivityRepository>(activityRepo);
    Get.put(ActivityUseCase(Get.find<IActivityRepository>()));
    Get.put(ActivityController());

    // ==========================
    // 🔹 Categories con Hive
    // ==========================
 
    final categoryBox = await Hive.openBox<Category>('categories');
    final categoryRepo = HiveCategoryRepository(categoryBox);
    final categoryUseCases = CategoryUseCases(
      createCategory: CreateCategory(categoryRepo),
      getCategories: GetCategories(categoryRepo),
      getCategoriesByCurso: GetCategoriesByCurso(categoryRepo),
      updateCategory: UpdateCategory(categoryRepo),
      deleteCategory: DeleteCategory(categoryRepo),
    );
    Get.put(CategoryController(categoryUseCases));

    // ==========================
    // 🔹 Use Cases
    // ==========================
    Get.lazyPut(() => UsuarioUseCase(Get.find<UsuarioRepository>()));
    Get.lazyPut(
      () => CursoUseCase(
        Get.find<CursoRepository>(),
        Get.find<InscripcionRepository>(),
      ),
    );

    // ==========================
    // 🔹 Controllers
    // ==========================
    Get.lazyPut(() => AuthenticationController(Get.find<UsuarioUseCase>()));
    Get.lazyPut(
      () => HomeController(
        Get.find<CursoUseCase>(),
        Get.find<AuthenticationController>(),
      ),
    );
    Get.lazyPut(
      () => EnrollCourseController(
        Get.find<CursoUseCase>(),
        Get.find<AuthenticationController>(),
      ),
    );
    Get.lazyPut(
      () => NewCourseController(
        Get.find<CursoUseCase>(),
        Get.find<AuthenticationController>(),
      ),
    );
  }
}
