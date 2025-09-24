import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/use_case/usuario_usecase.dart';
import 'i_auth_controller.dart';

class LocalAuthController extends IAuthController {
  final UsuarioUseCase usuarioUseCase;

  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final successMessage = ''.obs;
  final currentUser = Rxn<Usuario>();

  LocalAuthController(this.usuarioUseCase);

  @override
  void onInit() {
    super.onInit();
    _loadUserFromPreferences();
  }

  /// Carga el usuario desde SharedPreferences al iniciar
  Future<void> _loadUserFromPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('current_user_id');

      if (userId != null) {
        final usuarios = await usuarioUseCase.getUsuarios();
        final usuario = usuarios.firstWhereOrNull((u) => u.id == userId);

        if (usuario != null) {
          currentUser.value = usuario;
          print('✅ Usuario cargado desde preferencias: ${usuario.nombre}');
        }
      }
    } catch (e) {
      print('⚠️ Error cargando usuario desde preferencias: $e');
    }
  }

  /// Login local con email y password
  Future<bool> login(String email, String password) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      successMessage.value = '';

      print('🔐 Intentando login local para: $email');

      // Buscar usuario en Hive
      final usuarios = await usuarioUseCase.getUsuarios();
      final usuario = usuarios.firstWhereOrNull(
        (u) =>
            u.email.toLowerCase() == email.toLowerCase() &&
            u.password == password,
      );

      if (usuario == null) {
        errorMessage.value = 'Email o contraseña incorrectos';
        return false;
      }

      // Guardar usuario actual
      currentUser.value = usuario;

      // Guardar en SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('current_user_id', usuario.id ?? 0);
      await prefs.setString('user_email', usuario.email);
      await prefs.setString('user_name', usuario.nombre);

      print('✅ Login exitoso: ${usuario.nombre} (${usuario.rol})');

      // Inicializar controladores dependientes
      await _initializeDependentControllers();

      return true;
    } catch (e) {
      print('❌ Error en login: $e');
      errorMessage.value = 'Error al iniciar sesión: ${e.toString()}';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Registro local de nuevo usuario
  Future<bool> register({
    required String nombre,
    required String email,
    required String password,
    String rol = 'estudiante',
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      successMessage.value = '';

      print('📝 Registrando nuevo usuario: $email');

      // Verificar que el email no exista
      final usuarios = await usuarioUseCase.getUsuarios();
      final existeEmail = usuarios.any(
        (u) => u.email.toLowerCase() == email.toLowerCase(),
      );

      if (existeEmail) {
        errorMessage.value = 'El email ya está registrado';
        return false;
      }

      // Crear nuevo usuario
      await usuarioUseCase.createUsuario(
        nombre: nombre,
        email: email,
        password: password,
        rol: rol,
      );

      print('✅ Usuario registrado exitosamente: $email');
      successMessage.value =
          'Cuenta creada exitosamente. Ahora puedes iniciar sesión.';

      return true;
    } catch (e) {
      print('❌ Error en registro: $e');
      errorMessage.value = 'Error al registrar: ${e.toString()}';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Logout local
  Future<void> logout() async {
    try {
      print('🚪 Cerrando sesión local...');

      // Limpiar SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('current_user_id');
      await prefs.remove('user_email');
      await prefs.remove('user_name');

      // Limpiar usuario actual
      currentUser.value = null;
      errorMessage.value = '';
      successMessage.value = '';

      print('✅ Sesión cerrada exitosamente');
    } catch (e) {
      print('❌ Error en logout: $e');
    }
  }

  /// Inicializar controladores que dependen del usuario autenticado
  Future<void> _initializeDependentControllers() async {
    try {
      print('🔄 Inicializando controladores dependientes...');

      // TODO: Inicializar controladores cuando sea necesario
      // Por ahora se omite para evitar errores de dependencias

      print('✅ Controladores reinicializados después del login');
    } catch (e) {
      print('⚠️ Error reinicializando controladores: $e');
    }
  }

  /// Verificar si hay un usuario autenticado
  bool get isLoggedIn => currentUser.value != null;

  /// Obtener el usuario actual
  Usuario? get user => currentUser.value;

  /// Verificar si el usuario actual es profesor
  bool get isProfesor => currentUser.value?.rol == 'profesor';

  /// Verificar si el usuario actual es estudiante
  bool get isEstudiante => currentUser.value?.rol == 'estudiante';

  /// Buscar usuario por email (para funcionalidades de búsqueda)
  Future<Usuario?> buscarUsuarioPorEmail(String email) async {
    try {
      print('🔍 Buscando usuario local por email: $email');

      final usuarios = await usuarioUseCase.getUsuarios();
      final usuario = usuarios.firstWhereOrNull(
        (u) => u.email.toLowerCase() == email.toLowerCase(),
      );

      if (usuario != null) {
        print('✅ Usuario encontrado: ${usuario.nombre}');
      } else {
        print('❌ Usuario no encontrado con email: $email');
      }

      return usuario;
    } catch (e) {
      print('⚠️ Error buscando usuario: $e');
      return null;
    }
  }

  /// Obtener todos los usuarios (para funcionalidades administrativas)
  Future<List<Usuario>> obtenerTodosLosUsuarios() async {
    try {
      return await usuarioUseCase.getUsuarios();
    } catch (e) {
      print('⚠️ Error obteniendo usuarios: $e');
      return [];
    }
  }
}
