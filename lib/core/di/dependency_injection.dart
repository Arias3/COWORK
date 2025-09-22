import 'package:get/get.dart';
import '../data/database/hive_helper.dart';

// Repositorios existentes
import '../../src/features/auth/data/repositories/usuario_repository_impl.dart';
import '../../src/features/home/data/repositories/curso_repository_impl.dart';
import '../../src/features/home/data/repositories/inscripcion_repository_impl.dart';

// Nuevos repositorios
import '../../src/features/categories/data/repositories/categoria_equipo_repository_impl.dart';
import '../../src/features/categories/data/repositories/equipo_repository_impl.dart';
import '../../src/features/activities/data/datasources/local/hive_activity_repository.dart';

// Interfaces de repositorios existentes
import '../../src/features/auth/domain/repositories/usuario_repository.dart';
import '../../src/features/home/domain/repositories/curso_repository.dart';
import '../../src/features/home/domain/repositories/inscripcion_repository.dart';

// Nuevas interfaces de repositorios
import '../../src/features/categories/domain/repositories/categoria_equipo_repository.dart';
import '../../src/features/categories/domain/repositories/equipo_repository.dart';
import '../../src/features/activities/domain/repositories/i_activity_repository.dart';

// Casos de uso existentes
import '../../src/features/auth/domain/use_case/usuario_usecase.dart';
import '../../src/features/home/domain/use_case/curso_usecase.dart';

// Nuevo caso de uso
import '../../src/features/categories/domain/use_case/categoria_equipo_usecase.dart';
import '../../src/features/activities/domain/usecases/activity_usecase.dart';

// Controladores existentes
import '../../src/features/auth/presentation/controllers/login_controller.dart';
import '../../src/features/home/presentation/controllers/home_controller.dart';
import '../../src/features/home/presentation/controllers/enroll_course_controller.dart';
import '../../src/features/home/presentation/controllers/new_course_controller.dart';

// Nuevo controlador
import '../../src/features/categories/presentation/controllers/categoria_equipo_controller.dart';
import '../../src/features/activities/presentation/controllers/activity_controller.dart';

class DependencyInjection {
  static Future<void> init() async {
    // ========================================================================
    // REPOSITORIOS EXISTENTES
    // ========================================================================
    Get.put<UsuarioRepository>(UsuarioRepositoryImpl(), permanent: true);
    Get.put<CursoRepository>(CursoRepositoryImpl(), permanent: true);
    Get.put<InscripcionRepository>(
      InscripcionRepositoryImpl(),
      permanent: true,
    );

    // ========================================================================
    // NUEVOS REPOSITORIOS
    // ========================================================================
    Get.put<CategoriaEquipoRepository>(
      CategoriaEquipoRepositoryImpl(),
      permanent: true,
    );

    // Activities dependencies
    Get.put<IActivityRepository>(
      ActivityHiveRepository(HiveHelper.activitiesBoxInstance),
      permanent: true,
    );
    Get.put<EquipoRepository>(EquipoRepositoryImpl(), permanent: true);

    // ========================================================================
    // CASOS DE USO EXISTENTES
    // ========================================================================
    Get.put<UsuarioUseCase>(
      UsuarioUseCase(Get.find<UsuarioRepository>()),
      permanent: true,
    );
    Get.put<CursoUseCase>(
      CursoUseCase(
        Get.find<CursoRepository>(),
        Get.find<InscripcionRepository>(),
      ),
      permanent: true,
    );

    // ========================================================================
    // NUEVO CASO DE USO
    // ========================================================================
    Get.put<CategoriaEquipoUseCase>(
      CategoriaEquipoUseCase(
        Get.find<CategoriaEquipoRepository>(),
        Get.find<EquipoRepository>(),
        Get.find<InscripcionRepository>(),
        Get.find<UsuarioRepository>(),
      ),
      permanent: true,
    );

    Get.put<ActivityUseCase>(
      ActivityUseCase(Get.find<IActivityRepository>()),
      permanent: true,
    );

    // ========================================================================
    // CONTROLADOR CRÍTICO - AuthenticationController DEBE ir PRIMERO como Put
    // ========================================================================
    // CAMBIO PRINCIPAL: De lazyPut a put con permanent: true
    Get.put<AuthenticationController>(
      AuthenticationController(Get.find<UsuarioUseCase>()),
      permanent: true,
    );

    // ========================================================================
    // RESTO DE CONTROLADORES
    // ========================================================================
    Get.lazyPut<HomeController>(
      () => HomeController(
        Get.find<CursoUseCase>(),
        Get.find<AuthenticationController>(), // Ahora ya existe
        Get.find<UsuarioUseCase>(),
      ),
      fenix: true,
    );

    Get.lazyPut<EnrollCourseController>(
      () => EnrollCourseController(
        Get.find<CursoUseCase>(),
        Get.find<AuthenticationController>(), // Ahora ya existe
      ),
    );

    Get.lazyPut<NewCourseController>(
      () => NewCourseController(
        Get.find<CursoUseCase>(),
        Get.find<AuthenticationController>(), // Ahora ya existe
        Get.find<UsuarioUseCase>(),
      ),
      fenix: true,
    );

    // ========================================================================
    // NUEVO CONTROLADOR
    // ========================================================================
    Get.lazyPut<CategoriaEquipoController>(
      () => CategoriaEquipoController(
        Get.find<CategoriaEquipoUseCase>(),
        Get.find<AuthenticationController>(), // Ahora ya existe
      ),
    );

    Get.lazyPut<ActivityController>(() => ActivityController());
  }
}
