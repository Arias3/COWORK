import 'package:get/get.dart';
import 'package:loggy/loggy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/use_case/usuario_usecase.dart';
import '../../domain/entities/user_entity.dart';

class AuthenticationController extends GetxController {
  final UsuarioUseCase usuarioUseCase;
  
  // Estado reactivo
  final logged = false.obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final rememberMe = false.obs;
  final currentUser = Rxn<Usuario>();

  AuthenticationController(this.usuarioUseCase);

  @override
  Future<void> onInit() async {
    super.onInit();
    await _checkSavedCredentials();
    logInfo('AuthenticationController initialized');
  }

  bool get isLogged => logged.value;

  Future<bool> login(String email, String password) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      logInfo('AuthenticationController: Login attempt for $email');
      
      final usuario = await usuarioUseCase.login(email, password);
      
      if (usuario != null) {
        logged.value = true;
        currentUser.value = usuario;
        
        // Guardar ID del usuario en preferencias
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('currentUserId', usuario.id!);
        
        // Guardar credenciales si "rememberMe" está activado
        if (rememberMe.value) {
          await prefs.setString('savedEmail', email);
          await prefs.setString('savedPassword', password);
        }
        
        logInfo('Login successful for user: ${usuario.nombre}');
        return true;
      } else {
        logged.value = false;
        errorMessage.value = 'Credenciales incorrectas. Inténtalo de nuevo.';
        return false;
      }
    } catch (e) {
      logged.value = false;
      errorMessage.value = 'Error: ${e.toString()}';
      logError('Login error: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> signUp(String nombre, String email, String password, String rol) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final userId = await usuarioUseCase.createUsuario(
        nombre: nombre,
        email: email,
        password: password,
        rol: rol,
      );
      
      logInfo('User created successfully with ID: $userId');
      return true;
    } catch (e) {
      errorMessage.value = 'Error en registro: ${e.toString()}';
      logError('SignUp error: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('currentUserId');
    
    logged.value = false;
    currentUser.value = null;
    logInfo('AuthenticationController: User logged out');
  }

  Future<void> _checkSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('currentUserId');
    
    if (userId != null) {
      try {
        final usuario = await usuarioUseCase.getUsuarioById(userId);
        if (usuario != null) {
          logged.value = true;
          currentUser.value = usuario;
          logInfo('Auto-login successful for user: ${usuario.nombre}');
        }
      } catch (e) {
        logError('Auto-login failed: $e');
      }
    }
  }

  // Recuperar credenciales guardadas para el formulario
  Future<Map<String, String>> getSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      "email": prefs.getString('savedEmail') ?? "",
      "password": prefs.getString('savedPassword') ?? "",
    };
  }
}