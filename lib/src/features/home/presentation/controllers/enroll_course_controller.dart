import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domain/entities/curso_entity.dart';
import '../../domain/use_case/curso_usecase.dart';
import '../../../auth/presentation/controllers/login_controller.dart';

class EnrollCourseController extends GetxController {
  final CursoUseCase cursoUseCase;
  final AuthenticationController authController;

  EnrollCourseController(this.cursoUseCase, this.authController);

  var cursos = <CursoDomain>[].obs;
  var isLoading = false.obs;
  var seleccionado = (-1).obs;

  @override
  void onInit() {
    super.onInit();
    loadCursos();
  }

  Future<void> loadCursos() async {
    try {
      isLoading.value = true;
      final todosCursos = await cursoUseCase.getCursos();
      cursos.assignAll(todosCursos);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error al cargar cursos: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void seleccionar(int index) {
    seleccionado.value = index;
    update();
  }

  Future<void> inscribirseEnCursoSeleccionado() async {
    if (seleccionado.value >= 0 && seleccionado.value < cursos.length) {
      final curso = cursos[seleccionado.value];
      
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

        await cursoUseCase.inscribirseEnCurso(userId, curso.codigoRegistro ?? '');
        
        Get.snackbar(
          'Éxito',
          'Te has inscrito correctamente al curso "${curso.nombre}"',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } catch (e) {
        Get.snackbar(
          'Error',
          'Error al inscribirse: ${e.toString()}',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }
}