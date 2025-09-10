// ignore_for_file: deprecated_member_use, duplicate_ignore

import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Modelo para los cursos
class Curso {
  String id;
  String nombre;
  String imagen;
  String descripcion;
  List<String> categorias;
  DateTime fechaCreacion;
  int estudiantes;

  Curso({
    required this.id,
    required this.nombre,
    required this.imagen,
    this.descripcion = '',
    this.categorias = const [],
    DateTime? fechaCreacion,
    this.estudiantes = 0,
  }) : fechaCreacion = fechaCreacion ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'id': id,
    'nombre': nombre,
    'imagen': imagen,
    'descripcion': descripcion,
    'categorias': categorias,
    'fechaCreacion': fechaCreacion.toIso8601String(),
    'estudiantes': estudiantes,
  };

  factory Curso.fromJson(Map<String, dynamic> json) => Curso(
    id: json['id'],
    nombre: json['nombre'],
    imagen: json['imagen'],
    descripcion: json['descripcion'] ?? '',
    categorias: List<String>.from(json['categorias'] ?? []),
    fechaCreacion: DateTime.parse(json['fechaCreacion']),
    estudiantes: json['estudiantes'] ?? 0,
  );
}

class HomeController extends GetxController with GetTickerProviderStateMixin {
  // Información del usuario
  var userName = 'Juan'.obs;
  var userAvatar = 'assets/images/avatar.png'.obs;

  // Listas de cursos
  var dictados = <Curso>[].obs;
  var inscritos = <Curso>[].obs;

  // Estados de UI
  var isLoadingDictados = false.obs;
  var isLoadingInscritos = false.obs;
  var selectedTab = 0.obs;

  // Controladores de animación
  late AnimationController slideController;
  late AnimationController fadeController;

  // Categorías disponibles
  var categorias = [
    'Matemáticas',
    'Programación',
    'Diseño',
    'Idiomas',
    'Ciencias',
    'Arte',
    'Negocios',
    'Tecnología',
  ].obs;

  // Controladores de formularios
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController descripcionController = TextEditingController();
  var selectedCategoriasCrear = <String>[].obs;

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

  void loadInitialData() {
    // Datos iniciales de ejemplo
    dictados.addAll([
      Curso(
        id: '1',
        nombre: 'Cálculo Diferencial',
        imagen: 'assets/images/calculo.png',
        descripcion: 'Curso completo de cálculo diferencial para ingeniería',
        categorias: ['Matemáticas', 'Ciencias'],
        estudiantes: 145,
      ),
      Curso(
        id: '2',
        nombre: 'Análisis de Datos',
        imagen: 'assets/images/analisis.png',
        descripcion: 'Aprende a analizar datos con Python y R',
        categorias: ['Programación', 'Tecnología'],
        estudiantes: 89,
      ),
    ]);

    inscritos.addAll([
      Curso(
        id: '3',
        nombre: 'Flutter Avanzado',
        imagen: 'assets/images/flutter.png',
        descripcion: 'Desarrollo de aplicaciones móviles avanzadas',
        categorias: ['Programación', 'Tecnología'],
        estudiantes: 234,
      ),
      Curso(
        id: '4',
        nombre: 'Diseño UX/UI',
        imagen: 'assets/images/design.png',
        descripcion: 'Principios fundamentales del diseño de interfaces',
        categorias: ['Diseño', 'Arte'],
        estudiantes: 167,
      ),
    ]);
  }

  // =============== FUNCIONES PARA CURSOS DICTADOS ===============

  void crearCurso() {
    // Limpiar formulario
    nombreController.clear();
    descripcionController.clear();
    selectedCategoriasCrear.clear();

    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(Icons.add_circle, color: Colors.blue, size: 28),
            const SizedBox(width: 8),
            const Text('Crear Nuevo Curso'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildCrearCursoForm(),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: gestionarEstudiantes,
                icon: const Icon(Icons.people),
                label: const Text('Gestionar Estudiantes'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
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
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 120,
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: categorias.map((categoria) {
                    return Obx(
                      () => FilterChip(
                        label: Text(categoria),
                        selected: selectedCategoriasCrear.contains(categoria),
                        onSelected: (selected) {
                          if (selected) {
                            selectedCategoriasCrear.add(categoria);
                          } else {
                            selectedCategoriasCrear.remove(categoria);
                          }
                        },
                        // ignore: deprecated_member_use
                        selectedColor: Colors.blue.withOpacity(0.2),
                        checkmarkColor: Colors.blue,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmarCrearCurso() {
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

    final nuevoCurso = Curso(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      nombre: nombreController.text.trim(),
      imagen: 'assets/images/default_course.png',
      descripcion: descripcionController.text.trim(),
      categorias: selectedCategoriasCrear.toList(),
    );

    dictados.add(nuevoCurso);
    Get.back();

    Get.snackbar(
      'Éxito',
      'Curso "${nuevoCurso.nombre}" creado correctamente',
      backgroundColor: Colors.green,
      colorText: Colors.white,
      icon: const Icon(Icons.check_circle, color: Colors.white),
      duration: const Duration(seconds: 3),
    );
  }

  void mostrarMenuCurso(Curso curso, BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Título del curso
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                curso.nombre,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 8),
            const Divider(),
            // Opciones del menú
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.blue),
              title: const Text('Editar Curso'),
              subtitle: const Text('Modificar nombre y descripción'),
              onTap: () => editarCurso(curso),
            ),
            ListTile(
              leading: const Icon(Icons.category, color: Colors.orange),
              title: const Text('Ver Categorías'),
              subtitle: Text('${curso.categorias.length} categorías asignadas'),
              onTap: () => verCategorias(curso),
            ),
            ListTile(
              leading: const Icon(Icons.people, color: Colors.green),
              title: const Text('Estudiantes'),
              subtitle: Text('${curso.estudiantes} estudiantes inscritos'),
              onTap: () => verEstudiantes(curso),
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Eliminar Curso'),
              subtitle: const Text('Esta acción no se puede deshacer'),
              onTap: () => eliminarCurso(curso),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void editarCurso(Curso curso) {
    Get.back(); // Cerrar bottom sheet

    final nombreEditController = TextEditingController(text: curso.nombre);
    final descripcionEditController = TextEditingController(
      text: curso.descripcion,
    );

    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.edit, color: Colors.blue),
            const SizedBox(width: 8),
            const Text('Editar Curso'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nombreEditController,
              decoration: const InputDecoration(
                labelText: 'Nombre del curso',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.book),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descripcionEditController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Descripción',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
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
            onPressed: () {
              if (nombreEditController.text.trim().isEmpty) {
                Get.snackbar(
                  'Error',
                  'El nombre del curso es obligatorio',
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
                return;
              }

              final index = dictados.indexWhere((c) => c.id == curso.id);
              if (index != -1) {
                dictados[index].nombre = nombreEditController.text.trim();
                dictados[index].descripcion = descripcionEditController.text
                    .trim();
                dictados.refresh();
              }
              Get.back();
              Get.snackbar(
                'Éxito',
                'Curso actualizado correctamente',
                backgroundColor: Colors.green,
                colorText: Colors.white,
                icon: const Icon(Icons.check_circle, color: Colors.white),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void verCategorias(Curso curso) {
    Get.back(); // Cerrar bottom sheet
    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.category, color: Colors.orange),
            const SizedBox(width: 8),
            Text('Categorías de ${curso.nombre}'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (curso.categorias.isEmpty)
                Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Icon(
                        Icons.category_outlined,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 8),
                      const Text('No hay categorías asignadas'),
                    ],
                  ),
                )
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: curso.categorias.map((categoria) {
                    return Chip(
                      label: Text(categoria),
                      backgroundColor: Colors.blue.withOpacity(0.1),
                      avatar: const Icon(Icons.label, size: 16),
                    );
                  }).toList(),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cerrar')),
          ElevatedButton(
            onPressed: () => _editarCategorias(curso),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Editar'),
          ),
        ],
      ),
    );
  }

  void _editarCategorias(Curso curso) {
    Get.back();
    final selectedCategorias = RxList<String>(curso.categorias);

    Get.dialog(
      AlertDialog(
        title: const Text('Editar Categorías'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: Column(
            children: [
              const Text(
                'Selecciona las categorías para este curso:',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: categorias.map((categoria) {
                      return Obx(
                        () => FilterChip(
                          label: Text(categoria),
                          selected: selectedCategorias.contains(categoria),
                          onSelected: (selected) {
                            if (selected) {
                              selectedCategorias.add(categoria);
                            } else {
                              selectedCategorias.remove(categoria);
                            }
                          },
                          selectedColor: Colors.blue.withOpacity(0.2),
                          checkmarkColor: Colors.blue,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final index = dictados.indexWhere((c) => c.id == curso.id);
              if (index != -1) {
                dictados[index].categorias = selectedCategorias.toList();
                dictados.refresh();
              }
              Get.back();
              Get.snackbar(
                'Éxito',
                'Categorías actualizadas correctamente',
                backgroundColor: Colors.green,
                colorText: Colors.white,
                icon: const Icon(Icons.check_circle, color: Colors.white),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void eliminarCurso(Curso curso) {
    Get.back(); // Cerrar bottom sheet
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
            Text('¿Estás seguro de que quieres eliminar el curso?'),
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
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${curso.estudiantes} estudiantes',
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
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
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
            onPressed: () {
              dictados.removeWhere((c) => c.id == curso.id);
              Get.back();
              Get.snackbar(
                'Eliminado',
                'Curso "${curso.nombre}" eliminado correctamente',
                backgroundColor: Colors.red,
                colorText: Colors.white,
                icon: const Icon(Icons.delete, color: Colors.white),
                duration: const Duration(seconds: 3),
              );
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  // =============== FUNCIONES PARA CURSOS INSCRITOS ===============

  void inscribirse() {
    Get.snackbar(
      'Información',
      'Funcionalidad de inscripción próximamente',
      backgroundColor: Colors.orange,
      colorText: Colors.white,
      icon: const Icon(Icons.info, color: Colors.white),
      duration: const Duration(seconds: 3),
    );
  }

  // =============== UTILIDADES ===============

  void changeTab(int index) {
    selectedTab.value = index;
    slideController.reset();
    slideController.forward();
  }

  void refreshData() {
    isLoadingDictados.value = true;
    isLoadingInscritos.value = true;

    // Simular carga de datos
    Future.delayed(const Duration(seconds: 1), () {
      isLoadingDictados.value = false;
      isLoadingInscritos.value = false;
      Get.snackbar(
        'Actualizado',
        'Datos actualizados correctamente',
        backgroundColor: Colors.blue,
        colorText: Colors.white,
        icon: const Icon(Icons.refresh, color: Colors.white),
        duration: const Duration(seconds: 2),
      );
    });
  }

  @override
  void onClose() {
    slideController.dispose();
    fadeController.dispose();
    nombreController.dispose();
    descripcionController.dispose();
    super.onClose();
  }

  // Agregar después de las otras funciones del controller
  void verEstudiantes(Curso curso) {
    Get.back(); // Cerrar bottom sheet
    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.people, color: Colors.green),
            const SizedBox(width: 8),
            Text('Estudiantes de ${curso.nombre}'),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${curso.estudiantes} estudiantes inscritos'),
                  TextButton.icon(
                    onPressed: () => _agregarEstudiante(curso),
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Agregar'),
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: curso.estudiantes == 0
                    ? const Center(child: Text('No hay estudiantes inscritos'))
                    : ListView.builder(
                        itemCount: curso.estudiantes,
                        itemBuilder: (context, index) {
                          return ListTile(
                            leading: CircleAvatar(child: Text('${index + 1}')),
                            title: Text('Estudiante ${index + 1}'),
                            subtitle: Text('estudiante${index + 1}@email.com'),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () =>
                                  _eliminarEstudiante(curso, index),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cerrar')),
        ],
      ),
    );
  }

  void _agregarEstudiante(Curso curso) {
    final nombreController = TextEditingController();
    final emailController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('Agregar Estudiante'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nombreController,
              decoration: const InputDecoration(
                labelText: 'Nombre del estudiante',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
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
            onPressed: () {
              if (nombreController.text.trim().isEmpty) {
                Get.snackbar('Error', 'El nombre es obligatorio');
                return;
              }

              final index = dictados.indexWhere((c) => c.id == curso.id);
              if (index != -1) {
                dictados[index].estudiantes++;
                dictados.refresh();
              }
              Get.back();
              Get.back(); // Cerrar diálogo de estudiantes también
              Get.snackbar(
                'Éxito',
                'Estudiante agregado correctamente',
                backgroundColor: Colors.green,
                colorText: Colors.white,
              );
            },
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
  }

  void _eliminarEstudiante(Curso curso, int index) {
    Get.dialog(
      AlertDialog(
        title: const Text('Eliminar Estudiante'),
        content: Text('¿Eliminar a Estudiante ${index + 1}?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              final cursoIndex = dictados.indexWhere((c) => c.id == curso.id);
              if (cursoIndex != -1 && dictados[cursoIndex].estudiantes > 0) {
                dictados[cursoIndex].estudiantes--;
                dictados.refresh();
              }
              Get.back();
              Get.snackbar(
                'Eliminado',
                'Estudiante eliminado correctamente',
                backgroundColor: Colors.red,
                colorText: Colors.white,
              );
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void gestionarEstudiantes() {
    final estudiantes = <String>[].obs;

    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.people, color: Colors.blue),
            const SizedBox(width: 8),
            const Text('Gestión de Estudiantes'),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: Column(
            children: [
              // Formulario para agregar estudiantes
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Nombre del estudiante',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                onSubmitted: (value) {
                  if (value.trim().isNotEmpty) {
                    estudiantes.add(value.trim());
                  }
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  final nombre = estudiantes.last;
                  if (nombre.isNotEmpty) {
                    estudiantes.add(nombre);
                  }
                },
                icon: const Icon(Icons.add),
                label: const Text('Agregar Estudiante'),
              ),
              const SizedBox(height: 16),
              const Divider(),
              const Text(
                'Lista de Estudiantes:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              // Lista de estudiantes
              Expanded(
                child: Obx(
                  () => estudiantes.isEmpty
                      ? const Center(
                          child: Text('No hay estudiantes agregados'),
                        )
                      : ListView.builder(
                          itemCount: estudiantes.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              leading: CircleAvatar(
                                child: Text('${index + 1}'),
                              ),
                              title: Text(estudiantes[index]),
                              trailing: IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () {
                                  estudiantes.removeAt(index);
                                },
                              ),
                            );
                          },
                        ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              // Aquí puedes guardar la lista de estudiantes
              Get.back();
              Get.snackbar(
                'Éxito',
                'Estudiantes gestionados correctamente',
                backgroundColor: Colors.green,
                colorText: Colors.white,
              );
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }
}
