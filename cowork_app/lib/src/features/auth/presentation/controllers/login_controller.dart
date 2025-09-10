import 'package:get/get.dart';

class AuthController extends GetxController {
  RxString usuario = ''.obs;
  RxString contrasena = ''.obs;

  void login() {
    if (usuario.value == '' && contrasena.value == '') {
      Get.toNamed('/home');
    } else {
      Get.snackbar('Error de ingreso', 'Credenciales incorrectas');
    }
  }
}
