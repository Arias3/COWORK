import 'package:get/get.dart';
import '../../domain/entities/user_entity.dart';

/// Interfaz común para controladores de autenticación
/// Permite usar indistintamente LocalAuth o RobleAuth
abstract class IAuthController extends GetxController {
  /// Usuario actual autenticado
  Rxn<Usuario> get currentUser;

  /// Estado de carga
  RxBool get isLoading;

  /// Mensaje de error
  RxString get errorMessage;

  /// Verifica si hay un usuario autenticado
  bool get isAuthenticated => currentUser.value != null;

  /// Login con email y password
  Future<bool> login(String email, String password);

  /// Logout
  Future<void> logout();

  /// Buscar usuario por email (para funcionalidades como agregar estudiantes)
  Future<Usuario?> buscarUsuarioPorEmail(String email);

  /// Obtener todos los usuarios disponibles (estudiantes)
  Future<List<Usuario>> obtenerTodosLosUsuarios();
}
