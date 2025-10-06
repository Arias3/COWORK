import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/roble_auth_login_controller.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Usar el controller desde inyección de dependencias
    final robleAuthLoginController = Get.find<RobleAuthLoginController>();
    final usuarioController = TextEditingController();
    final contrasenaController = TextEditingController();
    final RxBool ocultarContrasena = true.obs;
    final RxBool recordarCredenciales = false.obs;

    // Precargar credenciales guardadas usando el método del controller
    Future<void> precargarCredenciales() async {
      final credentials = await robleAuthLoginController.getSavedCredentials();
      usuarioController.text = credentials['email'] ?? '';
      contrasenaController.text = credentials['password'] ?? '';
      recordarCredenciales.value = credentials['email']?.isNotEmpty == true;
    }

    // Ejecutar precarga al construir el widget
    WidgetsBinding.instance.addPostFrameCallback((_) {
      precargarCredenciales();
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
          // Botón Regístrate en la parte superior derecha
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

                    // Campo Usuario
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

                    // Campo Contraseña
                    SizedBox(
                      width: 260,
                      child: Obx(
                        () => TextField(
                          controller: contrasenaController,
                          style: const TextStyle(fontSize: 14),
                          obscureText: ocultarContrasena.value,
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
                            suffixIcon: IconButton(
                              icon: Icon(
                                ocultarContrasena.value
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Color(0xFF3B3576),
                              ),
                              onPressed: () {
                                ocultarContrasena.value =
                                    !ocultarContrasena.value;
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),

                    // Checkbox Recordarme
                    SizedBox(
                      width: 260,
                      child: Obx(
                        () => CheckboxListTile(
                          title: const Text(
                            'Recordarme',
                            style: TextStyle(color: Colors.white),
                          ),
                          value: recordarCredenciales.value,
                          onChanged: (value) {
                            recordarCredenciales.value = value ?? false;
                          },
                          controlAffinity: ListTileControlAffinity.leading,
                          activeColor: Color(0xFFF7D86A),
                          checkColor: Color(0xFF3B3576),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),

                    // Olvidaste contraseña
                    GestureDetector(
                      onTap: () {
                        // Eliminar mensaje innecesario - funcionalidad no implementada
                        print(
                          '🔄 Recuperación de contraseña - funcionalidad en desarrollo',
                        );
                        // TODO: Implementar recuperación de contraseña
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
                        onPressed: robleAuthLoginController.isLoading.value
                            ? null
                            : () async {
                                final email = usuarioController.text.trim();
                                final password = contrasenaController.text
                                    .trim();
                                if (email.isEmpty || password.isEmpty) {
                                  // Mantener solo validación crítica
                                  Get.snackbar(
                                    "Campos Requeridos",
                                    "Completa tu email y contraseña",
                                    backgroundColor: Colors.orange,
                                    colorText: Colors.white,
                                    snackPosition: SnackPosition.TOP,
                                    duration: const Duration(seconds: 2),
                                  );
                                  return;
                                }

                                // Usar el método mejorado del controller que maneja "Recuérdame"
                                final success = await robleAuthLoginController
                                    .login(
                                      email: email,
                                      password: password,
                                      rememberMe: recordarCredenciales.value,
                                    );

                                if (success) {
                                  // Mensaje de éxito eliminado - navegación es suficiente feedback
                                  print('✅ Login exitoso');
                                  Get.offAllNamed('/home');
                                } else {
                                  // Solo mostrar errores críticos de autenticación
                                  Get.snackbar(
                                    "Error de Acceso",
                                    "Credenciales incorrectas. Verifica tu email y contraseña.",
                                    backgroundColor: Colors.red,
                                    colorText: Colors.white,
                                    snackPosition: SnackPosition.TOP,
                                    duration: const Duration(seconds: 3),
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
                    const SizedBox(height: 10),

                    // ...existing code...
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
