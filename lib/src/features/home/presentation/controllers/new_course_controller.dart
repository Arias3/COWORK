import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:get/get.dart';
import '../../domain/use_case/curso_usecase.dart';
import '../../../auth/presentation/controllers/login_controller.dart';
import '../../../auth/domain/use_case/usuario_usecase.dart';
import '../../../auth/domain/entities/user_entity.dart';
import './home_controller.dart';
import 'dart:math';



class NewCourseController extends GetxController {
  final CursoUseCase cursoUseCase;
  final AuthenticationController authController;
  final UsuarioUseCase usuarioUseCase;

  NewCourseController(
    this.cursoUseCase, 
    this.authController,
    this.usuarioUseCase,
  );

  // Variables existentes
  var nombreCurso = ''.obs;
  var descripcion = ''.obs;
  var selectedCategorias = <String>[].obs;
  var isLoading = false.obs;

  // NUEVAS variables para manejo de usuarios
  var todosLosEstudiantes = <Usuario>[].obs;
  var estudiantesDisponibles = <Usuario>[].obs;
  var estudiantesSeleccionados = <Usuario>[].obs;
  var searchQuery = ''.obs;
  var isLoadingStudents = false.obs;

  var codigoRegistro = ''.obs;

  // Categorías disponibles
  var categorias = [
    'Matemáticas', 'Programación', 'Diseño', 'Idiomas', 
    'Ciencias', 'Arte', 'Negocios', 'Tecnología'
  ].obs;

  @override
void onInit() {
  super.onInit();
  print('🚀🚀🚀 CONTROLADOR DEBUG INICIADO 🚀🚀🚀');
  print('NewCourseController con debug activo');
  cargarEstudiantes();
  
  // Debug: Escuchar cambios en la búsqueda
  debounce(searchQuery, (query) {
    print('🔍 Búsqueda activa: "$query" (length: ${query.length})');
    filtrarEstudiantes();
    print('📊 Estudiantes disponibles después del filtro: ${estudiantesDisponibles.length}');
  }, time: const Duration(milliseconds: 500));
  
  // Escuchar cambios en searchQuery para debug
  ever(searchQuery, (String query) {
    print('👂 SearchQuery cambió inmediatamente a: "$query"');
  });
}

  // ========================================================================
  // MÉTODOS PARA CARGAR Y FILTRAR ESTUDIANTES (CON DEBUG)
  // ========================================================================

  Future<void> cargarEstudiantes() async {
    try {
      isLoadingStudents.value = true;
      print('🔄 Iniciando carga de estudiantes desde BD...');
      
      // Obtener todos los usuarios del sistema (tu lógica existente)
      final usuarios = await usuarioUseCase.getUsuarios();
      print('👥 Total usuarios obtenidos: ${usuarios.length}');
      
      // Debug: mostrar primeros 3 usuarios para verificar datos
      if (usuarios.isNotEmpty) {
        print('📋 Primeros usuarios (sample):');
        for (var i = 0; i < usuarios.length && i < 3; i++) {
          final usuario = usuarios[i];
          print('  - ${usuario.nombre} (${usuario.email}) - Rol: ${usuario.rol}');
        }
      }
      
      // Filtrar solo estudiantes (excluir profesores)
      todosLosEstudiantes.value = usuarios
          .where((usuario) => usuario.rol == 'estudiante')
          .toList();
      
      print('🎓 Estudiantes filtrados: ${todosLosEstudiantes.length}');
          
      // Inicialmente todos están disponibles
      estudiantesDisponibles.value = List.from(todosLosEstudiantes);
      print('✅ Lista inicial de disponibles: ${estudiantesDisponibles.length}');
      
    } catch (e) {
      print('❌ Error en cargarEstudiantes: $e');
      Get.snackbar(
        'Error',
        'Error al cargar estudiantes: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoadingStudents.value = false;
      print('🏁 Carga finalizada. Loading: ${isLoadingStudents.value}');
    }
  }

  void filtrarEstudiantes() {
    print('\n🔧 === INICIANDO FILTRADO ===');
    print('Query actual: "${searchQuery.value}" (length: ${searchQuery.value.length})');
    print('Total en BD: ${todosLosEstudiantes.length}');
    print('Seleccionados: ${estudiantesSeleccionados.length}');
    
    if (searchQuery.value.trim().isEmpty) {
      print('📝 Sin query - mostrando todos los disponibles');
      // Si no hay búsqueda, mostrar todos los disponibles
      estudiantesDisponibles.value = todosLosEstudiantes
          .where((estudiante) => !estudiantesSeleccionados
              .any((selected) => selected.id == estudiante.id))
          .toList();
    } else {
      print('🔍 Filtrando con query: "${searchQuery.value}"');
      // Filtrar por nombre o email
      final query = searchQuery.value.toLowerCase();
      
      final resultados = <Usuario>[];
      
      for (var estudiante in todosLosEstudiantes) {
        // Verificar si no está seleccionado
        final yaSeleccionado = estudiantesSeleccionados
            .any((selected) => selected.id == estudiante.id);
        
        if (!yaSeleccionado) {
          // Verificar si coincide con la búsqueda
          final coincideNombre = estudiante.nombre.toLowerCase().contains(query);
          final coincideEmail = estudiante.email.toLowerCase().contains(query);
          
          if (coincideNombre || coincideEmail) {
            resultados.add(estudiante);
            print('  ✓ Coincidencia: ${estudiante.nombre} (${estudiante.email})');
          }
        }
      }
      
      estudiantesDisponibles.value = resultados;
    }
    
    print('✅ RESULTADO FINAL: ${estudiantesDisponibles.length} estudiantes disponibles');
    print('=== FIN FILTRADO ===\n');
    
    // Forzar actualización de UI
    estudiantesDisponibles.refresh();
  }

  // ========================================================================
  // MÉTODOS PARA MANEJAR SELECCIÓN DE ESTUDIANTES (CON DEBUG)
  // ========================================================================

  void agregarEstudiante(Usuario estudiante) {
    print('➕ Agregando: ${estudiante.nombre}');
    
    if (!estudiantesSeleccionados.any((e) => e.id == estudiante.id)) {
      estudiantesSeleccionados.add(estudiante);
      print('  ✅ Agregado. Total seleccionados: ${estudiantesSeleccionados.length}');
      
      filtrarEstudiantes(); // Actualizar lista disponible
      
      Get.snackbar(
        'Agregado',
        'Estudiante "${estudiante.nombre}" agregado al curso',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 1),
      );
    } else {
      print('  ⚠️ Ya estaba seleccionado');
    }
  }

  void eliminarEstudiante(Usuario estudiante) {
    print('➖ Eliminando: ${estudiante.nombre}');
    estudiantesSeleccionados.removeWhere((e) => e.id == estudiante.id);
    print('  ✅ Eliminado. Total seleccionados: ${estudiantesSeleccionados.length}');
    
    filtrarEstudiantes(); // Actualizar lista disponible
    
    Get.snackbar(
      'Eliminado',
      'Estudiante "${estudiante.nombre}" eliminado del curso',
      backgroundColor: Colors.orange,
      colorText: Colors.white,
      duration: const Duration(seconds: 1),
    );
  }

  void limpiarSeleccion() {
    print('🧹 Limpiando ${estudiantesSeleccionados.length} estudiantes seleccionados');
    estudiantesSeleccionados.clear();
    filtrarEstudiantes();
    
    Get.snackbar(
      'Limpiado',
      'Se eliminaron todos los estudiantes seleccionados',
      backgroundColor: Colors.blue,
      colorText: Colors.white,
      duration: const Duration(seconds: 1),
    );
  }

  // ========================================================================
  // MÉTODOS PARA CATEGORÍAS (SIN CAMBIOS)
  // ========================================================================

  void toggleCategoria(String categoria) {
    if (selectedCategorias.contains(categoria)) {
      selectedCategorias.remove(categoria);
    } else {
      selectedCategorias.add(categoria);
    }
  }

  // ========================================================================
  // MÉTODO PARA CREAR CURSO (MODIFICADO)
  // ========================================================================

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

  if (descripcion.value.trim().isEmpty) {
    Get.snackbar(
      'Error',
      'La descripción del curso es obligatoria',
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
    return false;
  }

  // Add registration code validation
  if (!validarCodigoRegistro()) {
    return false;
  }

  try {
    isLoading.value = true;

    final userId = authController.currentUser.value?.id;
    if (userId == null) {
      Get.snackbar('Error', 'Usuario no autenticado');
      return false;
    }

    final totalEstudiantes = estudiantesSeleccionados.length;
    final estudiantesNombres = estudiantesSeleccionados.map((e) => e.nombre).toList();

    // Create the course with the registration code
    final cursoId = await cursoUseCase.createCurso(
      nombre: nombreCurso.value.trim(),
      descripcion: descripcion.value.trim(),
      profesorId: userId,
      codigoRegistro: codigoRegistro.value.trim(), // Pass the registration code
      categorias: selectedCategorias.toList(),
      estudiantesNombres: estudiantesNombres,
    );

    // Auto-enroll students
    await _inscribirEstudiantesAutomaticamente(cursoId);

    // Refresh home data
    final homeController = Get.find<HomeController>();
    await homeController.refreshData();

    // Clear form AFTER success
    _limpiarFormulario();

    // Show success message
    Get.snackbar(
      'Éxito',
      'Curso "${nombreCurso.value}" creado correctamente con código "${codigoRegistro.value}" y $totalEstudiantes estudiante(s) inscritos',
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 4),
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


  // ========================================================================
  // MÉTODO PARA INSCRIBIR ESTUDIANTES AUTOMÁTICAMENTE
  // ========================================================================

  Future<void> _inscribirEstudiantesAutomaticamente(int cursoId) async {
    try {
      // Obtener el curso recién creado para conseguir su código de registro
      final curso = await cursoUseCase.getCursoById(cursoId);
      if (curso?.codigoRegistro == null) {
        throw Exception('No se pudo obtener el código del curso');
      }

      // Inscribir cada estudiante seleccionado
      for (final estudiante in estudiantesSeleccionados) {
        if (estudiante.id != null) {
          await cursoUseCase.inscribirseEnCurso(
            estudiante.id!, 
            curso!.codigoRegistro,
          );
        }
      }
      
      print('✅ ${estudiantesSeleccionados.length} estudiantes inscritos automáticamente');
    } catch (e) {
      print('⚠️ Error al inscribir estudiantes automáticamente: $e');
      // No lanzamos el error para no interrumpir la creación del curso
      Get.snackbar(
        'Advertencia',
        'El curso se creó pero algunos estudiantes no pudieron inscribirse automáticamente',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    }
  }

  // ========================================================================
  // MÉTODO PARA LIMPIAR FORMULARIO (MODIFICADO)
  // ========================================================================

  void _limpiarFormulario() {
  nombreCurso.value = '';
  descripcion.value = '';
  codigoRegistro.value = ''; // Clear registration code
  selectedCategorias.clear();
  estudiantesSeleccionados.clear();
  searchQuery.value = '';
  filtrarEstudiantes();
}

  // ========================================================================
  // MÉTODOS DE DIAGNÓSTICO Y VERIFICACIÓN (MEJORADOS)
  // ========================================================================

  void mostrarEstadisticas() {
    print('\n📊 === ESTADÍSTICAS DE ESTUDIANTES ===');
    print('🔢 Contadores:');
    print('  - Total en BD: ${todosLosEstudiantes.length}');
    print('  - Disponibles para mostrar: ${estudiantesDisponibles.length}');
    print('  - Seleccionados: ${estudiantesSeleccionados.length}');
    print('🔍 Estado de búsqueda:');
    print('  - Query: "${searchQuery.value}"');
    print('  - Query length: ${searchQuery.value.length}');
    print('  - Loading: ${isLoadingStudents.value}');
    
    print('\n👥 Estudiantes en BD:');
    if (todosLosEstudiantes.isNotEmpty) {
      for (var i = 0; i < todosLosEstudiantes.length; i++) {
        final est = todosLosEstudiantes[i];
        print('  ${i + 1}. ${est.nombre} (${est.email}) - ID: ${est.id}');
      }
    } else {
      print('  ❌ Lista vacía');
    }
    
    print('\n📋 Estudiantes disponibles para UI:');
    if (estudiantesDisponibles.isNotEmpty) {
      for (var i = 0; i < estudiantesDisponibles.length; i++) {
        final est = estudiantesDisponibles[i];
        print('  ${i + 1}. ${est.nombre} (${est.email})');
      }
    } else {
      print('  ❌ Lista vacía');
    }
    
    if (estudiantesSeleccionados.isNotEmpty) {
      print('\n✅ Estudiantes seleccionados:');
      for (var i = 0; i < estudiantesSeleccionados.length; i++) {
        final est = estudiantesSeleccionados[i];
        print('  ${i + 1}. ${est.nombre} (${est.email})');
      }
    }
    print('=== FIN ESTADÍSTICAS ===\n');
  }

  // Método para debug rápido del estado de búsqueda
  void debugBusqueda() {
    print('\n🔍 === DEBUG BÚSQUEDA ===');
    print('searchQuery.value: "${searchQuery.value}"');
    print('searchQuery.value.length: ${searchQuery.value.length}');
    print('searchQuery.value.trim().isEmpty: ${searchQuery.value.trim().isEmpty}');
    print('estudiantesDisponibles.length: ${estudiantesDisponibles.length}');
    print('=== FIN DEBUG BÚSQUEDA ===\n');
  }

  int get totalEstudiantesDisponibles => estudiantesDisponibles.length;
  int get totalEstudiantesSeleccionados => estudiantesSeleccionados.length;
  
  bool get hayEstudiantesSeleccionados => estudiantesSeleccionados.isNotEmpty;
  bool get hayEstudiantesDisponibles => estudiantesDisponibles.isNotEmpty;

  String get resumenSeleccion {
    if (estudiantesSeleccionados.isEmpty) {
      return 'No hay estudiantes seleccionados';
    }
    return '${estudiantesSeleccionados.length} estudiante(s) seleccionado(s)';
  }

  void generarCodigoAleatorio() {
  const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  final random = Random();
  final codigo = String.fromCharCodes(Iterable.generate(
    6, (_) => chars.codeUnitAt(random.nextInt(chars.length))
  ));
  codigoRegistro.value = codigo;
}

bool validarCodigoRegistro() {
  if (codigoRegistro.value.trim().isEmpty) {
    Get.snackbar(
      'Error',
      'El código de registro es obligatorio',
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
    return false;
  }
  
  if (codigoRegistro.value.trim().length < 4) {
    Get.snackbar(
      'Error',
      'El código debe tener al menos 4 caracteres',
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
    return false;
  }
  
  return true;
}

}