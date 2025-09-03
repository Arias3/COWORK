import 'package:get/get.dart';

class HomeController extends GetxController {
  var userName = 'Juan'.obs;

  // Ejemplo de datos para dictados e inscritos
  var dictados = [
    {'nombre': 'Calculo 1', 'img': 'assets/images/calculo.png'},
    {'nombre': 'Analisis D', 'img': 'assets/images/analisis.png'},
  ].obs;

  var inscritos = [
    {'nombre': 'Calculo 1', 'img': 'assets/images/calculo.png'},
    {'nombre': 'Calculo 1', 'img': 'assets/images/calculo.png'},
    {'nombre': 'Calculo 1', 'img': 'assets/images/calculo.png'},
    {'nombre': 'Calculo 1', 'img': 'assets/images/calculo.png'},
  ].obs;

  void crearCurso() {
    // Lógica para crear curso
  }

  void inscribirse() {
    // Lógica para inscribirse
  }
}