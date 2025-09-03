import 'package:get/get.dart';

class NewCourseController extends GetxController {
  var estudiantes = <String>[].obs;
  var nombreCurso = ''.obs;
  var descripcion = ''.obs;
  var estudianteInput = ''.obs;

  void agregarEstudiante(String nombre) {
    if (nombre.isNotEmpty) {
      estudiantes.add(nombre);
      estudianteInput.value = '';
    }
  }

  void eliminarEstudiante(int index) {
    estudiantes.removeAt(index);
  }
}