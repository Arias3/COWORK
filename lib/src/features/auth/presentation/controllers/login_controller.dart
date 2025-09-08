import 'package:get/get.dart';

class AuthController extends GetxController {
  RxString usuario = ''.obs;
  RxString contrasena = ''.obs;

  void login() {
    if (usuario.value == 'admin' && contrasena.value == 'admin') {
      Get.toNamed('/home');
    } else {
      Get.snackbar('Error de ingreso', 'Credenciales incorrectas');
    }
  }
}
