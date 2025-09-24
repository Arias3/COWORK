import 'package:get/get.dart';
import '../../domain/use_case/roble_auth_login_usecase.dart';
import '../../domain/use_case/usuario_usecase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/datasources/roble_auth_refresh_token_datasource.dart';
import '../../data/datasources/roble_auth_logout_datasource.dart';
import '../../data/datasources/roble_auth_users_datasource.dart';
import '../../domain/entities/user_entity.dart';
import '../../../activities/presentation/controllers/activity_controller.dart';
import '../../../evaluations/presentation/controllers/evaluacion_controller.dart';
import '../../../categories/presentation/controllers/categoria_equipo_controller.dart';
import 'dart:async';

class RobleAuthLoginController extends GetxController {
  final RobleAuthLoginUseCase useCase;
  final RobleAuthRefreshTokenDatasource refreshDatasource =
      RobleAuthRefreshTokenDatasource();
  final RobleAuthLogoutDatasource logoutDatasource =
      RobleAuthLogoutDatasource();
  final RobleAuthUsersDatasource usersDatasource = RobleAuthUsersDatasource();
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final accessToken = ''.obs;
  final refreshToken = ''.obs;
  final currentUser = Rxn<Usuario>();

  Timer? _refreshTimer;

  RobleAuthLoginController(this.useCase);

  @override
  void onInit() {
    super.onInit();
    // Inicia el timer para refrescar el token cada 10 minutos
    _refreshTimer = Timer.periodic(const Duration(minutes: 10), (timer) async {
      await refreshAccessTokenIfNeeded();
    });
  }

  @override
  void onClose() {
    _refreshTimer?.cancel();
    super.onClose();
  }

  Future<bool> login({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final result = await useCase.call(email: email, password: password);
      accessToken.value = result['accessToken'] ?? '';
      refreshToken.value = result['refreshToken'] ?? '';

      // Siempre guardar tokens
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('accessToken', accessToken.value);
      await prefs.setString('refreshToken', refreshToken.value);

      // Solo guardar credenciales si "Recuérdame" está activo
      if (rememberMe) {
        await saveCredentials(email, password);
      } else {
        // Limpiar credenciales guardadas si "Recuérdame" no está activo
        await prefs.remove('savedEmail');
        await prefs.remove('savedPassword');
      }

      // Guardar información del usuario
      if (result['user'] != null) {
        final userData = result['user'] as Map<String, dynamic>;
        print('🔍 Datos de usuario recibidos de RobleAuth: $userData');

        currentUser.value = Usuario(
          id: userData['id']?.hashCode ?? 0, // Convertir string ID a int
          nombre: userData['name'] ?? '',
          email: userData['email'] ?? '',
          password: '', // No almacenar contraseña para RobleAuth
          rol: userData['role'] ?? 'user',
        );

        print('👤 Usuario creado: ${currentUser.value?.toJson()}');

        // 🔥 SINCRONIZAR CON BASE DE DATOS LOCAL
        await _sincronizarUsuarioConHive(currentUser.value!);

        print('✅ Sincronización con Hive completada');

        // 🔥 SINCRONIZAR TODOS LOS USUARIOS DE ROBLEAUTH
        await sincronizarTodosLosUsuariosDeRobleAuth();
      } else {
        print('⚠️ No se recibieron datos de usuario desde RobleAuth');
      }

      // Reinicializar controladores después del login exitoso
      try {
        if (Get.isRegistered<ActivityController>()) {
          final activityController = Get.find<ActivityController>();
          await activityController.reiniciar();
        }

        if (Get.isRegistered<EvaluacionController>()) {
          final evaluacionController = Get.find<EvaluacionController>();
          evaluacionController.limpiarDatos();
        }

        if (Get.isRegistered<CategoriaEquipoController>()) {
          final categoriaController = Get.find<CategoriaEquipoController>();
          categoriaController.limpiarDatos();
        }

        print('✅ Controladores reinicializados después del login');
      } catch (e) {
        print('⚠️ Error reinicializando controladores después del login: $e');
      }

      return accessToken.value.isNotEmpty;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Refresca el accessToken globalmente usando el refreshToken almacenado
  Future<bool> refreshAccessTokenIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    final storedRefreshToken = prefs.getString('refreshToken') ?? '';
    if (storedRefreshToken.isEmpty) return false;
    try {
      final newAccessToken = await refreshDatasource.refreshToken(
        refreshToken: storedRefreshToken,
      );
      accessToken.value = newAccessToken;
      await prefs.setString('accessToken', newAccessToken);
      return true;
    } catch (e) {
      errorMessage.value = 'Error al refrescar token: $e';
      // Mostrar mensaje y redirigir al login
      Get.snackbar(
        'Sesión expirada',
        'Por seguridad, vuelve a iniciar sesión.',
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
        snackPosition: SnackPosition.TOP,
      );
      // Limpiar tokens
      await prefs.remove('accessToken');
      await prefs.remove('refreshToken');
      // Redirigir al login
      Future.delayed(const Duration(seconds: 2), () {
        Get.offAllNamed('/login');
      });
      return false;
    }
  }

  /// Realiza logout en el backend y limpia los tokens locales
  Future<void> logout() async {
    try {
      // Si hay accessToken, intentar hacer logout en el backend
      if (accessToken.value.isNotEmpty) {
        await logoutDatasource.logout(accessToken: accessToken.value);
      }
    } catch (e) {
      print('Error durante logout remoto: $e');
      // Continúa con la limpieza local aunque el logout remoto falle
    }

    // Limpiar datos locales
    accessToken.value = '';
    refreshToken.value = '';
    currentUser.value = null;
    errorMessage.value = '';

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('accessToken');
    await prefs.remove('refreshToken');

    // Limpiar controladores
    try {
      if (Get.isRegistered<ActivityController>()) {
        final activityController = Get.find<ActivityController>();
        activityController.limpiarDatos();
      }

      if (Get.isRegistered<EvaluacionController>()) {
        final evaluacionController = Get.find<EvaluacionController>();
        evaluacionController.limpiarDatos();
      }

      if (Get.isRegistered<CategoriaEquipoController>()) {
        final categoriaController = Get.find<CategoriaEquipoController>();
        categoriaController.limpiarDatos();
      }

      print('✅ Controladores limpiados durante logout');
    } catch (e) {
      print('⚠️ Error limpiando controladores: $e');
    }

    Get.offAllNamed('/login');
  }

  /// Sincroniza usuario de RobleAuth con la base de datos local Hive
  Future<void> _sincronizarUsuarioConHive(Usuario usuarioRoble) async {
    try {
      print(
        '🔄 Iniciando sincronización con usuario: ${usuarioRoble.toJson()}',
      );

      // Obtener UsuarioUseCase para interactuar con Hive
      final usuarioUseCase = Get.find<UsuarioUseCase>();
      print('📦 UsuarioUseCase obtenido correctamente');

      // Verificar si el usuario ya existe en Hive (por email)
      final usuarioExistente = await usuarioUseCase.getUsuarios();
      print(
        '👥 Total usuarios en Hive antes de sync: ${usuarioExistente.length}',
      );

      for (int i = 0; i < usuarioExistente.length; i++) {
        final u = usuarioExistente[i];
        print(
          '   Usuario $i: ID=${u.id}, Email=${u.email}, Nombre=${u.nombre}, Rol=${u.rol}',
        );
      }

      Usuario? usuarioEnHive;

      try {
        usuarioEnHive = usuarioExistente.firstWhere(
          (u) => u.email.toLowerCase() == usuarioRoble.email.toLowerCase(),
        );
        print('🔍 Usuario encontrado en Hive: ${usuarioEnHive.toJson()}');
      } catch (e) {
        usuarioEnHive = null;
        print(
          '🔍 Usuario NO encontrado en Hive con email: ${usuarioRoble.email}',
        );
      }

      if (usuarioEnHive != null) {
        // Usuario existe, actualizar datos
        print(
          '📝 Actualizando usuario existente en Hive (ID: ${usuarioEnHive.id})...',
        );

        final usuarioActualizado = Usuario(
          id: usuarioEnHive.id, // Mantener el ID local de Hive
          nombre: usuarioRoble.nombre,
          email: usuarioRoble.email,
          password: usuarioEnHive.password, // Mantener password local si existe
          rol: usuarioRoble.rol == 'user'
              ? 'estudiante'
              : usuarioRoble.rol, // Normalizar rol
          creadoEn: usuarioEnHive.creadoEn, // Mantener fecha de creación
        );

        print(
          '📝 Datos del usuario actualizado: ${usuarioActualizado.toJson()}',
        );
        await usuarioUseCase.updateUsuario(usuarioActualizado);

        // Actualizar currentUser con el ID de Hive
        currentUser.value = usuarioActualizado;
        print(
          '✅ Usuario sincronizado y actualizado con ID Hive: ${usuarioActualizado.id}',
        );
      } else {
        // Usuario no existe, crear nuevo en Hive
        print('➕ Creando nuevo usuario en Hive...');

        // Buscar el próximo ID disponible en Hive
        final ids = usuarioExistente.map((u) => u.id ?? 0).toList();
        final maxId = ids.isEmpty ? 0 : ids.reduce((a, b) => a > b ? a : b);
        final nuevoIdHive = maxId + 1;

        print('🔢 Próximo ID disponible: $nuevoIdHive');

        final nuevoUsuario = Usuario(
          id: nuevoIdHive,
          nombre: usuarioRoble.nombre,
          email: usuarioRoble.email,
          password:
              '[ROBLE_AUTH]', // Marcador especial para usuarios de RobleAuth
          rol: usuarioRoble.rol == 'user'
              ? 'estudiante'
              : usuarioRoble.rol, // Normalizar rol
        );

        print('➕ Datos del nuevo usuario: ${nuevoUsuario.toJson()}');

        await usuarioUseCase.createUsuario(
          nombre: nuevoUsuario.nombre,
          email: nuevoUsuario.email,
          password:
              '[ROBLE_AUTH]', // Marcador especial para usuarios de RobleAuth
          rol: nuevoUsuario.rol,
          fromExternalAuth: true, // Marcar como usuario externo
        );

        // Actualizar currentUser con el nuevo ID de Hive
        currentUser.value = nuevoUsuario;
        print('✅ Nuevo usuario creado en Hive con ID: $nuevoIdHive');
      }

      // Debug final - Verificar estado después de la sincronización
      final usuariosFinales = await usuarioUseCase.getUsuarios();
      print(
        '🎯 Total usuarios en Hive después de sync: ${usuariosFinales.length}',
      );

      for (int i = 0; i < usuariosFinales.length; i++) {
        final u = usuariosFinales[i];
        print(
          '   Usuario final $i: ID=${u.id}, Email=${u.email}, Nombre=${u.nombre}, Rol=${u.rol}',
        );
      }

      print('👤 Usuario actual establecido: ${currentUser.value?.toJson()}');
    } catch (e, stackTrace) {
      print('❌ Error sincronizando usuario con Hive: $e');
      print('📍 StackTrace: $stackTrace');
      // No interrumpir el flujo de login por este error
    }
  }

  /// Guarda credenciales de usuario si el usuario selecciona 'Recordarme'
  Future<void> saveCredentials(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('savedEmail', email);
    await prefs.setString('savedPassword', password);
  }

  /// Recupera credenciales guardadas para autologin o precarga de formulario
  Future<Map<String, String>> getSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      "email": prefs.getString('savedEmail') ?? "",
      "password": prefs.getString('savedPassword') ?? "",
    };
  }

  /// Guarda el accessToken y refreshToken localmente
  Future<void> saveTokens(String accessToken, String refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('accessToken', accessToken);
    await prefs.setString('refreshToken', refreshToken);
  }

  /// Recupera el accessToken guardado
  Future<String> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('accessToken') ?? '';
  }

  /// Recupera el refreshToken guardado
  Future<String> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('refreshToken') ?? '';
  }

  /// Busca y sincroniza un usuario específico por email desde RobleAuth
  Future<Usuario?> buscarYSincronizarUsuarioPorEmail(String email) async {
    try {
      print('🔍 Buscando usuario por email en RobleAuth: $email');

      // Verificar token
      if (accessToken.value.isEmpty) {
        print('❌ No hay token de acceso disponible');
        return null;
      }

      // Buscar usuario en RobleAuth
      final usuarioData = await usersDatasource.searchUserByEmail(
        email: email,
        accessToken: accessToken.value,
      );

      if (usuarioData == null) {
        print('❌ Usuario no encontrado en RobleAuth: $email');
        return null;
      }

      // Convertir datos de RobleAuth a Usuario local
      final usuarioRoble = Usuario(
        id: 0, // Se asignará automáticamente por Hive
        nombre: usuarioData['name'] ?? usuarioData['nombre'] ?? 'Usuario',
        email: usuarioData['email'] ?? email,
        password: '[ROBLE_AUTH]',
        rol: usuarioData['role'] == 'user'
            ? 'estudiante'
            : usuarioData['role'] ?? 'estudiante',
        creadoEn: DateTime.now(),
      );

      print('👤 Usuario encontrado en RobleAuth: ${usuarioRoble.toJson()}');

      // Obtener UsuarioUseCase
      final usuarioUseCase = Get.find<UsuarioUseCase>();

      // Verificar si ya existe en Hive
      final usuariosHive = await usuarioUseCase.getUsuarios();
      final usuarioExistente = usuariosHive.firstWhereOrNull(
        (u) => u.email.toLowerCase() == email.toLowerCase(),
      );

      if (usuarioExistente != null) {
        print('📝 Usuario ya existe en Hive, actualizando...');
        final usuarioActualizado = Usuario(
          id: usuarioExistente.id,
          nombre: usuarioRoble.nombre,
          email: usuarioRoble.email,
          password: usuarioExistente.password,
          rol: usuarioRoble.rol,
          creadoEn: usuarioExistente.creadoEn,
        );
        await usuarioUseCase.updateUsuario(usuarioActualizado);
        return usuarioActualizado;
      } else {
        print('💾 Guardando nuevo usuario en Hive...');
        await usuarioUseCase.createUsuario(
          nombre: usuarioRoble.nombre,
          email: usuarioRoble.email,
          password: '[ROBLE_AUTH]',
          rol: usuarioRoble.rol,
          fromExternalAuth: true,
        );

        // Obtener el usuario recién creado
        final usuariosActualizados = await usuarioUseCase.getUsuarios();
        final usuarioCreado = usuariosActualizados.firstWhereOrNull(
          (u) => u.email.toLowerCase() == email.toLowerCase(),
        );

        return usuarioCreado;
      }
    } catch (e) {
      print('⚠️ Error buscando usuario por email: $e');
      return null;
    }
  }

  /// Sincroniza TODOS los usuarios de RobleAuth con Hive (no solo el que inicia sesión)
  Future<void> sincronizarTodosLosUsuariosDeRobleAuth() async {
    try {
      print('🔄 Iniciando sincronización completa de usuarios de RobleAuth...');

      // Primero explorar qué endpoints están disponibles
      print('🔍 Explorando endpoints disponibles en RobleAuth...');
      final availableEndpoints = await usersDatasource
          .discoverAvailableEndpoints(
            accessToken: accessToken.value.isEmpty ? null : accessToken.value,
          );

      if (availableEndpoints.isEmpty) {
        print(
          '❌ No se encontraron endpoints de usuarios disponibles en RobleAuth',
        );
        print(
          '💡 Los usuarios se sincronizarán individualmente cuando inicien sesión',
        );
        return;
      }

      print('✅ Endpoints disponibles encontrados: $availableEndpoints');

      // Verificar si tenemos token de acceso
      if (accessToken.value.isEmpty) {
        print(
          '⚠️ No hay token de acceso en memoria, intentando cargar de SharedPreferences...',
        );
        final prefs = await SharedPreferences.getInstance();
        final savedToken = prefs.getString('accessToken') ?? '';
        if (savedToken.isNotEmpty) {
          accessToken.value = savedToken;
          print('✅ Token cargado desde SharedPreferences');
        } else {
          print('❌ No hay token disponible, no se puede sincronizar usuarios');
          return;
        }
      }

      // Verificar si el token sigue siendo válido, si no, intentar refrescarlo
      print('🔍 Verificando validez del token...');
      if (refreshToken.value.isEmpty) {
        final prefs = await SharedPreferences.getInstance();
        refreshToken.value = prefs.getString('refreshToken') ?? '';
      }

      // Obtener todos los usuarios de RobleAuth
      print('📡 Llamando a RobleAuth para obtener todos los usuarios...');

      final usuariosRobleAuth = await usersDatasource.getAllUsers(
        accessToken: accessToken.value,
      );

      print('👥 Usuarios obtenidos de RobleAuth: ${usuariosRobleAuth.length}');

      if (usuariosRobleAuth.isEmpty) {
        print('💡 No se obtuvieron usuarios adicionales de RobleAuth');
        print('   Esto puede ser normal si:');
        print('   - El endpoint /users no está disponible');
        print('   - No hay otros usuarios registrados');
        print('   - Los usuarios solo se sincronizan al hacer login');
        return;
      }

      int usuariosNuevos = 0;
      int usuariosActualizados = 0;

      // Sincronizar cada usuario con Hive
      for (final userData in usuariosRobleAuth) {
        try {
          final usuarioRoble = Usuario(
            id: userData['id']?.hashCode ?? 0,
            nombre: userData['name'] ?? '',
            email: userData['email'] ?? '',
            password: '[ROBLE_AUTH]',
            rol: userData['role'] == 'user' ? 'estudiante' : userData['role'],
          );

          print(
            '🔄 Sincronizando: ${usuarioRoble.nombre} (${usuarioRoble.email})',
          );

          // Verificar si es un usuario nuevo o existente
          final usuarioUseCase = Get.find<UsuarioUseCase>();
          final usuariosExistentes = await usuarioUseCase.getUsuarios();
          final existente = usuariosExistentes.any(
            (u) => u.email.toLowerCase() == usuarioRoble.email.toLowerCase(),
          );

          await _sincronizarUsuarioConHive(usuarioRoble);

          if (existente) {
            usuariosActualizados++;
          } else {
            usuariosNuevos++;
          }
        } catch (e) {
          print('❌ Error sincronizando usuario ${userData['email']}: $e');
        }
      }

      print('✅ Sincronización completa finalizada:');
      print('   - Usuarios nuevos: $usuariosNuevos');
      print('   - Usuarios actualizados: $usuariosActualizados');
      print('   - Total procesados: ${usuariosRobleAuth.length}');
    } catch (e, stackTrace) {
      print('❌ Error en sincronización completa: $e');
      print('📍 StackTrace: $stackTrace');

      // Si el error es de token expirado, intentar refrescar
      if (e.toString().contains('Token expirado')) {
        print('🔄 Intentando refrescar token...');
        final refreshed = await refreshAccessTokenIfNeeded();
        if (refreshed) {
          print('✅ Token refrescado, reintentando sincronización...');
          await sincronizarTodosLosUsuariosDeRobleAuth();
        }
      }
    }
  }
}
