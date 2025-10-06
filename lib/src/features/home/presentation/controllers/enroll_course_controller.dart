import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domain/entities/curso_entity.dart';
import '../../domain/use_case/curso_usecase.dart';
import '../../../auth/presentation/controllers/roble_auth_login_controller.dart';

class EnrollCourseController extends GetxController {
  final CursoUseCase cursoUseCase;
  final RobleAuthLoginController authController;

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
      // Solo mostrar error si es crítico - no cargar cursos no impide usar la app
      print('❌ Error cargando cursos: $e');
      // Mensaje removido para evitar saturación
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
          // Error crítico - mostrar mensaje
          Get.snackbar(
            'Error de Autenticación',
            'Debes iniciar sesión para inscribirte',
            backgroundColor: Colors.red,
            colorText: Colors.white,
            duration: const Duration(seconds: 3),
          );
          return;
        }

        await cursoUseCase.inscribirseEnCurso(userId, curso.codigoRegistro);

        // Mensaje único y claro para inscripción exitosa
        Get.snackbar(
          '¡Inscrito al Curso!',
          'Te has inscrito a "${curso.nombre}" exitosamente',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      } catch (e) {
        Get.snackbar(
          'Error de Inscripción',
          'No se pudo completar la inscripción al curso',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }
    }
  }
}
