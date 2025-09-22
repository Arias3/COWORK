import 'package:get/get.dart';
import '../data/database/hive_helper.dart';

// Repositorios existentes
import '../../src/features/auth/data/repositories/usuario_repository_impl.dart';
import '../../src/features/auth/data/repositories/roble_auth_login_repository_impl.dart';
import '../../src/features/auth/data/repositories/roble_auth_repository_impl.dart';
import '../../src/features/auth/data/datasources/roble_auth_login_datasource.dart';
import '../../src/features/auth/data/datasources/roble_auth_register_datasource.dart';
import '../../src/features/home/data/repositories/curso_repository_impl.dart';
import '../../src/features/home/data/repositories/inscripcion_repository_impl.dart';

// Nuevos repositorios
import '../../src/features/categories/data/repositories/categoria_equipo_repository_impl.dart';
import '../../src/features/categories/data/repositories/equipo_repository_impl.dart';
import '../../src/features/activities/data/datasources/local/hive_activity_repository.dart';

// Interfaces de repositorios existentes
import '../../src/features/auth/domain/repositories/usuario_repository.dart';
import '../../src/features/auth/domain/repositories/roble_auth_login_repository.dart';
import '../../src/features/auth/domain/repositories/roble_auth_repository.dart';
import '../../src/features/home/domain/repositories/curso_repository.dart';
import '../../src/features/home/domain/repositories/inscripcion_repository.dart';

// Nuevas interfaces de repositorios
import '../../src/features/categories/domain/repositories/categoria_equipo_repository.dart';
import '../../src/features/categories/domain/repositories/equipo_repository.dart';
import '../../src/features/activities/domain/repositories/i_activity_repository.dart';

// Casos de uso existentes
import '../../src/features/auth/domain/use_case/usuario_usecase.dart';
import '../../src/features/auth/domain/use_case/roble_auth_login_usecase.dart';
import '../../src/features/auth/domain/use_case/roble_auth_register_usecase.dart';
import '../../src/features/home/domain/use_case/curso_usecase.dart';

// Nuevo caso de uso
import '../../src/features/categories/domain/usecases/categoria_equipo_usecase.dart';
import '../../src/features/activities/domain/usecases/activity_usecase.dart';

// Controladores existentes
import '../../src/features/auth/presentation/controllers/roble_auth_login_controller.dart';
import '../../src/features/auth/presentation/controllers/roble_auth_logout_controller.dart';
import '../../src/features/auth/presentation/controllers/roble_auth_register_controller.dart';
import '../../src/features/home/presentation/controllers/home_controller.dart';
import '../../src/features/home/presentation/controllers/enroll_course_controller.dart';
import '../../src/features/home/presentation/controllers/new_course_controller.dart';

// Nuevo controlador
import '../../src/features/categories/presentation/controllers/categoria_equipo_controller.dart';
import '../../src/features/activities/presentation/controllers/activity_controller.dart';

class DependencyInjection {
  static Future<void> init() async {
    // ========================================================================
    // DATASOURCES DE AUTH
    // ========================================================================
    Get.put<RobleAuthLoginDatasource>(
      RobleAuthLoginDatasource(),
      permanent: true,
    );
    Get.put<RobleAuthDatasource>(RobleAuthDatasource(), permanent: true);

    // ========================================================================
    // REPOSITORIOS EXISTENTES
    // ========================================================================
    Get.put<UsuarioRepository>(UsuarioRepositoryImpl(), permanent: true);
    Get.put<RobleAuthLoginRepository>(
      RobleAuthLoginRepositoryImpl(Get.find<RobleAuthLoginDatasource>()),
      permanent: true,
    );
    Get.put<RobleAuthRepository>(
      RobleAuthRepositoryImpl(Get.find<RobleAuthDatasource>()),
      permanent: true,
    );
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
    // NUEVOS CASOS DE USO DE AUTH
    // ========================================================================
    Get.put<RobleAuthLoginUseCase>(
      RobleAuthLoginUseCase(Get.find()),
      permanent: true,
    );
    Get.put<RobleAuthRegisterUseCase>(
      RobleAuthRegisterUseCase(Get.find()),
      permanent: true,
    );

    // ========================================================================
    // CONTROLADORES DE AUTENTICACIÓN - NUEVOS CONTROLLERS SEPARADOS
    // ========================================================================
    Get.put<RobleAuthLoginController>(
      RobleAuthLoginController(Get.find<RobleAuthLoginUseCase>()),
      permanent: true,
    );

    Get.put<RobleAuthLogoutController>(
      RobleAuthLogoutController(),
      permanent: true,
    );

    Get.put<RobleAuthRegisterController>(
      RobleAuthRegisterController(Get.find<RobleAuthRegisterUseCase>()),
      permanent: true,
    );

    // ========================================================================
    // RESTO DE CONTROLADORES
    // ========================================================================
    Get.lazyPut<HomeController>(
      () => HomeController(
        Get.find<CursoUseCase>(),
        Get.find<RobleAuthLoginController>(), // Nuevo controlador de login
        Get.find<UsuarioUseCase>(),
      ),
      fenix: true,
    );

    Get.lazyPut<EnrollCourseController>(
      () => EnrollCourseController(
        Get.find<CursoUseCase>(),
        Get.find<RobleAuthLoginController>(), // Nuevo controlador de login
      ),
    );

    Get.lazyPut<NewCourseController>(
      () => NewCourseController(
        Get.find<CursoUseCase>(),
        Get.find<RobleAuthLoginController>(), // Nuevo controlador de login
        Get.find<UsuarioUseCase>(),
      ),
      fenix: true,
    );

    // ========================================================================
    // NUEVO CONTROLADOR
    // ========================================================================
    Get.put<CategoriaEquipoController>(
      CategoriaEquipoController(
        Get.find<CategoriaEquipoUseCase>(),
        Get.find<RobleAuthLoginController>(), // Nuevo controlador de login
      ),
    );

    Get.lazyPut<ActivityController>(() => ActivityController());
  }
}
