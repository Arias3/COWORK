import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/new_course_controller.dart';

class NewCoursePage extends StatelessWidget {
  NewCoursePage({super.key});
  final NewCourseController controller = Get.put(NewCourseController());
  final nombreCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final estudianteCtrl = TextEditingController();

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
                    icon: const Icon(Icons.arrow_back, color: Color(0xFF3B3576)),
                    onPressed: () => Get.back(),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Nuevo Curso',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              // Nombre del curso
              const Text(
                'Nombre del curso',
                style: TextStyle(
                  color: Color(0xFF3B3576),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              TextField(
                controller: nombreCtrl,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFF7D7BA7),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 12),
              // Descripción
              const Text(
                'Descripción',
                style: TextStyle(
                  color: Color(0xFF3B3576),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              TextField(
                controller: descCtrl,
                maxLines: 3,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFF7D7BA7),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 12),
              // Agregar estudiantes
              const Text(
                'Agregar estudiantes',
                style: TextStyle(
                  color: Color(0xFF3B3576),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: estudianteCtrl,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: '',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      style: const TextStyle(color: Color(0xFF3B3576)),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle, color: Color(0xFF3B3576)),
                    onPressed: () {
                      controller.agregarEstudiante(estudianteCtrl.text);
                      estudianteCtrl.clear();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Lista de estudiantes
              Expanded(
                child: Obx(() => Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF7D7BA7),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListView.builder(
                    itemCount: controller.estudiantes.length,
                    itemBuilder: (context, i) {
                      final nombre = controller.estudiantes[i];
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                nombre,
                                style: const TextStyle(
                                  color: Color(0xFF3B3576),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Color(0xFF3B3576)),
                              onPressed: () => controller.eliminarEstudiante(i),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                )),
              ),
              const SizedBox(height: 8),
              // Botón Crear
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF7D7BA7),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  ),
                  onPressed: () {
                    showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => Dialog(
      backgroundColor: const Color(0xFFD3D3D3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, color: Color(0xFF232B50)),
                  onPressed: () {
                    Navigator.of(context).pop();
                    Get.offAllNamed('/home');
                    },
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Curso Creado\nexitosamente',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF232B50),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 16),
            Icon(Icons.check_circle_outline, size: 56, color: Color(0xFF232B50)),
            const SizedBox(height: 16),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: Color(0xFF7D7BA7),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              ),
              onPressed: () {
                // Aquí puedes poner la lógica para compartir
                Navigator.of(context).pop();
                Get.offAllNamed('/home');
              },
              icon: const Icon(Icons.link),
              label: const Text('Compartir', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    ),
  );
                  },
                  child: const Text('Crear'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}