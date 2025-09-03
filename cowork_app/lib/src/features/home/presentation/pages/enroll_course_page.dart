import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/enroll_course_controller.dart';

class EnrollCoursePage extends StatelessWidget {
  EnrollCoursePage({super.key});
  final EnrollCourseController controller = Get.find<EnrollCourseController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFB3B6C7),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Color(0xFF3B3576),
                    ),
                    onPressed: () => Get.back(),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Inscribirse a un curso',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              const Text(
                'Selecciona un curso',
                style: TextStyle(
                  color: Color(0xFF3B3576),
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              // Lista de cursos
              Expanded(
                child: GetBuilder<EnrollCourseController>(
                  builder: (controller) {
                    return ListView.separated(
                      itemCount: controller.cursos.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, i) {
                        final curso = controller.cursos[i];
                        final seleccionado = controller.seleccionado.value == i;
                        return GestureDetector(
                          onTap: () => controller.seleccionar(i),
                          child: Container(
                            decoration: BoxDecoration(
                              color: seleccionado
                                  ? const Color(0xFF7D7BA7)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: seleccionado
                                    ? const Color(0xFF3B3576)
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                Image.asset(
                                  curso['img'] ?? '',
                                  width: 48,
                                  height: 48,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(
                                        Icons.image_not_supported,
                                        size: 48,
                                        color: Color(0xFF3B3576),
                                      ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        curso['nombre'] ?? '',
                                        style: TextStyle(
                                          color: seleccionado
                                              ? Colors.white
                                              : const Color(0xFF3B3576),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        curso['descripcion'] ?? '',
                                        style: TextStyle(
                                          color: seleccionado
                                              ? Colors.white70
                                              : const Color(0xFF3B3576),
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (seleccionado)
                                  const Icon(
                                    Icons.check_circle,
                                    color: Colors.white,
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              // Botón Inscribirse
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF7D7BA7),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => Dialog(
                        backgroundColor: const Color(0xFFD3D3D3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  const Spacer(),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.close,
                                      color: Color(0xFF232B50),
                                    ),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      Get.offAllNamed('/home');
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Inscripción exitosa',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Color(0xFF232B50),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Icon(
                                Icons.check_circle_outline,
                                size: 56,
                                color: Color(0xFF232B50),
                              ),
                              const SizedBox(height: 16),
                              FilledButton.icon(
                                style: FilledButton.styleFrom(
                                  backgroundColor: Color(0xFF7D7BA7),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 18,
                                    vertical: 8,
                                  ),
                                ),
                                onPressed: () {
                                  // Aquí puedes poner lógica para compartir o simplemente volver al home
                                  Navigator.of(context).pop();
                                  Get.offAllNamed('/home');
                                },
                                icon: const Icon(Icons.link),
                                label: const Text(
                                  'Compartir',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  child: const Text('Inscribirse'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
