import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domain/use_case/curso_usecase.dart';
import '../../domain/entities/curso_entity.dart';
import '../../../auth/presentation/controllers/login_controller.dart';


class HomeController extends GetxController with GetTickerProviderStateMixin {
  final CursoUseCase cursoUseCase;
  final AuthenticationController authController;

  HomeController(this.cursoUseCase, this.authController);

  // Estados de UI
  var dictados = <CursoDomain>[].obs;
  var inscritos = <CursoDomain>[].obs;
  var isLoadingDictados = false.obs;
  var isLoadingInscritos = false.obs;
  var selectedTab = 0.obs;

  // Controladores de animación
  late AnimationController slideController;
  late AnimationController fadeController;

  // Categorías disponibles
  var categorias = [
    'Matemáticas', 'Programación', 'Diseño', 'Idiomas', 
    'Ciencias', 'Arte', 'Negocios', 'Tecnología'
  ].obs;

  // Controladores de formularios
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController descripcionController = TextEditingController();
  final TextEditingController estudianteController = TextEditingController();
  var selectedCategoriasCrear = <String>[].obs;
  var estudiantesCrear = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    initializeAnimations();
    loadInitialData();
  }

  void initializeAnimations() {
    slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    fadeController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  Future<void> loadInitialData() async {
    await refreshData();
  }

  // =============== FUNCIONES PARA CURSOS DICTADOS ===============

  Future<void> crearCurso() async {
    // Limpiar formulario
    nombreController.clear();
    descripcionController.clear();
    estudianteController.clear();
    selectedCategoriasCrear.clear();
    estudiantesCrear.clear();

    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(Icons.add_circle, color: Colors.blue, size: 28),
            const SizedBox(width: 8),
            const Text('Crear Nuevo Curso'),
          ],
        ),
        content: _buildCrearCursoForm(),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: _confirmarCrearCurso,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: const Text('Crear'),
          ),
        ],
      ),
    );
  }

  Widget _buildCrearCursoForm() {
    return SizedBox(
      width: double.maxFinite,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: nombreController,
              decoration: const InputDecoration(
                labelText: 'Nombre del curso',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.book),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descripcionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Descripción',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Categorías:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 120,
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: categorias.map((categoria) {
                    return Obx(() => FilterChip(
                      label: Text(categoria),
                      selected: selectedCategoriasCrear.contains(categoria),
                      onSelected: (selected) {
                        if (selected) {
                          selectedCategoriasCrear.add(categoria);
                        } else {
                          selectedCategoriasCrear.remove(categoria);
                        }
                      },
                      selectedColor: Colors.blue.withOpacity(0.2),
                      checkmarkColor: Colors.blue,
                    ));
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Estudiantes:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: estudianteController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre del estudiante',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                    onSubmitted: (value) => _agregarEstudianteCrear(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _agregarEstudianteCrear,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  child: const Icon(Icons.add),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Obx(() => Container(
              height: estudiantesCrear.isEmpty ? 50 : 120,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(8),
              child: estudiantesCrear.isEmpty
                  ? const Center(
                      child: Text(
                        'No hay estudiantes agregados',
                        style: TextStyle(
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: estudiantesCrear.length,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 4),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ListTile(
                            dense: true,
                            leading: const CircleAvatar(
                              radius: 16,
                              backgroundColor: Colors.blue,
                              child: Icon(
                                Icons.person,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                            title: Text(
                              estudiantesCrear[index],
                              style: const TextStyle(fontSize: 14),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.close, size: 18, color: Colors.red),
                              onPressed: () => _eliminarEstudianteCrear(index),
                            ),
                          ),
                        );
                      },
                    ),
            )),
            const SizedBox(height: 8),
            Obx(() => Text(
              'Total: ${estudiantesCrear.length} estudiantes',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            )),
          ],
        ),
      ),
    );
  }

  void _agregarEstudianteCrear() {
    final nombre = estudianteController.text.trim();
    if (nombre.isEmpty) {
      Get.snackbar(
        'Error',
        'Por favor ingresa un nombre',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        icon: const Icon(Icons.error, color: Colors.white),
        duration: const Duration(seconds: 2),
      );
      return;
    }

    if (estudiantesCrear.contains(nombre)) {
      Get.snackbar(
        'Error',
        'Este estudiante ya está agregado',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        icon: const Icon(Icons.warning, color: Colors.white),
        duration: const Duration(seconds: 2),
      );
      return;
    }

    estudiantesCrear.add(nombre);
    estudianteController.clear();
    
    Get.snackbar(
      'Agregado',
      'Estudiante "$nombre" agregado',
      backgroundColor: Colors.green,
      colorText: Colors.white,
      icon: const Icon(Icons.check, color: Colors.white),
      duration: const Duration(seconds: 1),
    );
  }

  void _eliminarEstudianteCrear(int index) {
    final nombre = estudiantesCrear[index];
    estudiantesCrear.removeAt(index);
    
    Get.snackbar(
      'Eliminado',
      'Estudiante "$nombre" eliminado',
      backgroundColor: Colors.red,
      colorText: Colors.white,
      icon: const Icon(Icons.delete, color: Colors.white),
      duration: const Duration(seconds: 1),
    );
  }

  Future<void> _confirmarCrearCurso() async {
    if (nombreController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'El nombre del curso es obligatorio',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        icon: const Icon(Icons.error, color: Colors.white),
      );
      return;
    }

    try {
      final userId = authController.currentUser.value?.id;
      if (userId == null) {
        Get.snackbar(
          'Error',
          'Usuario no autenticado',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      await cursoUseCase.createCurso(
        nombre: nombreController.text.trim(),
        descripcion: descripcionController.text.trim(),
        profesorId: userId,
        categorias: selectedCategoriasCrear.toList(),
        estudiantesNombres: estudiantesCrear.toList(),
      );
      
      Get.back();
      await refreshData(); // Recargar datos
      
      Get.snackbar(
        'Éxito',
        'Curso "${nombreController.text}" creado con ${estudiantesCrear.length} estudiantes',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        icon: const Icon(Icons.check_circle, color: Colors.white),
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error al crear curso: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> eliminarCurso(CursoDomain curso) async {
    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.warning, color: Colors.red),
            const SizedBox(width: 8),
            const Text('Confirmar Eliminación'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('¿Estás seguro de que quieres eliminar el curso?'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.school, color: Colors.red),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          curso.nombre,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${curso.estudiantesNombres.length} estudiantes',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Esta acción no se puede deshacer.',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              try {
                await cursoUseCase.deleteCurso(curso.id!);
                Get.back();
                await refreshData();
                
                Get.snackbar(
                  'Eliminado',
                  'Curso "${curso.nombre}" eliminado correctamente',
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                  icon: const Icon(Icons.delete, color: Colors.white),
                  duration: const Duration(seconds: 3),
                );
              } catch (e) {
                Get.back();
                Get.snackbar(
                  'Error',
                  'Error al eliminar curso: ${e.toString()}',
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
              }
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  // =============== FUNCIONES PARA CURSOS INSCRITOS ===============

  Future<void> inscribirseEnCurso(String codigoRegistro) async {
    try {
      final userId = authController.currentUser.value?.id;
      if (userId == null) {
        Get.snackbar('Error', 'Usuario no autenticado');
        return;
      }

      await cursoUseCase.inscribirseEnCurso(userId, codigoRegistro);
      await refreshData();
      
      Get.snackbar(
        'Éxito',
        'Te has inscrito correctamente al curso',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // =============== UTILIDADES ===============

  void changeTab(int index) {
    selectedTab.value = index;
    slideController.reset();
    slideController.forward();
  }

  Future<void> refreshData() async {
    try {
      isLoadingDictados.value = true;
      isLoadingInscritos.value = true;
      
      final userId = authController.currentUser.value?.id;
      if (userId == null) return;

      // Cargar cursos dictados por el usuario actual
      final cursosProfesor = await cursoUseCase.getCursosPorProfesor(userId);
      dictados.assignAll(cursosProfesor);

      // Cargar cursos en los que está inscrito el usuario
      final cursosInscritos = await cursoUseCase.getCursosInscritos(userId);
      inscritos.assignAll(cursosInscritos);

    } catch (e) {
      Get.snackbar(
        'Error',
        'Error al cargar datos: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoadingDictados.value = false;
      isLoadingInscritos.value = false;
    }
  }

  @override
  void onClose() {
    slideController.dispose();
    fadeController.dispose();
    nombreController.dispose();
    descripcionController.dispose();
    estudianteController.dispose();
    super.onClose();
  }
}