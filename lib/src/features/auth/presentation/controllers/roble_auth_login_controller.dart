import 'package:get/get.dart';
import '../../domain/use_case/roble_auth_login_usecase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/datasources/roble_auth_refresh_token_datasource.dart';
import '../../data/datasources/roble_auth_logout_datasource.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/usuario_repository.dart';
import '../../../../../core/data/database/roble_config.dart';
import '../../../../../core/di/dependency_injection.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import '../../domain/use_case/usuario_usecase.dart';

// Extensión para firstWhereOrNull si no está disponible
extension IterableExtension<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T) test) {
    for (T element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}

class RobleAuthLoginController extends GetxController {
  final RobleAuthLoginUseCase useCase;
  final RobleAuthRefreshTokenDatasource refreshDatasource =
      RobleAuthRefreshTokenDatasource();
  final RobleAuthLogoutDatasource logoutDatasource =
      RobleAuthLogoutDatasource();
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

    // Llamar al login de RobleAuth
    final result = await useCase.call(email: email, password: password);
    accessToken.value = result['accessToken'] ?? '';
    refreshToken.value = result['refreshToken'] ?? '';

    // Configurar token único para tu proyecto
    RobleConfig.setAccessToken(accessToken.value);

    // Activar Roble directamente (tablas ya creadas manualmente)
    if (accessToken.value.isNotEmpty && !RobleConfig.useRoble) {
      RobleConfig.useRoble = true;
      print('✅ Roble activado - usando tablas existentes');
    }

    // Guardar tokens
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('accessToken', accessToken.value);
    await prefs.setString('refreshToken', refreshToken.value);

    // Guardar credenciales si es necesario
    if (rememberMe) {
      await saveCredentials(email, password);
    } else {
      await prefs.remove('savedEmail');
      await prefs.remove('savedPassword');
    }

    // Procesar información del usuario
    if (result['user'] != null) {
      final userData = result['user'] as Map<String, dynamic>;
      final authUserId = userData['id'].toString();
      final emailNormalizado = email.toLowerCase().trim();

      final usuarioUseCase = Get.find<UsuarioUseCase>();
      Usuario? perfil;

      print('🔍 === BÚSQUEDA Y REPARACIÓN DE USUARIO ===');
      print('Email: $emailNormalizado');
      print('AuthUserId: $authUserId');

      try {
        // 1. Buscar por email
        perfil = await usuarioUseCase.getUsuarioByEmail(emailNormalizado);
        print('🔍 Búsqueda por email: ${perfil != null ? 'ENCONTRADO' : 'NO ENCONTRADO'}');

        if (perfil != null) {
          print('📋 Usuario encontrado - ID actual: ${perfil.id}, Rol: ${perfil.rol}');

          // REPARAR DATOS SI ES NECESARIO
          bool necesitaReparacion = false;

          // Reparar ID si es null o 0
          if (perfil.id == null || perfil.id! <= 0) {
            final nuevoId = DateTime.now().millisecondsSinceEpoch % 0x7FFFFFFF;
            perfil.id = nuevoId == 0 ? 1 : nuevoId;
            necesitaReparacion = true;
            print('🆔 Nuevo ID asignado: ${perfil.id}');
          }

          // Reparar authUserId
          if (perfil.authUserId != authUserId) {
            perfil.authUserId = authUserId;
            necesitaReparacion = true;
            print('🔧 REPARANDO: AuthUserId actualizado');
          }

          // Reparar nombre
          final nuevoNombre = userData['name'] ?? '';
          if (nuevoNombre.isNotEmpty && perfil.nombre != nuevoNombre) {
            perfil.nombre = nuevoNombre;
            necesitaReparacion = true;
            print('🔧 REPARANDO: Nombre actualizado a "$nuevoNombre"');
          }

          // Reparar rol: si no es profesor, detectar automáticamente por email o authRole
          final rolFinal = (perfil.rol != null && perfil.rol == 'profesor')
              ? 'profesor'
              : usuarioUseCase.detectarRolPorEmail(emailNormalizado);

          if (perfil.rol != rolFinal) {
            perfil.rol = rolFinal;
            necesitaReparacion = true;
            print('🔧 REPARANDO: Rol actualizado a $rolFinal');
          }

          // Guardar reparaciones
          if (necesitaReparacion) {
            await usuarioUseCase.updateUsuario(perfil);
            print('✅ Usuario actualizado correctamente');
          }

          currentUser.value = perfil;
          print('✅ Login completado - Usuario: ${perfil.nombre} (ID: ${perfil.id}, Rol: ${perfil.rol})');

        } else {
          // 2. Usuario no existe, crear nuevo
          print('🆕 Usuario no existe, creando nuevo...');
          final rolFinal = usuarioUseCase.detectarRolPorEmail(emailNormalizado);
          final nuevoUsuario = Usuario(
            nombre: userData['name'] ?? 'Usuario',
            email: emailNormalizado,
            password: '',
            rol: rolFinal,
            authUserId: authUserId,
          );

          final nuevoId = await usuarioUseCase.createUsuarioFromAuth(
            nombre: nuevoUsuario.nombre,
            email: nuevoUsuario.email,
            authUserId: authUserId,
            rol: rolFinal,
          );

          if (nuevoId != null) {
            nuevoUsuario.id = nuevoId;
            print('✅ Usuario creado con ID: $nuevoId');
          }

          currentUser.value = nuevoUsuario;

          Get.snackbar(
            rolFinal == 'profesor' ? 'Profesor Registrado' : 'Usuario Creado',
            'Bienvenido ${nuevoUsuario.nombre}',
            backgroundColor: Get.theme.colorScheme.primary,
            colorText: Get.theme.colorScheme.onPrimary,
            snackPosition: SnackPosition.TOP,
          );
        }

      } catch (e) {
        print('❌ Error general en procesamiento de usuario: $e');
      }
    }

    return accessToken.value.isNotEmpty;
  } catch (e) {
    print('❌ Error en login: $e');
    errorMessage.value = e.toString();
    return false;
  } finally {
    isLoading.value = false;
  }
}



  Future<bool> refreshAccessTokenIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    final storedRefreshToken = prefs.getString('refreshToken') ?? '';
    if (storedRefreshToken.isEmpty) return false;
    try {
      final newAccessToken = await refreshDatasource.refreshToken(
        refreshToken: storedRefreshToken,
      );
      accessToken.value = newAccessToken;
      
      // Actualizar token
      RobleConfig.setAccessToken(newAccessToken);
      
      await prefs.setString('accessToken', newAccessToken);
      return true;
    } catch (e) {
      errorMessage.value = 'Error al refrescar token: $e';
      Get.snackbar(
        'Sesión expirada',
        'Por seguridad, vuelve a iniciar sesión.',
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
        snackPosition: SnackPosition.TOP,
      );
      await prefs.remove('accessToken');
      await prefs.remove('refreshToken');
      Future.delayed(const Duration(seconds: 2), () {
        Get.offAllNamed('/login');
      });
      return false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken') ?? '';
    try {
      await logoutDatasource.logout(accessToken: token);
    } catch (e) {
      print('Error en logout: $e');
    }
    
    // Limpiar configuración de Roble
    RobleConfig.clearTokens();
    RobleConfig.useRoble = false;
    
    await prefs.remove('accessToken');
    await prefs.remove('refreshToken');
    accessToken.value = '';
    refreshToken.value = '';
    currentUser.value = null; // Limpiar usuario actual
    Get.offAllNamed('/login');
  }

  Future<void> saveCredentials(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('savedEmail', email);
    await prefs.setString('savedPassword', password);
  }

  Future<Map<String, String>> getSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      "email": prefs.getString('savedEmail') ?? "",
      "password": prefs.getString('savedPassword') ?? "",
    };
  }

  Future<void> saveTokens(String accessToken, String refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('accessToken', accessToken);
    await prefs.setString('refreshToken', refreshToken);
  }

  Future<String> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('accessToken') ?? '';
  }

  Future<String> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('refreshToken') ?? '';
  }

  String _mapRoleToLocal(String authRole) {
    switch (authRole.toLowerCase()) {
      case 'teacher':
      case 'instructor':
      case 'professor':
        return 'profesor';
      case 'student':
      case 'user':
      default:
        return 'estudiante';
    }
  }
}