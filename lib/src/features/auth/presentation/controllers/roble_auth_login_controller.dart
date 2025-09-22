import 'package:get/get.dart';
import '../../domain/use_case/roble_auth_login_usecase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/datasources/roble_auth_refresh_token_datasource.dart';
import '../../data/datasources/roble_auth_logout_datasource.dart';
import '../../domain/entities/user_entity.dart';
import 'dart:async';

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
        currentUser.value = Usuario(
          id: userData['id']?.hashCode ?? 0, // Convertir string ID a int
          nombre: userData['name'] ?? '',
          email: userData['email'] ?? '',
          password: '', // No almacenar contraseña para RobleAuth
          rol: userData['role'] ?? 'user',
        );
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
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken') ?? '';
    try {
      await logoutDatasource.logout(accessToken: token);
    } catch (e) {
      // Si falla, igual se limpian los tokens y se redirige
      print('Error en logout: $e');
    }
    await prefs.remove('accessToken');
    await prefs.remove('refreshToken');
    accessToken.value = '';
    refreshToken.value = '';
    Get.offAllNamed('/login');
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
}
