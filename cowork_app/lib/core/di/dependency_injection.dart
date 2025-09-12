import 'package:get/get.dart';
import '../data/database/hive_helper.dart';
import '../../../src/features/auth/data/repositories/usuario_repository_impl.dart';
import '../../../src/features/home/data/repositories/curso_repository_impl.dart';
import '../../../src/features/home/data/repositories/inscripcion_repository_impl.dart';
import '../../../src/features/auth/domain/repositories/usuario_repository.dart';
import '../../../src/features/home/domain/repositories/curso_repository.dart';
import '../../../src/features/home/domain/repositories/inscripcion_repository.dart';
import '../../../src/features/auth/domain/use_case/usuario_usecase.dart';
import '../../../src/features/home/domain/use_case/curso_usecase.dart'; // Corregido: era "feature" en lugar de "features"
import '../../../src/features/auth/presentation/controllers/login_controller.dart';
import '../../../src/features/home/presentation/controllers/home_controller.dart';
import '../../../src/features/home/presentation/controllers/enroll_course_controller.dart';
import '../../../src/features/home/presentation/controllers/new_course_controller.dart';

class DependencyInjection {
  static Future<void> init() async {

    // Repositories
    Get.lazyPut<UsuarioRepository>(() => UsuarioRepositoryImpl());
    Get.lazyPut<CursoRepository>(() => CursoRepositoryImpl());
    Get.lazyPut<InscripcionRepository>(() => InscripcionRepositoryImpl());

    // Use Cases
    Get.lazyPut(() => UsuarioUseCase(Get.find<UsuarioRepository>()));
    Get.lazyPut(() => CursoUseCase(
      Get.find<CursoRepository>(),
      Get.find<InscripcionRepository>(),
    ));

    // Controllers
    Get.lazyPut(() => AuthenticationController(Get.find<UsuarioUseCase>()));
    Get.lazyPut(() => HomeController(
      Get.find<CursoUseCase>(),
      Get.find<AuthenticationController>(),
    ));
    Get.lazyPut(() => EnrollCourseController(
      Get.find<CursoUseCase>(),
      Get.find<AuthenticationController>(), // Agregado parámetro faltante
    ));
    Get.lazyPut(() => NewCourseController(
      Get.find<CursoUseCase>(),
      Get.find<AuthenticationController>(),
    ));
  }
}