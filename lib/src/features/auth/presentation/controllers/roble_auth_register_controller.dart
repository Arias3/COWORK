import 'package:get/get.dart';
import '../../domain/use_case/roble_auth_register_usecase.dart';
import 'roble_auth_login_controller.dart';

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

      print('🔄 === INICIANDO REGISTRO COMPLETO ===');
      print('Email: $email');
      print('Nombre: $name');

      // 1. Registrar en el sistema de autenticación
      final result = await useCase.call(
        email: email,
        password: password,
        name: name,
      );

      if (result) {
        print('✅ Registro en Auth exitoso');

        // 2. Hacer login automático para obtener token válido
        try {
          print('� Obteniendo token para crear usuario en tabla...');
          final loginController = Get.find<RobleAuthLoginController>();
          final loginSuccess = await loginController.login(
            email: email,
            password: password,
            rememberMe:
                false, // No recordar credenciales del registro automático
          );

          if (loginSuccess) {
            print(
              '✅ Login automático exitoso - Usuario creado en tabla durante login',
            );
            success.value = true;

            Get.snackbar(
              '¡Registro Exitoso!',
              'Bienvenido $name. Ya puedes iniciar sesión.',
              backgroundColor: Get.theme.colorScheme.primary,
              colorText: Get.theme.colorScheme.onPrimary,
              snackPosition: SnackPosition.TOP,
              duration: const Duration(seconds: 3),
            );

            // Hacer logout automático para no dejar la sesión activa
            await loginController.logout();
            print('🔄 Logout automático completado');
          } else {
            print(
              '⚠️ Login automático falló, usuario se creará en primer login manual',
            );
            success.value = true;

            Get.snackbar(
              'Registro Parcial',
              'Cuenta creada. Al iniciar sesión se completará el perfil.',
              backgroundColor: Get.theme.colorScheme.secondary,
              colorText: Get.theme.colorScheme.onSecondary,
              snackPosition: SnackPosition.TOP,
            );
          }
        } catch (e, stackTrace) {
          print('❌ Error en login automático: $e');
          print('❌ StackTrace: $stackTrace');
          // Registro en Auth fue exitoso, solo falló el login automático
          success.value = true;

          Get.snackbar(
            'Registro Parcial',
            'Cuenta creada. Al iniciar sesión se completará el perfil.',
            backgroundColor: Get.theme.colorScheme.secondary,
            colorText: Get.theme.colorScheme.onSecondary,
            snackPosition: SnackPosition.TOP,
          );
        }
      } else {
        print('❌ Fallo en registro de Auth');
        success.value = false;
      }

      print('🏁 === FIN REGISTRO ===');
      return success.value;
    } catch (e) {
      print('❌ Error general en registro: $e');
      errorMessage.value = 'Error: ${e.toString()}';
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
