import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});
  final HomeController controller = Get.put(HomeController());

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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Obx(() => RichText(
                        text: TextSpan(
                          children: [
                            const TextSpan(
                              text: 'Bienvenido,\n',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                              ),
                            ),
                            TextSpan(
                              text: controller.userName.value,
                              style: const TextStyle(
                                color: Color(0xFFF7D86A),
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      )),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.notifications_none, color: Colors.white),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.settings, color: Colors.white),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 18),
              // Dictados
              const Text(
                'Dictados',
                style: TextStyle(
                  color: Color(0xFF3B3576),
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 90,
                child: Obx(() => ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: controller.dictados.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, i) {
                        final curso = controller.dictados[i]; // o controller.inscritos[i]
                        final nombre = curso['nombre'] ?? '';
                        final img = curso['img'] ?? '';
                        return _CursoCard(nombre: nombre, img: img);
                      },
                    )),
              ),
              const SizedBox(height: 18),
              // Inscrito
              const Text(
                'Inscrito',
                style: TextStyle(
                  color: Color(0xFF3B3576),
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Obx(() => GridView.builder(
                      itemCount: controller.inscritos.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        childAspectRatio: 1.7,
                      ),
                      itemBuilder: (context, i) {
                        final curso = controller.inscritos[i];
                        return _CursoCard(nombre: curso['nombre']!, img: curso['img']!);
                      },
                    )),
              ),
              // Botones
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF3B3576),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    ),
                    onPressed: () {
                        Get.toNamed('/new-course');
                        },
                        child: const Text('crear'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF3B3576),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    ),
                    onPressed: () {
                        Get.toNamed('/enroll-course');
                        },
                        child: const Text('Inscribirse'),
                  ),
                  const SizedBox(width: 8),
                  FloatingActionButton(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF3B3576),
                    onPressed: () {},
                    child: const Icon(Icons.add, size: 28),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CursoCard extends StatelessWidget {
  final String nombre;
  final String img;
  const _CursoCard({required this.nombre, required this.img});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      decoration: BoxDecoration(
        color: const Color(0xFFFFB74D),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(img, width: 48, height: 48, fit: BoxFit.contain),
          const SizedBox(height: 4),
          Text(
            nombre,
            style: const TextStyle(
              color: Color(0xFF3B3576),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}