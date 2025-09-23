import 'package:get/get.dart';
import '../data/database/hive_helper.dart';
import '../data/database/roble_config.dart';

// Repositorios Hive existentes
import '../../src/features/auth/data/repositories/usuario_repository_impl.dart';
import '../../src/features/home/data/repositories/curso_repository_impl.dart';
import '../../src/features/home/data/repositories/inscripcion_repository_impl.dart';
import '../../src/features/categories/data/repositories/categoria_equipo_repository_impl.dart';
import '../../src/features/categories/data/repositories/equipo_repository_impl.dart';

// Repositorios Roble (cuando los tengas creados)
import '../../src/features/auth/data/repositories/usuario_repository_roble_impl.dart';
import '../../src/features/home/data/repositories/curso_repository_roble_impl.dart';
import '../../src/features/home/data/repositories/inscripcion_repository_roble_impl.dart';
import '../../src/features/categories/data/repositories/categoria_equipo_repository_roble_impl.dart';
import '../../src/features/categories/data/repositories/equipo_repository_roble_impl.dart';

// 🆕 REPOSITORIO HÍBRIDO
import '../../src/features/home/data/repositories/curso_repository_hybrid_impl.dart';

// Auth repositories y datasources
import '../../src/features/auth/data/repositories/roble_auth_login_repository_impl.dart';
import '../../src/features/auth/data/repositories/roble_auth_repository_impl.dart';
import '../../src/features/auth/data/datasources/roble_auth_login_datasource.dart';
import '../../src/features/auth/data/datasources/roble_auth_register_datasource.dart';
import '../../src/features/activities/data/datasources/local/hive_activity_repository.dart';

// Resto de imports existentes...
import '../../src/features/auth/domain/repositories/usuario_repository.dart';
import '../../src/features/auth/domain/repositories/roble_auth_login_repository.dart';
import '../../src/features/auth/domain/repositories/roble_auth_repository.dart';
import '../../src/features/home/domain/repositories/curso_repository.dart';
import '../../src/features/home/domain/repositories/inscripcion_repository.dart';
import '../../src/features/categories/domain/repositories/categoria_equipo_repository.dart';
import '../../src/features/categories/domain/repositories/equipo_repository.dart';
import '../../src/features/activities/domain/repositories/i_activity_repository.dart';

// Use cases y controllers...
import '../../src/features/auth/domain/use_case/usuario_usecase.dart';
import '../../src/features/auth/domain/use_case/roble_auth_login_usecase.dart';
import '../../src/features/auth/domain/use_case/roble_auth_register_usecase.dart';
import '../../src/features/home/domain/use_case/curso_usecase.dart';
import '../../src/features/categories/domain/usecases/categoria_equipo_usecase.dart';
import '../../src/features/activities/domain/usecases/activity_usecase.dart';

import '../../src/features/auth/presentation/controllers/roble_auth_login_controller.dart';
import '../../src/features/auth/presentation/controllers/roble_auth_logout_controller.dart';
import '../../src/features/auth/presentation/controllers/roble_auth_register_controller.dart';
import '../../src/features/home/presentation/controllers/home_controller.dart';
import '../../src/features/home/presentation/controllers/enroll_course_controller.dart';
import '../../src/features/home/presentation/controllers/new_course_controller.dart';
import '../../src/features/categories/presentation/controllers/categoria_equipo_controller.dart';
import '../../src/features/activities/presentation/controllers/activity_controller.dart';

class DependencyInjection {
  static Future<void> init() async {
    print('\n🔧 === INICIANDO DEPENDENCY INJECTION ===');
    
    // Registrar datasources de auth
    print('📡 Registrando datasources...');
    Get.put<RobleAuthLoginDatasource>(RobleAuthLoginDatasource(), permanent: true);
    Get.put<RobleAuthDatasource>(RobleAuthDatasource(), permanent: true);
    print('✅ Datasources registrados');

    // Registrar repositorios según configuración
    await _registerRepositories();

    // Registrar auth repositories
    print('🔐 Registrando auth repositories...');
    Get.put<RobleAuthLoginRepository>(
      RobleAuthLoginRepositoryImpl(Get.find<RobleAuthLoginDatasource>()),
      permanent: true,
    );
    Get.put<RobleAuthRepository>(
      RobleAuthRepositoryImpl(Get.find<RobleAuthDatasource>()),
      permanent: true,
    );
    print('✅ Auth repositories registrados');

    // Registrar use cases
    _registerUseCases();

    // Registrar controllers
    _registerControllers();
    
    print('✅ DEPENDENCY INJECTION COMPLETADO\n');
  }

  static Future<void> _registerRepositories() async {
    print('\n🔍 === DEBUG REPOSITORIOS ===');
    print('RobleConfig.useRoble = ${RobleConfig.useRoble}');
    print('RobleConfig.dataUrl = ${RobleConfig.dataUrl}');
    print('RobleConfig.authUrl = ${RobleConfig.authUrl}');
    
    // DEBUGGING: Verificar si los repositorios ya están registrados
    try {
      final existingRepo = Get.find<CursoRepository>();
      print('⚠️ CursoRepository ya existe: ${existingRepo.runtimeType}');
      Get.delete<CursoRepository>();
      print('🗑️ Eliminando repositorio existente');
    } catch (e) {
      print('✅ No hay repositorio previo registrado');
    }
    
    // 🆕 LÓGICA HÍBRIDA: Siempre usar híbrido cuando Roble esté activado
    if (RobleConfig.useRoble) {
      print('🔄 CONDICIÓN: Usando Roble - Registrando repositorios HÍBRIDOS...');
      
      // 🚀 USAR REPOSITORIO HÍBRIDO PARA CURSOS
      print('🔄 Registrando CursoRepository -> CursoRepositoryHybridImpl (Roble + Hive)');
      Get.put<CursoRepository>(CursoRepositoryHybridImpl(), permanent: true);
      
      // Resto de repositorios Roble
      print('📝 Registrando InscripcionRepository -> InscripcionRepositoryRobleImpl');  
      Get.put<InscripcionRepository>(InscripcionRepositoryRobleImpl(), permanent: true);
      
      print('📝 Registrando UsuarioRepository -> UsuarioRepositoryRobleImpl');
      Get.put<UsuarioRepository>(UsuarioRepositoryRobleImpl(), permanent: true);
      
      print('📝 Registrando CategoriaEquipoRepository -> CategoriaEquipoRepositoryRobleImpl');
      Get.put<CategoriaEquipoRepository>(CategoriaEquipoRepositoryRobleImpl(), permanent: true);
      
      print('📝 Registrando EquipoRepository -> EquipoRepositoryRobleImpl');
      Get.put<EquipoRepository>(EquipoRepositoryRobleImpl(), permanent: true);
      
      // Activities repository sigue siendo Hive por ahora
      print('📝 Registrando IActivityRepository -> ActivityHiveRepository (temporal)');
      Get.put<IActivityRepository>(
        ActivityHiveRepository(HiveHelper.activitiesBoxInstance),
        permanent: true,
      );
      
      print('🔄 ✅ TODOS LOS REPOSITORIOS HÍBRIDOS/ROBLE REGISTRADOS');
    } else {
      print('💾 CONDICIÓN: NO usando Roble - Registrando repositorios Hive...');
      _registerHiveRepositories();
    }
    
    // VERIFICACIÓN FINAL
    print('\n🔍 === VERIFICACIÓN FINAL ===');
    final cursoRepo = Get.find<CursoRepository>();
    print('CursoRepository final registrado: ${cursoRepo.runtimeType}');
    
    final inscripcionRepo = Get.find<InscripcionRepository>();
    print('InscripcionRepository final registrado: ${inscripcionRepo.runtimeType}');
    
    final usuarioRepo = Get.find<UsuarioRepository>();
    print('UsuarioRepository final registrado: ${usuarioRepo.runtimeType}');
    print('=== FIN VERIFICACIÓN ===\n');
  }

  static void _registerHiveRepositories() {
    print('📝 Registrando repositorios Hive...');
    Get.put<UsuarioRepository>(UsuarioRepositoryImpl(), permanent: true);
    Get.put<CursoRepository>(CursoRepositoryImpl(), permanent: true);
    Get.put<InscripcionRepository>(InscripcionRepositoryImpl(), permanent: true);
    Get.put<CategoriaEquipoRepository>(CategoriaEquipoRepositoryImpl(), permanent: true);
    Get.put<EquipoRepository>(EquipoRepositoryImpl(), permanent: true);
    Get.put<IActivityRepository>(
      ActivityHiveRepository(HiveHelper.activitiesBoxInstance),
      permanent: true,
    );
    print('✅ Repositorios Hive registrados');
  }

  // 🆕 MÉTODO PARA FORZAR SINCRONIZACIÓN MANUAL
  static Future<void> syncOfflineData() async {
    try {
      print('🔄 Iniciando sincronización manual...');
      
      final cursoRepo = Get.find<CursoRepository>();
      if (cursoRepo is CursoRepositoryHybridImpl) {
        await cursoRepo.syncOfflineCursos();
        print('✅ Sincronización de cursos completada');
      } else {
        print('⚠️ Repositorio actual no es híbrido, saltando sincronización');
      }
    } catch (e) {
      print('❌ Error en sincronización: $e');
    }
  }

  static void _registerUseCases() {
    print('🎯 Registrando use cases...');
    Get.put<UsuarioUseCase>(
      UsuarioUseCase(Get.find<UsuarioRepository>()),
      permanent: true,
    );
    Get.put<CursoUseCase>(
      CursoUseCase(Get.find<CursoRepository>(), Get.find<InscripcionRepository>()),
      permanent: true,
    );
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
    Get.put<RobleAuthLoginUseCase>(
      RobleAuthLoginUseCase(Get.find()),
      permanent: true,
    );
    Get.put<RobleAuthRegisterUseCase>(
      RobleAuthRegisterUseCase(Get.find()),
      permanent: true,
    );
    print('✅ Use cases registrados');
  }

  static void _registerControllers() {
    print('🎮 Registrando controllers...');
    Get.put<RobleAuthLoginController>(
  RobleAuthLoginController(Get.find<RobleAuthLoginUseCase>()),
  permanent: true,
);


    Get.put<RobleAuthLogoutController>(RobleAuthLogoutController(), permanent: true);
    Get.put<RobleAuthRegisterController>(
      RobleAuthRegisterController(Get.find<RobleAuthRegisterUseCase>()),
      permanent: true,
    );

    Get.lazyPut<HomeController>(
      () => HomeController(
        Get.find<CursoUseCase>(),
        Get.find<RobleAuthLoginController>(),
        Get.find<UsuarioUseCase>(),
      ),
      fenix: true,
    );
    Get.lazyPut<EnrollCourseController>(
      () => EnrollCourseController(
        Get.find<CursoUseCase>(),
        Get.find<RobleAuthLoginController>(),
      ),
    );
    Get.lazyPut<NewCourseController>(
      () => NewCourseController(
        Get.find<CursoUseCase>(),
        Get.find<RobleAuthLoginController>(),
        Get.find<UsuarioUseCase>(),
      ),
      fenix: true,
    );
    Get.put<CategoriaEquipoController>(
      CategoriaEquipoController(
        Get.find<CategoriaEquipoUseCase>(),
        Get.find<RobleAuthLoginController>(),
      ),
    );
    Get.lazyPut<ActivityController>(() => ActivityController());
    print('✅ Controllers registrados');
  }
}