import 'package:get/get.dart';
import 'package:loggy/loggy.dart';

import '../../domain/entities/activity.dart';
import '../../domain/usecases/activity_usecase.dart';
import '../../../categories/domain/entities/equipo_entity.dart';
import '../../../categories/domain/entities/categoria_equipo_entity.dart';
import '../../../categories/domain/usecases/categoria_equipo_usecase.dart';
import '../../../categories/domain/usecases/equipo_actividad_usecase.dart';

class ActivityController extends GetxController {
  final RxList<Activity> _activities = <Activity>[].obs;
  final ActivityUseCase activityUseCase = Get.find();
  final CategoriaEquipoUseCase categoriaEquipoUseCase = Get.find();
  final EquipoActividadUseCase equipoActividadUseCase = Get.find();
  final RxBool isLoading = false.obs;
  final RxBool isLoadingTeams = false.obs;

  List<Activity> get activities => _activities;

  /// Guardamos el categoryId actual para filtrar actividades
  int? currentCategoryId;

  /// Variables para manejo de equipos
  final RxList<CategoriaEquipo> _categorias = <CategoriaEquipo>[].obs;
  final RxList<Equipo> _equiposDisponibles = <Equipo>[].obs;
  final RxList<int> _equiposSeleccionados = <int>[].obs;

  List<CategoriaEquipo> get categorias => _categorias;
  List<Equipo> get equiposDisponibles => _equiposDisponibles;
  List<int> get equiposSeleccionados => _equiposSeleccionados;

  /// Cargar actividades, opcionalmente filtradas por categoría
  Future<void> getActivities({int? categoryId}) async {
    logInfo("ActivityController: Getting activities");
    isLoading.value = true;

    currentCategoryId = categoryId ?? currentCategoryId;

    final result = await activityUseCase.getActivities(
      categoryId: currentCategoryId,
    );

    _activities.assignAll(result);
    isLoading.value = false;
  }

  Future<void> addActivity(
    int categoryId, // 🔹 obligatorio ahora
    String name,
    String desc,
    DateTime deliveryDate,
  ) async {
    logInfo("ActivityController: Add Activity");
    await activityUseCase.addActivity(categoryId, name, desc, deliveryDate);
    await getActivities(
      categoryId: categoryId,
    ); // 🔹 refresca solo esa categoría
  }

  Future<void> updateActivity(Activity activity) async {
    logInfo("ActivityController: Update Activity");
    await activityUseCase.updateActivity(activity);
    await getActivities(categoryId: activity.categoryId);
  }

  Future<void> deleteActivity(Activity activity) async {
    logInfo("ActivityController: Delete Activity");
    await activityUseCase.deleteActivity(activity);
    await getActivities(categoryId: activity.categoryId);
  }

  Future<void> deleteActivities({int? categoryId}) async {
    logInfo("ActivityController: Delete all activities");
    isLoading.value = true;
    await activityUseCase.deleteActivities();
    await getActivities(categoryId: categoryId);
    isLoading.value = false;
  }

  /// ===================== MÉTODOS PARA ASIGNACIÓN A EQUIPOS =====================

  /// Cargar categorías por curso
  Future<void> loadCategoriasPorCurso(int cursoId) async {
    logInfo("ActivityController: Loading categorias for curso: $cursoId");
    isLoadingTeams.value = true;
    try {
      final categorias = await categoriaEquipoUseCase.getCategoriasPorCurso(
        cursoId,
      );
      _categorias.assignAll(categorias);
    } catch (e) {
      logError("Error loading categorias: $e");
      Get.snackbar('Error', 'Error al cargar categorías: $e');
    } finally {
      isLoadingTeams.value = false;
    }
  }

  /// Cargar equipos por categoría
  Future<void> loadEquiposPorCategoria(int categoriaId) async {
    logInfo("ActivityController: Loading equipos for categoria: $categoriaId");
    isLoadingTeams.value = true;
    try {
      final equipos = await categoriaEquipoUseCase.getEquiposPorCategoria(
        categoriaId,
      );
      _equiposDisponibles.assignAll(equipos);
      _equiposSeleccionados.clear(); // Limpiar selección anterior
    } catch (e) {
      logError("Error loading equipos: $e");
      Get.snackbar('Error', 'Error al cargar equipos: $e');
    } finally {
      isLoadingTeams.value = false;
    }
  }

  /// Alternar selección de equipo
  void toggleEquipoSelection(int equipoId) {
    if (_equiposSeleccionados.contains(equipoId)) {
      _equiposSeleccionados.remove(equipoId);
    } else {
      _equiposSeleccionados.add(equipoId);
    }
  }

  /// Seleccionar todos los equipos disponibles
  void selectAllTeams() {
    _equiposSeleccionados.assignAll(
      _equiposDisponibles.map((e) => e.id!).toList(),
    );
  }

  /// Obtener IDs de equipos que ya tienen asignada una actividad específica
  Future<List<int>> getEquiposConActividad(String actividadId) async {
    try {
      final asignaciones = await equipoActividadUseCase
          .getAsignacionesByActividad(actividadId);
      return asignaciones.map((a) => a.equipoId).toList();
    } catch (e) {
      logError("Error getting teams with activity: $e");
      return [];
    }
  }

  /// Verificar si un equipo tiene asignada una actividad específica
  Future<bool> equipoTieneActividad(int equipoId, String actividadId) async {
    try {
      final asignacion = await equipoActividadUseCase.getAsignacion(
        equipoId,
        actividadId,
      );
      return asignacion != null;
    } catch (e) {
      logError("Error checking team activity assignment: $e");
      return false;
    }
  }

  /// Limpiar selección de equipos
  void clearEquiposSelection() {
    _equiposSeleccionados.clear();
  }

  /// Verificar si un equipo está seleccionado
  bool isEquipoSelected(int equipoId) {
    return _equiposSeleccionados.contains(equipoId);
  }

  /// Asignar actividad a equipos seleccionados
  Future<void> assignActivityToSelectedTeams(Activity activity) async {
    if (_equiposSeleccionados.isEmpty) {
      Get.snackbar('Error', 'Debe seleccionar al menos un equipo');
      return;
    }

    logInfo(
      "ActivityController: Assigning activity ${activity.id} to ${_equiposSeleccionados.length} teams",
    );

    try {
      // Usar la fecha de entrega de la actividad
      await equipoActividadUseCase.asignarActividadAEquipos(
        activity.id!,
        _equiposSeleccionados.toList(),
        activity.deliveryDate,
      );

      Get.snackbar(
        'Éxito',
        'Actividad "${activity.name}" asignada a ${_equiposSeleccionados.length} equipo(s)',
        snackPosition: SnackPosition.BOTTOM,
      );

      _equiposSeleccionados.clear();

      // 🔹 NUEVO: Recargar equipos disponibles para mostrar el estado actualizado
      await loadEquiposPorCategoria(activity.categoryId);

      // 🔹 Notificar que se debe recargar el estado de asignaciones
      update();
    } catch (e) {
      logError("Error assigning activity to teams: $e");
      Get.snackbar('Error', 'Error al asignar actividad: $e');
    }
  }

  /// Método para limpiar datos cuando se cambia de usuario/sesión
  void limpiarDatos() {
    _activities.clear();
    _categorias.clear();
    _equiposDisponibles.clear();
    _equiposSeleccionados.clear();
    currentCategoryId = null;
    isLoading.value = false;
    isLoadingTeams.value = false;
  }

  /// Método para reiniciar el controller después de cambio de sesión
  Future<void> reiniciar() async {
    limpiarDatos();
    // Recargar datos básicos si es necesario
  }

  @override
  void onClose() {
    limpiarDatos();
    super.onClose();
  }
}
