import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/login_controller.dart';
import '../../domain/use_case/usuario_usecase.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthenticationController authController = Get.put(
      AuthenticationController(Get.find<UsuarioUseCase>()),
    );
    final nombreController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final rolSeleccionado = 'estudiante'.obs; // Por defecto estudiante

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
                Get.toNamed('/login');
              },
              child: const Text('Ingresa'),
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
                          'Registrate',
                          style: TextStyle(
                            color: Color(0xFFF7D86A),
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),

                        // Campo Nombre
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 320),
                          child: TextField(
                            controller: nombreController,
                            style: const TextStyle(fontSize: 14),
                            decoration: InputDecoration(
                              prefixIcon: const Icon(
                                Icons.person_outline,
                                color: Color(0xFF3B3576),
                              ),
                              labelText: 'Nombre',
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
                        const SizedBox(height: 12),

                        // Campo Email
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 320),
                          child: TextField(
                            controller: emailController,
                            style: const TextStyle(fontSize: 14),
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(
                                Icons.mail_outline,
                                color: Color(0xFF3B3576),
                              ),
                              labelText: 'Correo electrónico',
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
                        const SizedBox(height: 12),

                        // Campo Contraseña
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 320),
                          child: TextField(
                            controller: passwordController,
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
                        const SizedBox(height: 12),

                        // Selector de Rol
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 320),
                          child: Obx(
                            () => Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: DropdownButtonFormField<String>(
                                value: rolSeleccionado.value,
                                decoration: InputDecoration(
                                  prefixIcon: const Icon(
                                    Icons.school_outlined,
                                    color: Color(0xFF3B3576),
                                  ),
                                  labelText: 'Tipo de cuenta',
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
                                items: const [
                                  DropdownMenuItem(
                                    value: 'estudiante',
                                    child: Text('Estudiante'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'profesor',
                                    child: Text('Profesor'),
                                  ),
                                ],
                                onChanged: (value) {
                                  if (value != null) {
                                    rolSeleccionado.value = value;
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Botón de Registro
                        Obx(
                          () => ConstrainedBox(
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
                                onPressed: authController.isLoading.value
                                    ? null
                                    : () async {
                                        // Validaciones básicas en el frontend
                                        if (nombreController.text
                                            .trim()
                                            .isEmpty) {
                                          Get.snackbar(
                                            'Error',
                                            'Por favor ingresa tu nombre',
                                            backgroundColor: Colors.red,
                                            colorText: Colors.white,
                                            snackPosition: SnackPosition.TOP,
                                          );
                                          return;
                                        }

                                        if (emailController.text
                                            .trim()
                                            .isEmpty) {
                                          Get.snackbar(
                                            'Error',
                                            'Por favor ingresa tu email',
                                            backgroundColor: Colors.red,
                                            colorText: Colors.white,
                                            snackPosition: SnackPosition.TOP,
                                          );
                                          return;
                                        }

                                        if (passwordController.text
                                                .trim()
                                                .length <
                                            6) {
                                          Get.snackbar(
                                            'Error',
                                            'La contraseña debe tener al menos 6 caracteres',
                                            backgroundColor: Colors.red,
                                            colorText: Colors.white,
                                            snackPosition: SnackPosition.TOP,
                                          );
                                          return;
                                        }

                                        // Intentar registro - toda la lógica está en el controller y use case
                                        final success = await authController
                                            .signUp(
                                              nombreController.text.trim(),
                                              emailController.text.trim(),
                                              passwordController.text.trim(),
                                              rolSeleccionado.value,
                                            );

                                        if (success) {
                                          Get.snackbar(
                                            'Éxito',
                                            'Cuenta creada exitosamente. Ahora puedes iniciar sesión',
                                            backgroundColor: Colors.green,
                                            colorText: Colors.white,
                                            snackPosition: SnackPosition.TOP,
                                          );
                                          // Limpiar campos
                                          nombreController.clear();
                                          emailController.clear();
                                          passwordController.clear();
                                          rolSeleccionado.value = 'estudiante';

                                          // Navegar al login
                                          Get.offAllNamed('/login');
                                        } else {
                                          Get.snackbar(
                                            'Error',
                                            authController.errorMessage.value,
                                            backgroundColor: Colors.red,
                                            colorText: Colors.white,
                                            snackPosition: SnackPosition.TOP,
                                          );
                                        }
                                      },
                                child: authController.isLoading.value
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Color(0xFF3B3576),
                                              ),
                                        ),
                                      )
                                    : const Text(
                                        'Registrarse',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
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
