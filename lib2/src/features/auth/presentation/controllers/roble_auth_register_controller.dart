import 'package:get/get.dart';
import '../../domain/use_case/roble_auth_register_usecase.dart';
import '../../domain/use_case/usuario_usecase.dart';
import '../../../home/presentation/controllers/new_course_controller.dart';

class RobleAuthRegisterController extends GetxController {
  final RobleAuthRegisterUseCase useCase;
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final success = false.obs;

  RobleAuthRegisterController(this.useCase);

  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      success.value = false;
      final result = await useCase.call(
        email: email,
        password: password,
        name: name,
      );
      success.value = result;

      // Si el registro fue exitoso, refrescar listas de estudiantes
      if (result) {
        try {
          // 🔥 SINCRONIZAR USUARIO REGISTRADO CON HIVE
          await _sincronizarUsuarioRegistradoConHive(name, email, 'estudiante');

          // Intentar refrescar el NewCourseController si existe
          if (Get.isRegistered<NewCourseController>()) {
            final controller = Get.find<NewCourseController>();
            await controller.refrescarEstudiantes();
            print('✅ Lista de estudiantes refrescada después del registro');
          }
        } catch (e) {
          print('⚠️ No se pudo refrescar lista de estudiantes: $e');
          // No interrumpir el flujo por este error
        }
      }

      return result;
    } catch (e) {
      errorMessage.value = 'Error: ${e.toString()}';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Sincroniza usuario recién registrado con la base de datos local Hive
  Future<void> _sincronizarUsuarioRegistradoConHive(
    String nombre,
    String email,
    String rol,
  ) async {
    try {
      print('🔄 Sincronizando usuario registrado $email con Hive...');

      // Obtener UsuarioUseCase para interactuar con Hive
      final usuarioUseCase = Get.find<UsuarioUseCase>();

      // Crear usuario en Hive
      final nuevoIdHive = await usuarioUseCase.createUsuario(
        nombre: nombre,
        email: email,
        password: '[ROBLE_AUTH]', // Marcador especial
        rol: rol == 'user' ? 'estudiante' : rol, // Normalizar rol para Hive
      );

      print('✅ Usuario registrado sincronizado en Hive con ID: $nuevoIdHive');
    } catch (e) {
      print('❌ Error sincronizando usuario registrado con Hive: $e');
      // No interrumpir el flujo de registro por este error
    }
  }
}
