import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domain/use_case/curso_usecase.dart';
import '../../domain/entities/curso_entity.dart';
import '../../../auth/presentation/controllers/roble_auth_login_controller.dart';
import '../../../auth/domain/use_case/usuario_usecase.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../../../core/routes/app_routes.dart';

// Extensión para firstWhereOrNull si no está disponible
extension IterableExtension<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T) test) {
    for (T element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}

class HomeController extends GetxController with GetTickerProviderStateMixin {
  final CursoUseCase cursoUseCase;
  final RobleAuthLoginController authController;
  final UsuarioUseCase usuarioUseCase;

  HomeController(this.cursoUseCase, this.authController, this.usuarioUseCase);

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
    'Matemáticas',
    'Programación',
    'Diseño',
    'Idiomas',
    'Ciencias',
    'Arte',
    'Negocios',
    'Tecnología',
  ].obs;

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
                          style: const TextStyle(fontWeight: FontWeight.bold),
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
    super.onClose();
  }

  void abrirGestionEquipos(CursoDomain curso) {
    Get.toNamed(AppRoutes.categoriaEquipos, arguments: curso);
  }

  // =============== MÉTODOS CORREGIDOS PARA ESTUDIANTES REALES ===============

  Future<List<Usuario>> getEstudiantesReales(int cursoId) async {
    try {
      print('🔍 Obteniendo estudiantes reales del curso $cursoId');

      // Verificar que el ID sea válido
      if (cursoId == null || cursoId <= 0) {
        print('❌ ID de curso inválido: $cursoId');
        return [];
      }

      // 1. Verificar que el curso existe
      final curso = await cursoUseCase.getCursoById(cursoId);
      if (curso == null) {
        print('❌ No se encontró curso con ID: $cursoId');
        return [];
      }

      print('✅ Curso encontrado: ${curso.nombre} (Código: ${curso.codigoRegistro})');

      // 2. Obtener inscripciones del curso usando el método que existe
      final inscripciones = await cursoUseCase.getInscripcionesPorCurso(cursoId);
      print('📋 Inscripciones encontradas: ${inscripciones.length}');

      if (inscripciones.isEmpty) {
        print('❌ No hay inscripciones para el curso $cursoId');
        return [];
      }

      // 3. Obtener todos los usuarios del sistema
      final todosUsuarios = await usuarioUseCase.getUsuarios();
      print('👥 Total usuarios en sistema: ${todosUsuarios.length}');

      // 4. Filtrar solo los usuarios que están inscritos en este curso
      final estudiantesInscritos = <Usuario>[];
      for (var inscripcion in inscripciones) {
        print('🔍 Buscando usuario con ID: ${inscripcion.usuarioId}');
        
        final usuario = todosUsuarios.firstWhereOrNull(
          (u) => u.id == inscripcion.usuarioId,
        );
        
        if (usuario != null) {
          estudiantesInscritos.add(usuario);
          print('✅ Estudiante encontrado: ${usuario.nombre} (${usuario.email})');
        } else {
          print('⚠️ Usuario con ID ${inscripcion.usuarioId} no encontrado en la lista de usuarios');
          
          // Debug: mostrar algunos usuarios para comparar IDs
          if (todosUsuarios.isNotEmpty) {
            print('📋 Primeros usuarios disponibles:');
            for (int i = 0; i < todosUsuarios.length && i < 3; i++) {
              final u = todosUsuarios[i];
              print('  - ${u.nombre}: ID=${u.id}');
            }
          }
        }
      }

      print('🎓 Total estudiantes reales encontrados: ${estudiantesInscritos.length}');
      return estudiantesInscritos;
    } catch (e) {
      print('❌ Error obteniendo estudiantes reales: $e');
      print('Stack trace: ${StackTrace.current}');
      return [];
    }
  }

  Future<int> getNumeroEstudiantesReales(int cursoId) async {
    final estudiantes = await getEstudiantesReales(cursoId);
    return estudiantes.length;
  }

  void mostrarEstudiantesReales(CursoDomain curso) async {
    try {
      // Mostrar loading
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      final estudiantesReales = await getEstudiantesReales(curso.id!);

      // Cerrar loading
      Get.back();

      // Mostrar diálogo con estudiantes reales
      Get.dialog(
        AlertDialog(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Estudiantes de ${curso.nombre}'),
              Text(
                '${estudiantesReales.length} estudiante(s) inscrito(s)',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: estudiantesReales.isEmpty
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No hay estudiantes inscritos',
                        style: TextStyle(color: Colors.grey[600], fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Comparte el código "${curso.codigoRegistro}" para que los estudiantes se inscriban',
                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: estudiantesReales.length,
                    itemBuilder: (context, index) {
                      final estudiante = estudiantesReales[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue.withOpacity(0.1),
                          child: Text(
                            estudiante.nombre[0].toUpperCase(),
                            style: const TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(estudiante.nombre),
                        subtitle: Text(
                          estudiante.email,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'INSCRITO',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.green[700],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          actions: [
            if (estudiantesReales.isNotEmpty)
              TextButton(
                onPressed: () {
                  Get.back();
                  Get.snackbar(
                    'Código de Registro',
                    'Código: ${curso.codigoRegistro}',
                    backgroundColor: Colors.purple,
                    colorText: Colors.white,
                    duration: const Duration(seconds: 5),
                  );
                },
                child: const Text('Compartir Código'),
              ),
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Cerrar'),
            ),
          ],
        ),
      );
    } catch (e) {
      Get.back(); // Cerrar loading si hay error
      Get.snackbar(
        'Error',
        'No se pudieron cargar los estudiantes: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}