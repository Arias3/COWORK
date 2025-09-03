import 'package:get/get.dart';

class EnrollCourseController extends GetxController {
  var cursos = [
    {'nombre': 'Calculo 1', 'descripcion': 'Curso de matemáticas básicas', 'img': 'assets/images/calculo.png'},
    {'nombre': 'Analisis D', 'descripcion': 'Curso de análisis de datos', 'img': 'assets/images/analisis.png'},
    {'nombre': 'Álgebra', 'descripcion': 'Curso de álgebra lineal', 'img': 'assets/images/algebra.png'},
  ].obs;

  var seleccionado = (-1).obs;

  void seleccionar(int index) {
  seleccionado.value = index;
  update(); // Forzar actualización del widget
    }
}