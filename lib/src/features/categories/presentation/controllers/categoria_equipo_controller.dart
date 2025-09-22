// categoria_equipo_controller.dart - CLEAN VERSION
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domain/usecases/categoria_equipo_usecase.dart';
import '../../domain/entities/categoria_equipo_entity.dart';
import '../../domain/entities/equipo_entity.dart';
import '../../../home/domain/entities/curso_entity.dart';
import '../../../auth/presentation/controllers/roble_auth_login_controller.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../domain/entities/tipo_asignacion.dart';

class CategoriaEquipoController extends GetxController {
  final CategoriaEquipoUseCase _categoriaEquipoUseCase;
  final RobleAuthLoginController _authController;

  CategoriaEquipoController(this._categoriaEquipoUseCase, this._authController);

  // Estados observables
  var categorias = <CategoriaEquipo>[].obs;
  var equipos = <Equipo>[].obs;
  var equiposDisponibles = <Equipo>[].obs;
  var miEquipo = Rxn<Equipo>();
  var isLoading = false.obs;
  var isLoadingEquipos = false.obs;
  var isRemovingStudent =
      false.obs; // Variable para controlar operaciones de remoción

  // Datos del curso actual
  var cursoActual = Rxn<CursoDomain>();
  var categoriaSeleccionada = Rxn<CategoriaEquipo>();
  var estudiantesInscritos = <Usuario>[].obs;

  // Controladores de formulario
  final TextEditingController nombreCategoriaController =
      TextEditingController();
  final TextEditingController nombreEquipoController = TextEditingController();
  var tipoAsignacionSeleccionado = TipoAsignacion.manual.obs;
  var maxEstudiantesPorEquipo = 4.obs;

  // Estados de UI
  var selectedTab = 0.obs;

  @override
  void onInit() {
    super.onInit();
  }

  // ============================================================================
  // GESTIÓN DE PERMISOS
  // ============================================================================

  /// Verifica si el usuario actual es el profesor/creador de un curso específico
  bool esProfesorDelCurso(CursoDomain curso) {
    final currentUser = _authController.currentUser.value;
    if (currentUser == null) return false;

    // Un usuario es profesor de un curso si es quien lo creó (profesorId)
    return currentUser.id == curso.profesorId;
  }

  /// Verifica si el usuario actual es el profesor del curso actualmente cargado
  bool get esProfesorDelCursoActual {
    final curso = cursoActual.value;
    if (curso == null) return false;
    return esProfesorDelCurso(curso);
  }

  /// Alias para mantener compatibilidad con código existente
  bool get esProfesor {
    return esProfesorDelCursoActual;
  }

  // ============================================================================
  // GESTIÓN DE CATEGORÍAS
  // ============================================================================

  Future<void> loadCategoriasPorCurso(CursoDomain curso) async {
    try {
      isLoading.value = true;
      cursoActual.value = curso;

      final categoriasList = await _categoriaEquipoUseCase
          .getCategoriasPorCurso(curso.id!);
      categorias.assignAll(categoriasList);

      if (categoriasList.isNotEmpty) {
        await selectCategoria(categoriasList.first);
      }
    } catch (e) {
      _showErrorSnackbar('Error al cargar categorías', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void mostrarDialogoCrearCategoria() {
    if (!esProfesorDelCursoActual) {
      _showErrorSnackbar(
        'Sin permisos',
        'Solo el profesor del curso puede crear categorías',
      );
      return;
    }

    nombreCategoriaController.clear();
    tipoAsignacionSeleccionado.value = TipoAsignacion.manual;
    maxEstudiantesPorEquipo.value = 4;

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.category, color: Colors.blue, size: 28),
            const SizedBox(width: 8),
            const Text('Crear Categoría'),
          ],
        ),
        content: _buildCrearCategoriaForm(),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: _confirmarCrearCategoria,
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

  void mostrarDialogoEditarCategoria(CategoriaEquipo categoria) {
    if (!esProfesorDelCursoActual) {
      _showErrorSnackbar(
        'Sin permisos',
        'Solo el profesor del curso puede editar categorías',
      );
      return;
    }

    nombreCategoriaController.text = categoria.nombre;
    tipoAsignacionSeleccionado.value = categoria.tipoAsignacion;
    maxEstudiantesPorEquipo.value = categoria.maxEstudiantesPorEquipo;

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.edit, color: Colors.orange, size: 28),
            const SizedBox(width: 8),
            const Text('Editar Categoría'),
          ],
        ),
        content: _buildEditarCategoriaForm(categoria),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => _confirmarEditarCategoria(categoria),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  Widget _buildCrearCategoriaForm() {
    return SizedBox(
      width: double.maxFinite,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: nombreCategoriaController,
            decoration: const InputDecoration(
              labelText: 'Nombre de la categoría',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.label),
              hintText: 'Ej: Proyecto Final, Laboratorio 1',
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Tipo de asignación:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Obx(
            () => Column(
              children: [
                RadioListTile<TipoAsignacion>(
                  title: const Text('Manual'),
                  subtitle: const Text('Los estudiantes eligen su equipo'),
                  value: TipoAsignacion.manual,
                  groupValue: tipoAsignacionSeleccionado.value,
                  onChanged: (value) =>
                      tipoAsignacionSeleccionado.value = value!,
                ),
                RadioListTile<TipoAsignacion>(
                  title: const Text('Aleatoria'),
                  subtitle: const Text(
                    'El sistema asigna equipos automáticamente',
                  ),
                  value: TipoAsignacion.aleatoria,
                  groupValue: tipoAsignacionSeleccionado.value,
                  onChanged: (value) =>
                      tipoAsignacionSeleccionado.value = value!,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Máximo estudiantes por equipo:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Obx(
            () => Row(
              children: [
                Expanded(
                  child: Slider(
                    value: maxEstudiantesPorEquipo.value.toDouble(),
                    min: 2,
                    max: 8,
                    divisions: 6,
                    label: maxEstudiantesPorEquipo.value.toString(),
                    onChanged: (value) =>
                        maxEstudiantesPorEquipo.value = value.round(),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${maxEstudiantesPorEquipo.value}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditarCategoriaForm(CategoriaEquipo categoria) {
    return SizedBox(
      width: double.maxFinite,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: nombreCategoriaController,
            decoration: const InputDecoration(
              labelText: 'Nombre de la categoría',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.label),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.amber.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info, color: Colors.amber, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Tipo actual: ${categoria.tipoAsignacion.name.toUpperCase()}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Máximo estudiantes por equipo:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          if (categoria.equiposIds.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              'Nota: Reducir el límite podría afectar equipos existentes',
              style: TextStyle(
                fontSize: 12,
                color: Colors.orange[700],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          const SizedBox(height: 8),
          Obx(
            () => Row(
              children: [
                Expanded(
                  child: Slider(
                    value: maxEstudiantesPorEquipo.value.toDouble(),
                    min: 2,
                    max: 8,
                    divisions: 6,
                    label: maxEstudiantesPorEquipo.value.toString(),
                    onChanged: (value) =>
                        maxEstudiantesPorEquipo.value = value.round(),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${maxEstudiantesPorEquipo.value}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmarCrearCategoria() async {
    if (nombreCategoriaController.text.trim().isEmpty) {
      _showErrorSnackbar('Error', 'El nombre de la categoría es obligatorio');
      return;
    }

    if (!esProfesorDelCursoActual) {
      _showErrorSnackbar(
        'Sin permisos',
        'Solo el profesor del curso puede crear categorías',
      );
      return;
    }

    try {
      await _categoriaEquipoUseCase.createCategoria(
        nombre: nombreCategoriaController.text.trim(),
        cursoId: cursoActual.value!.id!,
        tipoAsignacion: tipoAsignacionSeleccionado.value,
        maxEstudiantesPorEquipo: maxEstudiantesPorEquipo.value,
      );

      Get.back();
      await loadCategoriasPorCurso(cursoActual.value!);

      _showSuccessSnackbar(
        'Categoría creada',
        'La categoría "${nombreCategoriaController.text}" ha sido creada',
      );
    } catch (e) {
      _showErrorSnackbar('Error al crear categoría', e.toString());
    }
  }

  Future<void> _confirmarEditarCategoria(CategoriaEquipo categoria) async {
    if (nombreCategoriaController.text.trim().isEmpty) {
      _showErrorSnackbar('Error', 'El nombre de la categoría es obligatorio');
      return;
    }

    if (!esProfesorDelCursoActual) {
      _showErrorSnackbar(
        'Sin permisos',
        'Solo el profesor del curso puede editar categorías',
      );
      return;
    }

    try {
      await _categoriaEquipoUseCase.updateCategoria(
        categoria.id!,
        nombre: nombreCategoriaController.text.trim(),
        maxEstudiantesPorEquipo: maxEstudiantesPorEquipo.value,
      );

      Get.back();
      await loadCategoriasPorCurso(cursoActual.value!);

      _showSuccessSnackbar(
        'Categoría actualizada',
        'Los cambios han sido guardados exitosamente',
      );
    } catch (e) {
      _showErrorSnackbar('Error al actualizar categoría', e.toString());
    }
  }

  Future<void> eliminarCategoria(CategoriaEquipo categoria) async {
    if (!esProfesorDelCursoActual) {
      _showErrorSnackbar(
        'Sin permisos',
        'Solo el profesor del curso puede eliminar categorías',
      );
      return;
    }

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 8),
            Text('Confirmar eliminación'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('¿Estás seguro de eliminar esta categoría?'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    categoria.nombre,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Tipo: ${categoria.tipoAsignacion.name}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  Text(
                    'Equipos: ${categoria.equiposIds.length}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Se eliminarán todos los equipos asociados. Esta acción no se puede deshacer.',
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
                await _categoriaEquipoUseCase.deleteCategoria(categoria.id!);
                Get.back();
                await loadCategoriasPorCurso(cursoActual.value!);
                _showSuccessSnackbar(
                  'Eliminada',
                  'Categoría "${categoria.nombre}" eliminada',
                );
              } catch (e) {
                Get.back();
                _showErrorSnackbar('Error al eliminar', e.toString());
              }
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // GESTIÓN DE EQUIPOS
  // ============================================================================

  Future<void> selectCategoria(CategoriaEquipo categoria) async {
    // Actualizar inmediatamente la categoría seleccionada para reactividad visual
    categoriaSeleccionada.value = categoria;

    try {
      isLoadingEquipos.value = true;

      final equiposList = await _categoriaEquipoUseCase.getEquiposPorCategoria(
        categoria.id!,
      );
      equipos.assignAll(equiposList);

      await _checkMiEquipo();
      _loadEquiposDisponibles();
    } catch (e) {
      _showErrorSnackbar('Error al cargar equipos', e.toString());
    } finally {
      isLoadingEquipos.value = false;
    }
  }

  Future<void> _checkMiEquipo() async {
    if (categoriaSeleccionada.value == null) return;

    try {
      final userId = _authController.currentUser.value?.id;
      if (userId == null) return;

      final equipo = await _categoriaEquipoUseCase.getEquipoPorEstudiante(
        userId,
        categoriaSeleccionada.value!.id!,
      );

      miEquipo.value = equipo;
    } catch (e) {
      print('Error checking mi equipo: $e');
    }
  }

  void _loadEquiposDisponibles() {
    if (categoriaSeleccionada.value == null) return;

    equiposDisponibles.assignAll(
      equipos
          .where(
            (equipo) =>
                equipo.estudiantesIds.length <
                categoriaSeleccionada.value!.maxEstudiantesPorEquipo,
          )
          .toList(),
    );
  }

  Future<void> generarEquiposAleatorios() async {
    if (categoriaSeleccionada.value == null) return;

    if (!esProfesorDelCursoActual) {
      _showErrorSnackbar(
        'Sin permisos',
        'Solo el profesor del curso puede generar equipos',
      );
      return;
    }

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.shuffle, color: Colors.orange),
            SizedBox(width: 8),
            Text('Generar Equipos'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('¿Generar equipos aleatoriamente?'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Categoría: ${categoriaSeleccionada.value!.nombre}'),
                  Text(
                    'Max por equipo: ${categoriaSeleccionada.value!.maxEstudiantesPorEquipo}',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Se eliminarán los equipos existentes.',
              style: TextStyle(
                color: Colors.orange,
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
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              try {
                Get.back();
                isLoadingEquipos.value = true;

                await _categoriaEquipoUseCase.generarEquiposAleatorios(
                  categoriaSeleccionada.value!.id!,
                );

                await selectCategoria(categoriaSeleccionada.value!);
                _showSuccessSnackbar(
                  'Equipos generados',
                  'Los equipos han sido creados aleatoriamente',
                );
              } catch (e) {
                _showErrorSnackbar('Error al generar equipos', e.toString());
              } finally {
                isLoadingEquipos.value = false;
              }
            },
            child: const Text('Generar'),
          ),
        ],
      ),
    );
  }

  Future<void> crearEquipo(String nombreEquipo, [String? descripcion]) async {
    if (categoriaSeleccionada.value == null) return;
    if (nombreEquipo.trim().isEmpty) {
      _showErrorSnackbar('Error', 'El nombre del equipo es obligatorio');
      return;
    }

    try {
      final userId = _authController.currentUser.value?.id;
      if (userId == null) throw Exception('Usuario no autenticado');

      await _categoriaEquipoUseCase.crearEquipo(
        nombre: nombreEquipo.trim(),
        categoriaId: categoriaSeleccionada.value!.id!,
      );

      await selectCategoria(categoriaSeleccionada.value!);
      _showSuccessSnackbar(
        'Equipo creado',
        'El equipo "$nombreEquipo" ha sido creado exitosamente',
      );
    } catch (e) {
      _showErrorSnackbar('Error al crear equipo', e.toString());
    }
  }

  void mostrarDialogoCrearEquipo() {
    nombreEquipoController.clear();
    final descripcionController = TextEditingController();

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.group_add, color: Colors.green, size: 28),
            const SizedBox(width: 8),
            const Text('Crear Equipo'),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nombreEquipoController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del equipo',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.groups),
                  hintText: 'Ej: Los Innovadores, Team Alpha',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descripcionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción (opcional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                  hintText: 'Describe brevemente el equipo...',
                ),
                maxLines: 2,
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
              Get.back();
              crearEquipo(
                nombreEquipoController.text,
                descripcionController.text,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Crear'),
          ),
        ],
      ),
    );
  }

  Future<void> unirseAEquipo(Equipo equipo) async {
    try {
      final userId = _authController.currentUser.value?.id;
      if (userId == null) throw Exception('Usuario no autenticado');

      if (miEquipo.value != null) {
        _showErrorSnackbar(
          'Ya tienes un equipo',
          'Debes salir de tu equipo actual antes de unirte a otro',
        );
        return;
      }

      await _categoriaEquipoUseCase.unirseAEquipo(userId, equipo.id!);
      await selectCategoria(categoriaSeleccionada.value!);

      _showSuccessSnackbar(
        'Te uniste al equipo',
        'Ahora eres parte de "${equipo.nombre}"',
      );
    } catch (e) {
      _showErrorSnackbar('Error al unirse al equipo', e.toString());
    }
  }

  Future<void> salirDeEquipo() async {
    if (miEquipo.value == null || categoriaSeleccionada.value == null) return;

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.exit_to_app, color: Colors.red),
            SizedBox(width: 8),
            Text('Salir del equipo'),
          ],
        ),
        content: Text('¿Salir del equipo "${miEquipo.value!.nombre}"?'),
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
                final userId = _authController.currentUser.value?.id;
                if (userId == null) throw Exception('Usuario no autenticado');

                await _categoriaEquipoUseCase.salirDeEquipo(
                  userId,
                  categoriaSeleccionada.value!.id!,
                );
                Get.back();
                await selectCategoria(categoriaSeleccionada.value!);

                _showSuccessSnackbar(
                  'Saliste del equipo',
                  'Ya no formas parte del equipo',
                );
              } catch (e) {
                Get.back();
                _showErrorSnackbar('Error al salir del equipo', e.toString());
              }
            },
            child: const Text('Salir'),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // GESTIÓN DE ESTUDIANTES EN EQUIPOS - SOLO LLAMADAS AL USE CASE
  // ============================================================================

  Future<void> agregarEstudianteAEquipo(
    String equipoId,
    String estudianteId,
  ) async {
    try {
      await _categoriaEquipoUseCase.agregarEstudianteAEquipo(
        equipoId,
        estudianteId,
      );

      _showSuccessSnackbar(
        'Estudiante agregado',
        'El estudiante ha sido agregado al equipo exitosamente',
      );

      if (categoriaSeleccionada.value != null) {
        await selectCategoria(categoriaSeleccionada.value!);
      }
    } catch (e) {
      _showErrorSnackbar('Error al agregar estudiante', e.toString());
    }
  }

  Future<void> removerEstudianteDeEquipo(
    String equipoId,
    String estudianteId,
  ) async {
    try {
      isRemovingStudent.value = true;

      await _categoriaEquipoUseCase.removerEstudianteDeEquipo(
        equipoId,
        estudianteId,
      );

      _showSuccessSnackbar(
        'Estudiante removido',
        'El estudiante ha sido removido del equipo exitosamente',
      );

      if (categoriaSeleccionada.value != null) {
        await selectCategoria(categoriaSeleccionada.value!);
      }

      // Pequeño delay adicional para asegurar actualización completa del estado
      await Future.delayed(const Duration(milliseconds: 300));
    } catch (e) {
      _showErrorSnackbar('Error al remover estudiante', e.toString());
    } finally {
      isRemovingStudent.value = false;
    }
  }

  // SOLO llamada al use case, SIN duplicar lógica
  Future<List<Usuario>> getEstudiantesDelCurso() async {
    try {
      if (cursoActual.value?.id == null) return [];

      return await _categoriaEquipoUseCase.getEstudiantesDelCurso(
        cursoActual.value!.id!,
      );
    } catch (e) {
      print('Error obteniendo estudiantes del curso: $e');
      return [];
    }
  }

  // SOLO llamada al use case, SIN duplicar lógica
  Future<List<Usuario>> getEstudiantesDisponiblesParaEquipo(
    String equipoId,
  ) async {
    try {
      if (cursoActual.value?.id == null ||
          categoriaSeleccionada.value?.id == null)
        return [];

      return await _categoriaEquipoUseCase.getEstudiantesDisponiblesParaEquipo(
        equipoId,
        categoriaSeleccionada.value!.id!,
      );
    } catch (e) {
      print('Error obteniendo estudiantes disponibles: $e');
      return [];
    }
  }

  // ============================================================================
  // UTILIDADES
  // ============================================================================

  void changeTab(int index) {
    selectedTab.value = index;
  }

  RobleAuthLoginController get authController => _authController;

  void _showSuccessSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      icon: const Icon(Icons.check_circle, color: Colors.white),
      duration: const Duration(seconds: 3),
    );
  }

  void _showErrorSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      icon: const Icon(Icons.error, color: Colors.white),
      duration: const Duration(seconds: 3),
    );
  }

  @override
  void onClose() {
    nombreCategoriaController.dispose();
    nombreEquipoController.dispose();
    super.onClose();
  }
}
