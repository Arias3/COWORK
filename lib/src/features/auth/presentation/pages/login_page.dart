import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/login_controller.dart';
import 'package:cowork_app/src/features/auth/domain/use_case/usuario_usecase.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthenticationController authController = Get.put(
      AuthenticationController(Get.find<UsuarioUseCase>()),
    );
    final usuarioController = TextEditingController();
    final contrasenaController = TextEditingController();

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
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isSmallScreen = MediaQuery.of(context).size.width < 400;
                  final horizontalPadding = isSmallScreen ? 16.0 : 24.0;

                  return Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
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

                        // Campo Usuario
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 320),
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

                        // Campo Contraseña
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 320),
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

                        // Checkbox Recordarme
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Obx(
                              () => Checkbox(
                                value: authController.rememberMe.value,
                                onChanged: (value) {
                                  authController.rememberMe.value =
                                      value ?? false;
                                },
                                activeColor: const Color(0xFFF7D86A),
                                checkColor: const Color(0xFF3B3576),
                              ),
                            ),
                            const Text(
                              'Recordarme',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),

                        // Olvidaste contraseña
                        GestureDetector(
                          onTap: () {
                            Get.snackbar(
                              'Información',
                              'Funcionalidad de recuperación en desarrollo',
                              backgroundColor: Colors.orange,
                              colorText: Colors.white,
                              snackPosition: SnackPosition.TOP,
                            );
                          },
                          child: const Text(
                            '¿Olvidaste tu contraseña?',
                            style: TextStyle(
                              color: Colors.white,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Botón Iniciar sesión
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 320),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFF7D86A),
                                foregroundColor: const Color(0xFF3B3576),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: () async {
                                final email = usuarioController.text.trim();
                                final password = contrasenaController.text
                                    .trim();

                                if (email.isEmpty || password.isEmpty) {
                                  Get.snackbar(
                                    "Error",
                                    "Por favor completa todos los campos",
                                    backgroundColor: Colors.red,
                                    colorText: Colors.white,
                                    snackPosition: SnackPosition.TOP,
                                  );
                                  return;
                                }

                                final success = await authController.login(
                                  email,
                                  password,
                                );

                                if (success) {
                                  Get.snackbar(
                                    "Éxito",
                                    "Bienvenido ${authController.currentUser.value?.nombre}",
                                    backgroundColor: Colors.green,
                                    colorText: Colors.white,
                                    snackPosition: SnackPosition.TOP,
                                  );
                                  Get.offAllNamed('/home');
                                } else {
                                  Get.snackbar(
                                    "Error",
                                    authController.errorMessage.value,
                                    backgroundColor: Colors.red,
                                    colorText: Colors.white,
                                    snackPosition: SnackPosition.TOP,
                                  );
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
                        ),
                        const SizedBox(height: 10),

                        // Botón Regístrate
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 320),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF3B3576),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: () {
                                Get.toNamed('/register');
                              },
                              child: const Text(
                                'Regístrate',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
