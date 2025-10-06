import 'package:get/get.dart';
import '../../domain/entities/user_entity.dart';
import '../controllers/i_auth_controller.dart';
import '../controllers/local_auth_controller.dart';

/// Servicio que unifica el acceso a la autenticación
/// Permite cambiar entre LocalAuth y RobleAuth de forma transparente
class AuthService extends GetxService {
  /// Controlador de autenticación activo
  late IAuthController _authController;

  /// Getter para acceder al controlador actual
  IAuthController get authController => _authController;

  @override
  void onInit() {
    super.onInit();
    _initializeAuthController();
  }

  /// Inicializa el controlador de autenticación apropiado
  void _initializeAuthController() {
    try {
      // Por ahora siempre usar LocalAuth
      // En el futuro se puede configurar dinámicamente
      _authController = Get.find<LocalAuthController>();
      print('🔧 AuthService inicializado con LocalAuthController');
    } catch (e) {
      print('⚠️ Error inicializando AuthService: $e');
      // Fallback a LocalAuth si no se encuentra el controlador
      _authController = Get.find<LocalAuthController>();
    }
  }

  /// Cambia al modo de autenticación local
  void switchToLocalAuth() {
    try {
      _authController = Get.find<LocalAuthController>();
      print('🔄 Cambiado a LocalAuthController');
    } catch (e) {
      print('❌ Error cambiando a LocalAuth: $e');
    }
  }

  /// Cambia al modo de autenticación RobleAuth
  void switchToRobleAuth() {
    // TODO: Implementar cuando RobleAuthLoginController implemente IAuthController
    print('🚧 RobleAuth no implementado aún - manteniendo LocalAuth');
    /*
    try {
      _authController = Get.find<RobleAuthLoginController>();
      print('🔄 Cambiado a RobleAuthController');
    } catch (e) {
      print('❌ Error cambiando a RobleAuth: $e');
      print('   Manteniendo LocalAuth como fallback');
    }
    */
  }

  // Métodos proxy que delegan al controlador activo

  /// Usuario actual autenticado
  Usuario? get currentUser => _authController.currentUser.value;

  /// Verifica si hay un usuario autenticado
  bool get isAuthenticated => _authController.isAuthenticated;

  /// Estado de carga
  bool get isLoading => _authController.isLoading.value;

  /// Mensaje de error
  String get errorMessage => _authController.errorMessage.value;

  /// Login con email y password
  Future<bool> login(String email, String password) {
    return _authController.login(email, password);
  }

  /// Logout
  Future<void> logout() {
    return _authController.logout();
  }

  /// Buscar usuario por email
  Future<Usuario?> buscarUsuarioPorEmail(String email) {
    return _authController.buscarUsuarioPorEmail(email);
  }

  /// Obtener todos los usuarios disponibles
  Future<List<Usuario>> obtenerTodosLosUsuarios() {
    return _authController.obtenerTodosLosUsuarios();
  }

  /// Método helper para migración: sincronizar usuarios si es RobleAuth
  Future<void> sincronizarUsuarios() async {
    // TODO: Implementar cuando RobleAuth esté disponible
    print('ℹ️ Usando LocalAuth - no es necesario sincronizar');
    /*
    if (_authController is RobleAuthLoginController) {
      try {
        final robleController = _authController as RobleAuthLoginController;
        await robleController.sincronizarTodosLosUsuariosDeRobleAuth();
        print('✅ Usuarios sincronizados desde RobleAuth');
      } catch (e) {
        print('⚠️ Error sincronizando usuarios desde RobleAuth: $e');
      }
    } else {
      print('ℹ️ Usando LocalAuth - no es necesario sincronizar');
    }
    */
  }
}
