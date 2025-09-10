import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/login_controller.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthenticationController authController = Get.put(
      AuthenticationController(Get.find()),
    );
    final usuarioController = TextEditingController();
    final contrasenaController = TextEditingController();

    // Precargar credenciales si existen
    authController.getSavedCredentials().then((saved) {
      usuarioController.text = saved['email'] ?? '';
      contrasenaController.text = saved['password'] ?? '';
      if (saved['email']!.isNotEmpty) {
        authController.rememberMe.value = true;
      }
    });

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 29, 28, 34),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/login_bg.jpeg',
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 50,
            right: 0,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF3B3576),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 9,
                ),
              ),
              onPressed: () {
                Get.toNamed('/register');
              },
              child: const Text('Regístrate'),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFF3B3576),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Iniciar sesión',
                      style: TextStyle(
                        color: Color(0xFFF7D86A),
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: 260,
                      child: TextField(
                        controller: usuarioController,
                        style: const TextStyle(fontSize: 14),
                        decoration: InputDecoration(
                          prefixIcon: const Icon(
                            Icons.mail_outline,
                            color: Color(0xFF3B3576),
                          ),
                          labelText: 'Usuario',
                          labelStyle: const TextStyle(
                            color: Color.fromARGB(255, 25, 22, 53),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 20,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: 260,
                      child: TextField(
                        controller: contrasenaController,
                        style: const TextStyle(fontSize: 14),
                        obscureText: true,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(
                            Icons.key,
                            color: Color(0xFF3B3576),
                          ),
                          labelText: 'Contraseña',
                          labelStyle: const TextStyle(
                            color: Color.fromARGB(255, 18, 16, 39),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 20,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Obx(
                          () => Checkbox(
                            value: authController.rememberMe.value,
                            onChanged: (value) {
                              authController.rememberMe.value = value ?? false;
                            },
                            activeColor: const Color(0xFF3B3576),
                          ),
                        ),
                        const Text(
                          'Recuérdame',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Align(
                      alignment: Alignment.center,
                      child: const Text(
                        '¿Olvidaste tu contraseña?',
                        style: TextStyle(
                          color: Colors.white,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF7D86A),
                          foregroundColor: const Color(0xFF3B3576),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () async {
                          final success = await authController.login(
                            usuarioController.text.trim(),
                            contrasenaController.text.trim(),
                          );

                          if (success) {
                            Get.offAllNamed('/home');
                          } else {
                            // Mostrar error como snackbar
                            if (authController.errorMessage.isNotEmpty) {
                              Get.snackbar(
                                'Error de inicio de sesión',
                                authController.errorMessage.value,
                                backgroundColor: const Color(0xFFF7D86A),
                                colorText: const Color.fromARGB(
                                  255,
                                  197,
                                  45,
                                  45,
                                ),
                                snackPosition: SnackPosition.TOP,
                                duration: const Duration(seconds: 3),
                              );
                            }
                          }
                        },

                        child: const Text(
                          'Iniciar sesión',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
