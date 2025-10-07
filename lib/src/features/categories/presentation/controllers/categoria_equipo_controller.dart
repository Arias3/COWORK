// categoria_equipo_controller.dart - FIXED VERSION para IDs String
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
  var isRemovingStudent = false.obs;

  // Cache de datos para optimizar rendimiento
  final Map<String, List<CategoriaEquipo>> _categoriasCache = {};
  final Map<int, List<Equipo>> _equiposCache = {};
  final Map<String, List<Usuario>> _estudiantesCache = {};
  DateTime? _lastCacheUpdate;

  // Datos del curso actual
  var cursoActual = Rxn<CursoDomain>();
  var categoriaSeleccionada = Rxn<CategoriaEquipo>();

  // Controladores de formulario
  final TextEditingController nombreCategoriaController =
      TextEditingController();
  final TextEditingController nombreEquipoController = TextEditingController();
  var tipoAsignacionSeleccionado = TipoAsignacion.manual.obs;
  var maxEstudiantesPorEquipo = 4.obs;
  var selectedTab = 0.obs;

  @override
  void onInit() {
    super.onInit();
  }

  // ============================================================================
  // MÉTODOS DE CACHÉ PARA OPTIMIZACIÓN
  // ============================================================================

  bool _isCacheValid() {
    if (_lastCacheUpdate == null) return false;
    final now = DateTime.now();
    final timeDifference = now.difference(_lastCacheUpdate!).inMinutes;
    return timeDifference < 5; // Cache válido por 5 minutos
  }

  void _updateCacheTimestamp() {
    _lastCacheUpdate = DateTime.now();
  }

  void _clearCache() {
    _categoriasCache.clear();
    _equiposCache.clear();
    _estudiantesCache.clear();
    _lastCacheUpdate = null;
  }

  // Método para refrescar datos manualmente
  Future<void> refreshData() async {
    _clearCache();
    if (cursoActual.value != null) {
      await loadCategoriasPorCurso(cursoActual.value!);
    }
  }

  // ============================================================================
  // GESTIÓN DE PERMISOS
  // ============================================================================

  bool esProfesorDelCurso(CursoDomain curso) {
    final currentUser = _authController.currentUser.value;
    if (currentUser == null) return false;
    return currentUser.id == curso.profesorId;
  }

  bool get esProfesorDelCursoActual {
    final curso = cursoActual.value;
    if (curso == null) return false;
    return esProfesorDelCurso(curso);
  }

  bool get esProfesor => esProfesorDelCursoActual;

  // ============================================================================
  // GESTIÓN DE CATEGORÍAS
  // ============================================================================

  Future<void> loadCategoriasPorCurso(CursoDomain curso) async {
    try {
      isLoading.value = true;
      cursoActual.value = curso;

      // Verificar caché primero
      final cacheKey = curso.id.toString();
      if (_isCacheValid() && _categoriasCache.containsKey(cacheKey)) {
        print('📦 Usando categorías desde caché para curso: ${curso.nombre}');
        categorias.assignAll(_categoriasCache[cacheKey]!);

        if (categorias.isNotEmpty) {
          // Si hay una categoría ya seleccionada, mantenerla
          if (categoriaSeleccionada.value != null) {
            final categoriaExistente = categorias.firstWhereOrNull(
              (cat) => cat.id == categoriaSeleccionada.value!.id,
            );
            if (categoriaExistente != null) {
              await selectCategoria(categoriaExistente);
              return;
            }
          }
          // Si no hay categoría seleccionada, seleccionar la primera
          await selectCategoria(categorias.first);
        }
        return;
      }

      // Cargar desde API si no hay caché válido
      print('🌐 Cargando categorías desde API para curso: ${curso.nombre}');
      final categoriasList = await _categoriaEquipoUseCase
          .getCategoriasPorCurso(curso.id);

      // Actualizar caché
      _categoriasCache[cacheKey] = categoriasList;
      _updateCacheTimestamp();

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

    _resetFormularioCategoria();
    Get.dialog(
      _buildDialogoCategoria(
        titulo: 'Crear Categoría',
        icono: Icons.category,
        color: Colors.blue,
        contenido: _buildCrearCategoriaForm(),
        onConfirmar: _confirmarCrearCategoria,
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

    _cargarDatosCategoria(categoria);
    Get.dialog(
      _buildDialogoCategoria(
        titulo: 'Editar Categoría',
        icono: Icons.edit,
        color: Colors.orange,
        contenido: _buildEditarCategoriaForm(categoria),
        onConfirmar: () => _confirmarEditarCategoria(categoria),
      ),
    );
  }

  void _resetFormularioCategoria() {
    nombreCategoriaController.clear();
    tipoAsignacionSeleccionado.value = TipoAsignacion.manual;
    maxEstudiantesPorEquipo.value = 4;
  }

  void _cargarDatosCategoria(CategoriaEquipo categoria) {
    nombreCategoriaController.text = categoria.nombre;
    tipoAsignacionSeleccionado.value = categoria.tipoAsignacion;
    maxEstudiantesPorEquipo.value = categoria.maxEstudiantesPorEquipo;
  }

  Widget _buildDialogoCategoria({
    required String titulo,
    required IconData icono,
    required Color color,
    required Widget contenido,
    required VoidCallback onConfirmar,
  }) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(icono, color: color, size: 28),
          const SizedBox(width: 8),
          Text(titulo),
        ],
      ),
      content: contenido,
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('Cancelar')),
        ElevatedButton(
          onPressed: onConfirmar,
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
          ),
          child: Text(titulo.contains('Crear') ? 'Crear' : 'Guardar'),
        ),
      ],
    );
  }

  Widget _buildCrearCategoriaForm() {
    return _buildFormularioCategoria(esCreacion: true);
  }

  Widget _buildEditarCategoriaForm(CategoriaEquipo categoria) {
    return _buildFormularioCategoria(esCreacion: false, categoria: categoria);
  }

  Widget _buildFormularioCategoria({
    required bool esCreacion,
    CategoriaEquipo? categoria,
  }) {
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
          if (esCreacion) _buildTipoAsignacionSelector(),
          if (!esCreacion && categoria != null)
            _buildInfoTipoAsignacion(categoria),
          const SizedBox(height: 16),
          _buildMaxEstudiantesSlider(
            !esCreacion && categoria?.equiposIds.isNotEmpty == true,
          ),
        ],
      ),
    );
  }

  Widget _buildTipoAsignacionSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                onChanged: (value) => tipoAsignacionSeleccionado.value = value!,
              ),
              RadioListTile<TipoAsignacion>(
                title: const Text('Aleatoria'),
                subtitle: const Text(
                  'El sistema asigna equipos automáticamente',
                ),
                value: TipoAsignacion.aleatoria,
                groupValue: tipoAsignacionSeleccionado.value,
                onChanged: (value) => tipoAsignacionSeleccionado.value = value!,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoTipoAsignacion(CategoriaEquipo categoria) {
    return Container(
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
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMaxEstudiantesSlider(bool mostrarAdvertencia) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Máximo estudiantes por equipo:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        if (mostrarAdvertencia) ...[
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
    );
  }

  Future<void> _confirmarCrearCategoria() async {
    if (!_validarFormularioCategoria()) return;
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
        cursoId: cursoActual.value!.id,
        tipoAsignacion: tipoAsignacionSeleccionado.value,
        maxEstudiantesPorEquipo: maxEstudiantesPorEquipo.value,
      );

      // Invalidar caché después de crear
      _clearCache();

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
    if (!_validarFormularioCategoria()) return;
    if (!esProfesorDelCursoActual) {
      _showErrorSnackbar(
        'Sin permisos',
        'Solo el profesor del curso puede editar categorías',
      );
      return;
    }

    try {
      // ✅ Validar que el ID no sea nulo antes de actualizar
      if (categoria.id == null) {
        throw Exception('ID de categoría no válido');
      }

      await _categoriaEquipoUseCase.updateCategoria(
        categoria.id!,
        nombre: nombreCategoriaController.text.trim(),
        maxEstudiantesPorEquipo: maxEstudiantesPorEquipo.value,
      );

      // Invalidar caché después de editar
      _clearCache();

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

  bool _validarFormularioCategoria() {
    if (nombreCategoriaController.text.trim().isEmpty) {
      _showErrorSnackbar('Error', 'El nombre de la categoría es obligatorio');
      return false;
    }
    return true;
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
      _buildDialogoConfirmacion(
        titulo: 'Confirmar eliminación',
        mensaje: '¿Estás seguro de eliminar esta categoría?',
        detalles: _buildDetallesCategoria(categoria),
        advertencia:
            'Se eliminarán todos los equipos asociados. Esta acción no se puede deshacer.',
        onConfirmar: () => _ejecutarEliminacionCategoria(categoria),
      ),
    );
  }

  Widget _buildDialogoConfirmacion({
    required String titulo,
    required String mensaje,
    required Widget detalles,
    required String advertencia,
    required VoidCallback onConfirmar,
  }) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          const Icon(Icons.warning, color: Colors.red),
          const SizedBox(width: 8),
          Text(titulo),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(mensaje),
          const SizedBox(height: 8),
          detalles,
          const SizedBox(height: 8),
          Text(
            advertencia,
            style: const TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('Cancelar')),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          onPressed: onConfirmar,
          child: const Text('Eliminar'),
        ),
      ],
    );
  }

  Widget _buildDetallesCategoria(CategoriaEquipo categoria) {
    return Container(
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
    );
  }

  Future<void> _ejecutarEliminacionCategoria(CategoriaEquipo categoria) async {
    try {
      // ✅ Validar que el ID no sea nulo antes de eliminar
      if (categoria.id == null) {
        throw Exception('ID de categoría no válido');
      }

      await _categoriaEquipoUseCase.deleteCategoria(categoria.id!);

      // Invalidar caché después de eliminar
      _clearCache();

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
  }

  // ============================================================================
  // GESTIÓN DE EQUIPOS
  // ============================================================================

  Future<void> selectCategoria(CategoriaEquipo categoria) async {
    categoriaSeleccionada.value = categoria;

    try {
      isLoadingEquipos.value = true;

      // ✅ Validar que el ID no sea nulo antes de obtener equipos
      if (categoria.id == null) {
        throw Exception('ID de categoría no válido');
      }

      // Verificar caché de equipos primero
      if (_isCacheValid() && _equiposCache.containsKey(categoria.id!)) {
        print(
          '📦 Usando equipos desde caché para categoría: ${categoria.nombre}',
        );
        equipos.assignAll(_equiposCache[categoria.id!]!);
        await _checkMiEquipo();
        _loadEquiposDisponibles();
        return;
      }

      // Cargar desde API si no hay caché válido
      print(
        '🌐 Cargando equipos desde API para categoría: ${categoria.nombre}',
      );
      final equiposList = await _categoriaEquipoUseCase.getEquiposPorCategoria(
        categoria.id!,
      );

      // Actualizar caché
      _equiposCache[categoria.id!] = equiposList;
      _updateCacheTimestamp();

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
    if (categoriaSeleccionada.value == null || !esProfesorDelCursoActual) {
      _showErrorSnackbar(
        'Sin permisos',
        'Solo el profesor del curso puede generar equipos',
      );
      return;
    }

    Get.dialog(_buildDialogoGenerarEquipos());
  }

  Widget _buildDialogoGenerarEquipos() {
    return AlertDialog(
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
            style: TextStyle(color: Colors.orange, fontWeight: FontWeight.w500),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('Cancelar')),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
          ),
          onPressed: _ejecutarGenerarEquipos,
          child: const Text('Generar'),
        ),
      ],
    );
  }

  Future<void> _ejecutarGenerarEquipos() async {
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
  }

  Future<void> crearEquipo(String nombreEquipo, [String? descripcion]) async {
    if (categoriaSeleccionada.value == null || nombreEquipo.trim().isEmpty) {
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

      // Invalidar caché de equipos para esta categoría
      _equiposCache.remove(categoriaSeleccionada.value!.id!);

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

  // CAMBIO: Método corregido para usar String equipoId
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

      // CAMBIO: Convertir ID a String
      final equipoIdString = equipo.id!.toString();
      await _categoriaEquipoUseCase.unirseAEquipo(userId, equipoIdString);

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

    Get.dialog(_buildDialogoSalirEquipo());
  }

  Widget _buildDialogoSalirEquipo() {
    return AlertDialog(
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
        TextButton(onPressed: () => Get.back(), child: const Text('Cancelar')),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          onPressed: _ejecutarSalirEquipo,
          child: const Text('Salir'),
        ),
      ],
    );
  }

  Future<void> _ejecutarSalirEquipo() async {
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
  }

  // ============================================================================
  // GESTIÓN DE ESTUDIANTES EN EQUIPOS - CORREGIDO PARA STRING IDs
  // ============================================================================

  Future<Equipo?> _getEquipoById(String equipoId) async {
    try {
      print('🔍 [CONTROLLER] Buscando equipo con ID: $equipoId');
      return await _categoriaEquipoUseCase.getEquipoById(equipoId);
    } catch (e) {
      print('❌ [CONTROLLER] Error obteniendo equipo: $e');
      return null;
    }
  }

  Future<void> agregarEstudianteAEquipo(
    String equipoId,
    String estudianteId,
  ) async {
    try {
      print(
        '🔍 [CONTROLLER] Agregando estudiante $estudianteId al equipo $equipoId',
      );

      final equipo = await _getEquipoById(equipoId);
      if (equipo == null) {
        _showErrorSnackbar('Error', 'Equipo no encontrado');
        return;
      }

      await _categoriaEquipoUseCase.agregarEstudianteAEquipoV2(
        equipo,
        estudianteId,
      );

      // Invalidar caché de equipos para esta categoría
      if (categoriaSeleccionada.value?.id != null) {
        _equiposCache.remove(categoriaSeleccionada.value!.id!);
      }

      _showSuccessSnackbar(
        'Estudiante agregado',
        'El estudiante ha sido agregado al equipo exitosamente',
      );

      if (categoriaSeleccionada.value != null) {
        await selectCategoria(categoriaSeleccionada.value!);
      }
    } catch (e) {
      print('❌ [CONTROLLER] Error agregando estudiante: $e');
      _showErrorSnackbar('Error al agregar estudiante', e.toString());
    }
  }

  Future<void> removerEstudianteDeEquipo(
    String equipoId,
    String estudianteId,
  ) async {
    try {
      print(
        '🔍 [CONTROLLER] Removiendo estudiante $estudianteId del equipo $equipoId',
      );
      isRemovingStudent.value = true;

      final equipo = await _getEquipoById(equipoId);
      if (equipo == null) {
        _showErrorSnackbar('Error', 'Equipo no encontrado');
        return;
      }

      await _categoriaEquipoUseCase.removerEstudianteDeEquipoV2(
        equipo,
        estudianteId,
      );

      // Invalidar caché de equipos para esta categoría
      if (categoriaSeleccionada.value?.id != null) {
        _equiposCache.remove(categoriaSeleccionada.value!.id!);
      }

      _showSuccessSnackbar(
        'Estudiante removido',
        'El estudiante ha sido removido del equipo exitosamente',
      );

      if (categoriaSeleccionada.value != null) {
        await selectCategoria(categoriaSeleccionada.value!);
      }

      await Future.delayed(const Duration(milliseconds: 300));
    } catch (e) {
      print('❌ [CONTROLLER] Error removiendo estudiante: $e');
      _showErrorSnackbar('Error al remover estudiante', e.toString());
    } finally {
      isRemovingStudent.value = false;
    }
  }

  Future<List<Usuario>> getEstudiantesDelCurso() async {
    try {
      final curso = cursoActual.value;
      if (curso == null) return [];

      final cacheKey = curso.id.toString();

      // Verificar caché de estudiantes primero
      if (_isCacheValid() && _estudiantesCache.containsKey(cacheKey)) {
        print('📦 Usando estudiantes desde caché para curso: ${curso.nombre}');
        return _estudiantesCache[cacheKey]!;
      }

      // Cargar desde API si no hay caché válido
      print('🌐 Cargando estudiantes desde API para curso: ${curso.nombre}');
      final estudiantes = await _categoriaEquipoUseCase.getEstudiantesDelCurso(
        curso.id,
      );

      // Actualizar caché
      _estudiantesCache[cacheKey] = estudiantes;
      _updateCacheTimestamp();

      return estudiantes;
    } catch (e) {
      print('❌ [CONTROLLER] Error obteniendo estudiantes del curso: $e');
      return [];
    }
  }

  Future<List<Usuario>> getEstudiantesDisponiblesParaEquipo(
    String equipoId,
  ) async {
    try {
      print(
        '🔍 [CONTROLLER] Obteniendo estudiantes disponibles para equipo: $equipoId',
      );

      if (cursoActual.value?.id == null ||
          categoriaSeleccionada.value?.id == null) {
        print('❌ [CONTROLLER] Curso o categoría no disponible');
        return [];
      }

      final equipo = await _getEquipoById(equipoId);
      if (equipo == null) {
        print('❌ [CONTROLLER] Equipo no encontrado con ID: $equipoId');
        return [];
      }

      print('✅ [CONTROLLER] Equipo encontrado: ${equipo.nombre}');

      return await _categoriaEquipoUseCase.getEstudiantesDisponiblesParaEquipo(
        equipo,
        categoriaSeleccionada.value!.id!,
      );
    } catch (e) {
      print('❌ [CONTROLLER] Error obteniendo estudiantes disponibles: $e');
      return [];
    }
  }

  // ============================================================================
  // UTILIDADES
  // ============================================================================

  void changeTab(int index) => selectedTab.value = index;
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
