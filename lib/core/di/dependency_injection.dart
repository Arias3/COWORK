import 'package:get/get.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../data/database/roble_config.dart';
import '../data/datasources/roble_api_datasource.dart';

// Repositorios Roble (únicos)
import '../../src/features/auth/data/repositories/usuario_repository_roble_impl.dart';
import '../../src/features/home/data/repositories/curso_repository_roble_impl.dart';
import '../../src/features/home/data/repositories/inscripcion_repository_roble_impl.dart';
import '../../src/features/categories/data/repositories/categoria_equipo_repository_roble_impl.dart';
import '../../src/features/categories/data/repositories/equipo_repository_roble_impl.dart';
import '../../src/features/evaluations/data/repositories/evaluacion_periodo_repository_roble_impl.dart';
import '../../src/features/evaluations/data/repositories/evaluacion_individual_repository_roble_impl.dart';
import '../../src/features/categories/data/repositories/equipo_actividad_repository_roble_impl.dart';

// Auth repositories y datasources
import '../../src/features/auth/data/repositories/roble_auth_login_repository_impl.dart';
import '../../src/features/auth/data/repositories/roble_auth_repository_impl.dart';
import '../../src/features/auth/data/datasources/roble_auth_login_datasource.dart';
import '../../src/features/auth/data/datasources/roble_auth_register_datasource.dart';
import '../../src/features/activities/data/repositories_impl/activity_repository_roble_impl.dart';

// Resto de imports existentes...
import '../../src/features/auth/domain/repositories/usuario_repository.dart';
import '../../src/features/auth/domain/repositories/roble_auth_login_repository.dart';
import '../../src/features/auth/domain/repositories/roble_auth_repository.dart';
import '../../src/features/home/domain/repositories/curso_repository.dart';
import '../../src/features/home/domain/repositories/inscripcion_repository.dart';
import '../../src/features/categories/domain/repositories/categoria_equipo_repository.dart';
import '../../src/features/categories/domain/repositories/equipo_repository.dart';
import '../../src/features/categories/domain/repositories/equipo_actividad_repository.dart';
import '../../src/features/activities/domain/repositories/i_activity_repository.dart';
import '../../src/features/evaluations/domain/repositories/evaluacion_periodo_repository.dart';
import '../../src/features/evaluations/domain/repositories/evaluacion_individual_repository.dart';

// Use cases y controllers...
import '../../src/features/auth/domain/use_case/usuario_usecase.dart';
import '../../src/features/auth/domain/use_case/roble_auth_login_usecase.dart';
import '../../src/features/auth/domain/use_case/roble_auth_register_usecase.dart';
import '../../src/features/home/domain/use_case/curso_usecase.dart';
import '../../src/features/categories/domain/usecases/categoria_equipo_usecase.dart';
import '../../src/features/categories/domain/usecases/equipo_actividad_usecase.dart';
import '../../src/features/activities/domain/usecases/activity_usecase.dart';
import '../../src/features/evaluations/domain/usecases/evaluacion_periodo_usecase.dart';
import '../../src/features/evaluations/domain/usecases/evaluacion_individual_usecase.dart';

import '../../src/features/auth/presentation/controllers/roble_auth_login_controller.dart';
import '../../src/features/auth/presentation/controllers/roble_auth_logout_controller.dart';
import '../../src/features/auth/presentation/controllers/roble_auth_register_controller.dart';
import '../../src/features/home/presentation/controllers/home_controller.dart';
import '../../src/features/home/presentation/controllers/enroll_course_controller.dart';
import '../../src/features/home/presentation/controllers/new_course_controller.dart';
import '../../src/features/categories/presentation/controllers/categoria_equipo_controller.dart';
import '../../src/features/activities/presentation/controllers/activity_controller.dart';
import '../../src/features/evaluations/presentation/controllers/evaluacion_periodo_controller.dart';
import '../../src/features/evaluations/presentation/controllers/evaluacion_individual_controller.dart';

class DependencyInjection {
  // Helper para logs compatibles con web
  static void _webSafeLog(String message) {
    if (kIsWeb) {
      // En web, solo usar caracteres ASCII seguros
      final cleanMessage = message.replaceAll(RegExp(r'[^\x00-\x7F]'), '');
      print(cleanMessage);
    } else {
      // En móvil, usar el mensaje original
      print(message);
    }
  }

  static Future<void> init() async {
    _webSafeLog('\n=== INICIANDO DEPENDENCY INJECTION ===');

    // Registrar RobleApiDataSource
    _webSafeLog('Registrando RobleApiDataSource...');
    Get.put<RobleApiDataSource>(RobleApiDataSource(), permanent: true);

    // Registrar datasources de auth
    _webSafeLog('Registrando datasources...');
    Get.put<RobleAuthLoginDatasource>(
      RobleAuthLoginDatasource(),
      permanent: true,
    );
    Get.put<RobleAuthDatasource>(RobleAuthDatasource(), permanent: true);
    _webSafeLog('Datasources registrados');

    // Registrar repositorios según configuración
    await _registerRepositories();

    // Registrar auth repositories
    _webSafeLog('Registrando auth repositories...');
    Get.put<RobleAuthLoginRepository>(
      RobleAuthLoginRepositoryImpl(Get.find<RobleAuthLoginDatasource>()),
      permanent: true,
    );
    Get.put<RobleAuthRepository>(
      RobleAuthRepositoryImpl(Get.find<RobleAuthDatasource>()),
      permanent: true,
    );
    _webSafeLog('Auth repositories registrados');

    // Registrar use cases
    _registerUseCases();

    // Registrar controllers
    _registerControllers();

    _webSafeLog('DEPENDENCY INJECTION COMPLETADO\n');
  }

  static Future<void> _registerRepositories() async {
    _webSafeLog('\n=== DEBUG REPOSITORIOS ===');
    _webSafeLog('RobleConfig.useRoble = ${RobleConfig.useRoble}');
    _webSafeLog('RobleConfig.dataUrl = ${RobleConfig.dataUrl}');
    _webSafeLog('RobleConfig.authUrl = ${RobleConfig.authUrl}');

    // DEBUGGING: Verificar si los repositorios ya están registrados
    try {
      final existingRepo = Get.find<CursoRepository>();
      _webSafeLog(
        'AVISO: CursoRepository ya existe: ${existingRepo.runtimeType}',
      );
      Get.delete<CursoRepository>();
      Get.delete<InscripcionRepository>();
      Get.delete<UsuarioRepository>();
      Get.delete<CategoriaEquipoRepository>();
      Get.delete<EquipoRepository>();
      _webSafeLog('LIMPIEZA: Eliminando repositorios existentes');
    } catch (e) {
      _webSafeLog('OK: No hay repositorios previos registrados');
    }

    // USAR SOLO REPOSITORIOS ROBLE (sin lógica condicional)
    _webSafeLog('INICIO: Registrando repositorios ROBLE únicamente...');

    _webSafeLog('REGISTRO: CursoRepository -> CursoRepositoryRobleImpl');
    Get.put<CursoRepository>(CursoRepositoryRobleImpl(), permanent: true);

    _webSafeLog(
      'REGISTRO: InscripcionRepository -> InscripcionRepositoryRobleImpl',
    );
    Get.put<InscripcionRepository>(
      InscripcionRepositoryRobleImpl(),
      permanent: true,
    );

    _webSafeLog('REGISTRO: UsuarioRepository -> UsuarioRepositoryRobleImpl');
    Get.put<UsuarioRepository>(UsuarioRepositoryRobleImpl(), permanent: true);

    _webSafeLog(
      'REGISTRO: CategoriaEquipoRepository -> CategoriaEquipoRepositoryRobleImpl',
    );
    Get.put<CategoriaEquipoRepository>(
      CategoriaEquipoRepositoryRobleImpl(),
      permanent: true,
    );

    _webSafeLog('REGISTRO: EquipoRepository -> EquipoRepositoryRobleImpl');
    Get.put<EquipoRepository>(EquipoRepositoryRobleImpl(), permanent: true);

    _webSafeLog(
      'REGISTRO: EquipoActividadRepository -> EquipoActividadRepositoryRobleImpl',
    );
    Get.put<EquipoActividadRepository>(
      EquipoActividadRepositoryRobleImpl(),
      permanent: true,
    );

    _webSafeLog(
      'REGISTRO: EvaluacionPeriodoRepository -> EvaluacionPeriodoRepositoryRobleImpl',
    );
    Get.put<EvaluacionPeriodoRepository>(
      EvaluacionPeriodoRepositoryRobleImpl(Get.find<RobleApiDataSource>()),
      permanent: true,
    );

    _webSafeLog(
      'REGISTRO: EvaluacionIndividualRepository -> EvaluacionIndividualRepositoryRobleImpl',
    );
    Get.put<EvaluacionIndividualRepository>(
      EvaluacionIndividualRepositoryRobleImpl(Get.find<RobleApiDataSource>()),
      permanent: true,
    );

    // Activities repository ahora usa Roble
    _webSafeLog('REGISTRO: IActivityRepository -> ActivityRepositoryRobleImpl');
    Get.put<IActivityRepository>(
      ActivityRepositoryRobleImpl(),
      permanent: true,
    );

    _webSafeLog('COMPLETADO: TODOS LOS REPOSITORIOS ROBLE REGISTRADOS');

    // VERIFICACIÓN FINAL
    _webSafeLog('\n=== VERIFICACIÓN FINAL ===');
    final cursoRepo = Get.find<CursoRepository>();
    _webSafeLog('CursoRepository final registrado: ${cursoRepo.runtimeType}');

    final inscripcionRepo = Get.find<InscripcionRepository>();
    _webSafeLog(
      'InscripcionRepository final registrado: ${inscripcionRepo.runtimeType}',
    );

    final usuarioRepo = Get.find<UsuarioRepository>();
    _webSafeLog(
      'UsuarioRepository final registrado: ${usuarioRepo.runtimeType}',
    );

    final categoriaRepo = Get.find<CategoriaEquipoRepository>();
    _webSafeLog(
      'CategoriaEquipoRepository final registrado: ${categoriaRepo.runtimeType}',
    );

    final equipoRepo = Get.find<EquipoRepository>();
    _webSafeLog('EquipoRepository final registrado: ${equipoRepo.runtimeType}');
    _webSafeLog('=== FIN VERIFICACIÓN ===\n');
  }

  static void _registerUseCases() {
    _webSafeLog('Registrando use cases...');
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
    Get.put<CategoriaEquipoUseCase>(
      CategoriaEquipoUseCase(
        Get.find<CategoriaEquipoRepository>(),
        Get.find<EquipoRepository>(),
        Get.find<InscripcionRepository>(),
        Get.find<UsuarioRepository>(),
      ),
      permanent: true,
    );
    Get.put<EquipoActividadUseCase>(
      EquipoActividadUseCase(Get.find<EquipoActividadRepository>()),
      permanent: true,
    );
    Get.put<ActivityUseCase>(
      ActivityUseCase(Get.find<IActivityRepository>()),
      permanent: true,
    );
    Get.put<EvaluacionPeriodoUseCase>(
      EvaluacionPeriodoUseCase(Get.find<EvaluacionPeriodoRepository>()),
      permanent: true,
    );
    Get.put<EvaluacionIndividualUseCase>(
      EvaluacionIndividualUseCase(Get.find<EvaluacionIndividualRepository>()),
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
    print('Use cases registrados');
  }

  static void _registerControllers() {
    _webSafeLog('Registrando controllers...');
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
    Get.lazyPut<EvaluacionPeriodoController>(
      () => EvaluacionPeriodoController(Get.find<EvaluacionPeriodoUseCase>()),
      fenix: true,
    );
    Get.lazyPut<EvaluacionIndividualController>(
      () => EvaluacionIndividualController(
        Get.find<EvaluacionIndividualUseCase>(),
      ),
      fenix: true,
    );
    _webSafeLog('Controllers registrados');
  }
}
