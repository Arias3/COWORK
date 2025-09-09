import 'package:get/get.dart';
import 'package:loggy/loggy.dart';
import '../../domain/use_case/authentication_usecase.dart';

class AuthenticationController extends GetxController {
  final AuthenticationUseCase authentication;

  // Estado reactivo
  final logged = false.obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  AuthenticationController(this.authentication);

  @override
  Future<void> onInit() async {
    super.onInit();
    logInfo('AuthenticationController initialized');
  }

  bool get isLogged => logged.value;

  Future<bool> login(String email, String password) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      logInfo('AuthenticationController: Login $email');

      final rta = await authentication.login(email, password);

      if (rta) {
        logged.value = true;
        return true;
      } else {
        logged.value = false;
        errorMessage.value = 'Credenciales incorrectas. Inténtalo de nuevo.';
        return false;
      }
    } catch (e) {
      logged.value = false;
      errorMessage.value = 'Error en el servidor o conexión: $e';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> signUp(String email, String password) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      await authentication.signUp(email, password);
      return true;
    } catch (e) {
      errorMessage.value = 'Error en sign up: $e';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logOut() async {
    await authentication.logOut();
    logged.value = false;
    logInfo('AuthenticationController: Log Out');
  }
}
