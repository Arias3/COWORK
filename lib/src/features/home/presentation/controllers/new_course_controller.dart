import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domain/use_case/curso_usecase.dart';
import '../../../auth/presentation/controllers/login_controller.dart';

class NewCourseController extends GetxController {
  final CursoUseCase cursoUseCase;
  final AuthenticationController authController;

  NewCourseController(this.cursoUseCase, this.authController);

  var estudiantes = <String>[].obs;
  var nombreCurso = ''.obs;
  var descripcion = ''.obs;
  var estudianteInput = ''.obs;
  var selectedCategorias = <String>[].obs;
  var isLoading = false.obs;

  // Categorías disponibles
  var categorias = [
    'Matemáticas', 'Programación', 'Diseño', 'Idiomas', 
    'Ciencias', 'Arte', 'Negocios', 'Tecnología'
  ].obs;

  void agregarEstudiante(String nombre) {
    if (nombre.isNotEmpty && !estudiantes.contains(nombre)) {
      estudiantes.add(nombre);
      estudianteInput.value = '';
      
      Get.snackbar(
        'Agregado',
        'Estudiante "$nombre" agregado correctamente',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 1),
      );
    } else if (estudiantes.contains(nombre)) {
      Get.snackbar(
        'Error',
        'Este estudiante ya está en la lista',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        duration: const Duration(seconds: 1),
      );
    }
  }

  void eliminarEstudiante(int index) {
    if (index >= 0 && index < estudiantes.length) {
      final nombre = estudiantes[index];
      estudiantes.removeAt(index);
      
      Get.snackbar(
        'Eliminado',
        'Estudiante "$nombre" eliminado de la lista',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 1),
      );
    }
  }

  void toggleCategoria(String categoria) {
    if (selectedCategorias.contains(categoria)) {
      selectedCategorias.remove(categoria);
    } else {
      selectedCategorias.add(categoria);
    }
  }

  Future<bool> crearCurso() async {
    if (nombreCurso.value.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'El nombre del curso es obligatorio',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    try {
      isLoading.value = true;
      
      final userId = authController.currentUser.value?.id;
      if (userId == null) {
        Get.snackbar('Error', 'Usuario no autenticado');
        return false;
      }

      await cursoUseCase.createCurso(
        nombre: nombreCurso.value.trim(),
        descripcion: descripcion.value.trim(),
        profesorId: userId,
        categorias: selectedCategorias.toList(),
        estudiantesNombres: estudiantes.toList(),
      );

      // Limpiar formulario
      _limpiarFormulario();
      
      Get.snackbar(
        'Éxito',
        'Curso "${nombreCurso.value}" creado correctamente',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      
      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error al crear curso: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  void _limpiarFormulario() {
    estudiantes.clear();
    nombreCurso.value = '';
    descripcion.value = '';
    estudianteInput.value = '';
    selectedCategorias.clear();
  }
}