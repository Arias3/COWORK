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

  @override
  void onInit() {
    super.onInit();
    // ⚠️ No cargamos nada aún hasta que tengamos un categoryId
  }

  /// Cargar actividades, opcionalmente filtradas por categoría
  Future<void> getActivities({int? categoryId}) async {
    logInfo("ActivityController: Getting activities");
    isLoading.value = true;

    currentCategoryId = categoryId ?? currentCategoryId;

    try {
      List<Activity> result;
      if (currentCategoryId != null) {
        result = await activityUseCase.getActivitiesByCategoria(
          currentCategoryId!,
        );
      } else {
        result = await activityUseCase.getAllActivities();
      }

      _activities.assignAll(result);
      logInfo("ActivityController: Loaded ${result.length} activities");
    } catch (e) {
      logError("ActivityController: Error loading activities: $e");
      Get.snackbar('Error', 'No se pudieron cargar las actividades');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addActivity(
    int categoryId, // 🔹 obligatorio ahora
    String name,
    String desc,
    DateTime deliveryDate, {
    String? archivoAdjunto,
  }) async {
    logInfo("ActivityController: Add Activity");
    try {
      await activityUseCase.createActivity(
        categoriaId: categoryId,
        nombre: name,
        descripcion: desc,
        fechaEntrega: deliveryDate,
        archivoAdjunto: archivoAdjunto,
      );

      await getActivities(
        categoryId: categoryId,
      ); // 🔹 refresca solo esa categoría
      Get.snackbar('Éxito', 'Actividad creada exitosamente');
    } catch (e) {
      logError("ActivityController: Error adding activity: $e");
      Get.snackbar('Error', e.toString());
    }
  }

  Future<void> updateActivity(
    Activity activity, {
    String? nombre,
    String? descripcion,
    DateTime? fechaEntrega,
    String? archivoAdjunto,
  }) async {
    logInfo("ActivityController: Update Activity");
    try {
      if (activity.id == null) {
        throw Exception('ID de actividad no válido');
      }

      await activityUseCase.updateActivity(
        id: activity.id!,
        nombre: nombre,
        descripcion: descripcion,
        fechaEntrega: fechaEntrega,
        archivoAdjunto: archivoAdjunto,
      );

      await getActivities(categoryId: activity.categoriaId);
      Get.snackbar('Éxito', 'Actividad actualizada exitosamente');
    } catch (e) {
      logError("ActivityController: Error updating activity: $e");
      Get.snackbar('Error', e.toString());
    }
  }

  Future<void> deleteActivity(Activity activity) async {
    logInfo("ActivityController: Delete Activity");
    try {
      if (activity.id == null) {
        throw Exception('ID de actividad no válido');
      }

      await activityUseCase.deleteActivity(activity.id!);
      await getActivities(categoryId: activity.categoriaId);
      Get.snackbar('Éxito', 'Actividad eliminada exitosamente');
    } catch (e) {
      logError("ActivityController: Error deleting activity: $e");
      Get.snackbar('Error', e.toString());
    }
  }

  Future<void> deleteActivitiesByCategory({required int categoryId}) async {
    logInfo("ActivityController: Delete activities by category");
    isLoading.value = true;
    try {
      await activityUseCase.deleteActivitiesByCategoria(categoryId);
      await getActivities(categoryId: categoryId);
      Get.snackbar('Éxito', 'Actividades eliminadas exitosamente');
    } catch (e) {
      logError("ActivityController: Error deleting activities by category: $e");
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
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
      // Mensaje optimizado - solo errores críticos
      print('❌ Error cargando categorías: $e');
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
      print('❌ Error cargando equipos: $e');
    } finally {
      isLoadingTeams.value = false;
    }
  }

  /// Alternar selección de equipo
  void toggleEquipoSelection(int equipoId) {
    print('🔄 [CONTROLLER] Toggle equipo $equipoId');
    print('   Antes: ${_equiposSeleccionados.toList()}');

    if (_equiposSeleccionados.contains(equipoId)) {
      _equiposSeleccionados.remove(equipoId);
      print('   ➖ Removido');
    } else {
      _equiposSeleccionados.add(equipoId);
      print('   ➕ Agregado');
    }

    print('   Después: ${_equiposSeleccionados.toList()}');

    // Forzar actualización de la UI
    _equiposSeleccionados.refresh();
    update(); // GetxController.update() para forzar rebuild
  }

  /// Seleccionar todos los equipos disponibles
  void selectAllTeams() {
    _equiposSeleccionados.assignAll(
      _equiposDisponibles.map((e) => e.id!).toList(),
    );

    // Forzar actualización de la UI
    update();
    refresh();

    print(
      '🔄 [CONTROLLER] Seleccionados todos los equipos: ${_equiposSeleccionados.toList()}',
    );
    print('🔄 [CONTROLLER] UI actualizada con update() y refresh()');
  }

  /// Seleccionar solo equipos que NO tienen la actividad asignada
  void selectTeamsWithoutActivity(List<int> equiposConActividad) {
    final equiposDisponiblesSinActividad = _equiposDisponibles
        .where((equipo) => !equiposConActividad.contains(equipo.id))
        .map((equipo) => equipo.id!)
        .toList();

    _equiposSeleccionados.assignAll(equiposDisponiblesSinActividad);

    // Forzar actualización de la UI
    update();
    refresh();

    print('🔄 [CONTROLLER] Seleccionados equipos sin actividad:');
    print('   Equipos con actividad: $equiposConActividad');
    print(
      '   Equipos disponibles sin actividad: $equiposDisponiblesSinActividad',
    );
    print('   Lista final seleccionada: ${_equiposSeleccionados.toList()}');
    print('🔄 [CONTROLLER] UI actualizada con update() y refresh()');
  }

  /// Obtener IDs de equipos que ya tienen asignada una actividad específica
  Future<List<int>> getEquiposConActividad(String actividadId) async {
    try {
      print('🔍 [CONTROLLER] Buscando equipos con actividad: $actividadId');

      final asignaciones = await equipoActividadUseCase
          .getAsignacionesByActividad(actividadId);

      final equiposIds = asignaciones.map((a) => a.equipoId).toList();

      print('   Asignaciones encontradas: ${asignaciones.length}');
      print('   Equipos con actividad: $equiposIds');

      return equiposIds;
    } catch (e) {
      logError("Error getting teams with activity: $e");
      print('❌ [CONTROLLER] Error obteniendo equipos con actividad: $e');
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
    final isSelected = _equiposSeleccionados.contains(equipoId);
    // Solo imprimir para el primer equipo para evitar spam
    if (equipoId == _equiposDisponibles.first.id) {
      print('🔍 [CONTROLLER] isEquipoSelected($equipoId): $isSelected');
      print('   Lista actual: ${_equiposSeleccionados.toList()}');
    }
    return isSelected;
  }

  /// Asignar actividad a equipos seleccionados
  Future<void> assignActivityToSelectedTeams(Activity activity) async {
    if (_equiposSeleccionados.isEmpty) {
      Get.snackbar(
        'Selección Requerida',
        'Debe seleccionar al menos un equipo',
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
        duration: const Duration(seconds: 2),
      );
      return;
    }

    logInfo(
      "ActivityController: Assigning activity ${activity.id} to ${_equiposSeleccionados.length} teams",
    );

    try {
      // Usar la fecha de entrega de la actividad
      await equipoActividadUseCase.asignarActividadAEquipos(
        activity.robleId ?? activity.id.toString(),
        _equiposSeleccionados.toList(),
        activity.fechaEntrega,
      );

      // Mensaje único optimizado
      Get.snackbar(
        '¡Actividad Asignada!',
        'Actividad "${activity.nombre}" asignada a ${_equiposSeleccionados.length} equipo(s)',
        backgroundColor: Get.theme.colorScheme.primary,
        colorText: Get.theme.colorScheme.onPrimary,
        duration: const Duration(seconds: 2),
      );

      _equiposSeleccionados.clear();

      // Recargar equipos disponibles para mostrar el estado actualizado
      await loadEquiposPorCategoria(activity.categoriaId);

      // Notificar que se debe recargar el estado de asignaciones
      update();
    } catch (e) {
      logError("Error assigning activity to teams: $e");
      Get.snackbar(
        'Error de Asignación',
        'No se pudo asignar la actividad a los equipos',
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
        duration: const Duration(seconds: 3),
      );
    }
  }

  /// Obtener actividades asignadas a un equipo específico
  Future<List<Activity>> getActividadesAsignadasAEquipo(int equipoId) async {
    try {
      logInfo(
        "ActivityController: Getting activities assigned to team: $equipoId",
      );

      // Obtener las asignaciones de este equipo
      final asignaciones = await equipoActividadUseCase.getAsignacionesByEquipo(
        equipoId,
      );

      if (asignaciones.isEmpty) {
        logInfo("ActivityController: No activities assigned to team $equipoId");
        return [];
      }

      // Obtener todas las actividades para poder filtrar
      await getActivities(); // Cargar todas las actividades

      // Filtrar las actividades que están asignadas a este equipo
      final actividadesAsignadas = <Activity>[];
      for (final asignacion in asignaciones) {
        final actividad = _activities.firstWhereOrNull(
          (a) =>
              a.id.toString() == asignacion.actividadId ||
              a.robleId == asignacion.actividadId,
        );
        if (actividad != null) {
          actividadesAsignadas.add(actividad);
        }
      }

      logInfo(
        "ActivityController: Found ${actividadesAsignadas.length} activities assigned to team $equipoId",
      );
      return actividadesAsignadas;
    } catch (e) {
      logError(
        "ActivityController: Error getting activities for team $equipoId: $e",
      );
      return [];
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
