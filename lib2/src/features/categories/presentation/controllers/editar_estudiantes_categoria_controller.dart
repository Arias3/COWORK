// editar_estudiantes_categoria_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domain/usecases/categoria_equipo_usecase.dart';
import '../../domain/entities/categoria_equipo_entity.dart';
import '../../domain/entities/equipo_entity.dart';
import '../../../auth/domain/entities/user_entity.dart';

class EditarEstudiantesCategoriaController extends GetxController {
  final CategoriaEquipoUseCase _categoriaEquipoUseCase;

  EditarEstudiantesCategoriaController(this._categoriaEquipoUseCase);

  // Estados observables
  var categoria = Rxn<CategoriaEquipo>();
  var equipos = <Equipo>[].obs;
  var todosLosEstudiantes = <Usuario>[].obs;
  var estudiantesSinEquipo = <Usuario>[].obs;
  var estudiantesPorEquipo = <String, List<Usuario>>{}.obs;

  var isLoading = false.obs;
  var isGuardando = false.obs;
  var hayChangiosPendientes = false.obs;

  // Contador para forzar actualización de UI
  var uiUpdateCounter = 0.obs;

  // Cambios pendientes para rastreo
  final Map<String, List<String>> _cambiosPendientes = {};
  final List<String> _equiposAEliminar = [];

  int get totalEstudiantes => todosLosEstudiantes.length;

  // Método para forzar actualización de UI
  void _forceUIUpdate() {
    uiUpdateCounter.value++;
    estudiantesPorEquipo.refresh();
    estudiantesSinEquipo.refresh();
  }

  @override
  void onInit() {
    super.onInit();
  }

  Future<void> inicializar(CategoriaEquipo categoriaParam) async {
    try {
      isLoading.value = true;
      categoria.value = categoriaParam;
      await _cargarDatos();
    } catch (e) {
      _showErrorSnackbar('Error al cargar datos', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _cargarDatos() async {
    if (categoria.value == null) return;

    // Cargar equipos de la categoría
    final equiposData = await _categoriaEquipoUseCase.getEquiposPorCategoria(
      categoria.value!.id!,
    );
    equipos.assignAll(equiposData);

    // Cargar todos los estudiantes del curso
    final estudiantesData = await _categoriaEquipoUseCase
        .getEstudiantesDelCurso(categoria.value!.cursoId);
    todosLosEstudiantes.assignAll(estudiantesData);

    // Organizar estudiantes por equipo
    await _organizarEstudiantesPorEquipo();
  }

  Future<void> _organizarEstudiantesPorEquipo() async {
    estudiantesPorEquipo.clear();
    estudiantesSinEquipo.clear();

    // Inicializar listas vacías para cada equipo
    for (var equipo in equipos) {
      estudiantesPorEquipo[equipo.id!.toString()] = [];
    }

    // Lista temporal para estudiantes sin equipo
    List<Usuario> sinEquipo = List.from(todosLosEstudiantes);

    // Asignar estudiantes a sus equipos
    for (var equipo in equipos) {
      for (var estudianteId in equipo.estudiantesIds) {
        final estudiante = todosLosEstudiantes.firstWhereOrNull(
          (est) => est.id == estudianteId,
        );
        if (estudiante != null) {
          estudiantesPorEquipo[equipo.id!.toString()]?.add(estudiante);
          sinEquipo.remove(estudiante);
        }
      }
    }

    estudiantesSinEquipo.assignAll(sinEquipo);
  }

  Future<void> recargarDatos() async {
    if (categoria.value != null) {
      await _cargarDatos();
    }
  }

  void mostrarDialogoAgregarEstudiante(Equipo equipo) {
    final estudiantesDisponibles = estudiantesSinEquipo
        .where(
          (estudiante) =>
              !_estaEnEquipo(estudiante.id!.toString(), equipo.id!.toString()),
        )
        .toList();

    if (estudiantesDisponibles.isEmpty) {
      _showInfoSnackbar(
        'Sin estudiantes disponibles',
        'No hay estudiantes sin equipo para agregar',
      );
      return;
    }

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.person_add, color: Colors.green),
            const SizedBox(width: 8),
            Expanded(child: Text('Agregar a ${equipo.nombre}')),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Selecciona un estudiante:'),
              const SizedBox(height: 16),
              Container(
                constraints: const BoxConstraints(maxHeight: 300),
                child: SingleChildScrollView(
                  child: Column(
                    children: estudiantesDisponibles
                        .map(
                          (estudiante) => ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.green.withOpacity(0.1),
                              child: Text(
                                estudiante.nombre[0].toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(estudiante.nombre),
                            subtitle: Text(estudiante.email),
                            onTap: () {
                              Get.back();
                              _agregarEstudianteAEquipo(estudiante, equipo);
                            },
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  void mostrarDialogoMoverEstudiante(Usuario estudiante, Equipo equipoActual) {
    final equiposDisponibles = equipos
        .where(
          (equipo) =>
              equipo.id != equipoActual.id &&
              (estudiantesPorEquipo[equipo.id]?.length ?? 0) <
                  categoria.value!.maxEstudiantesPorEquipo,
        )
        .toList();

    if (equiposDisponibles.isEmpty) {
      _showInfoSnackbar(
        'No hay equipos disponibles',
        'Todos los otros equipos están completos',
      );
      return;
    }

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.swap_horiz, color: Colors.blue),
            const SizedBox(width: 8),
            const Text('Mover estudiante'),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Mover a ${estudiante.nombre}'),
              const SizedBox(height: 8),
              Text(
                'De: ${equipoActual.nombre}',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
              const SizedBox(height: 16),
              const Text('Selecciona el equipo destino:'),
              const SizedBox(height: 8),
              Container(
                constraints: const BoxConstraints(maxHeight: 200),
                child: SingleChildScrollView(
                  child: Column(
                    children: equiposDisponibles
                        .map(
                          (equipo) => ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.groups,
                                color: Colors.blue,
                                size: 20,
                              ),
                            ),
                            title: Text(equipo.nombre),
                            subtitle: Text(
                              '${estudiantesPorEquipo[equipo.id!.toString()]?.length ?? 0}/${categoria.value!.maxEstudiantesPorEquipo} miembros',
                            ),
                            onTap: () {
                              Get.back();
                              _moverEstudianteEntreEquipos(
                                estudiante,
                                equipoActual,
                                equipo,
                              );
                            },
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  void _agregarEstudianteAEquipo(Usuario estudiante, Equipo equipo) {
    // Verificar límite
    final currentCount = estudiantesPorEquipo[equipo.id]?.length ?? 0;
    if (currentCount >= categoria.value!.maxEstudiantesPorEquipo) {
      _showErrorSnackbar(
        'Equipo completo',
        'Este equipo ya tiene el máximo de estudiantes',
      );
      return;
    }

    // Verificar que el estudiante no esté ya en el equipo
    if (_estaEnEquipo(estudiante.id!.toString(), equipo.id!.toString())) {
      _showErrorSnackbar('Error', 'El estudiante ya está en este equipo');
      return;
    }

    // Usar update para forzar la reactividad completa del mapa
    estudiantesPorEquipo.update(equipo.id!.toString(), (value) {
      value.add(estudiante);
      return List<Usuario>.from(value); // Crear nueva lista para forzar cambio
    }, ifAbsent: () => [estudiante]);

    // Actualizar lista de estudiantes sin equipo
    estudiantesSinEquipo.remove(estudiante);

    // Forzar actualización completa de UI
    _forceUIUpdate();

    // Registrar cambio
    _registrarCambio(equipo.id!.toString(), estudiante.id!.toString());
    hayChangiosPendientes.value = true;

    _showSuccessSnackbar(
      'Estudiante agregado',
      '${estudiante.nombre} agregado a ${equipo.nombre}',
    );
  }

  void _moverEstudianteEntreEquipos(
    Usuario estudiante,
    Equipo equipoOrigen,
    Equipo equipoDestino,
  ) {
    // Verificar límite del equipo destino
    final currentCount =
        estudiantesPorEquipo[equipoDestino.id!.toString()]?.length ?? 0;
    if (currentCount >= categoria.value!.maxEstudiantesPorEquipo) {
      _showErrorSnackbar(
        'Equipo completo',
        'El equipo destino ya tiene el máximo de estudiantes',
      );
      return;
    }

    // Remover del equipo origen usando update
    estudiantesPorEquipo.update(equipoOrigen.id!.toString(), (value) {
      value.remove(estudiante);
      return List<Usuario>.from(value);
    });

    // Agregar al equipo destino usando update
    estudiantesPorEquipo.update(equipoDestino.id!.toString(), (value) {
      value.add(estudiante);
      return List<Usuario>.from(value);
    }, ifAbsent: () => [estudiante]);

    // Forzar actualización completa de UI
    _forceUIUpdate();

    // Registrar cambios
    _registrarCambio(
      equipoOrigen.id!.toString(),
      null,
    ); // Remover del equipo origen
    _registrarCambio(
      equipoDestino.id!.toString(),
      estudiante.id!.toString(),
    ); // Agregar al equipo destino
    hayChangiosPendientes.value = true;

    _showSuccessSnackbar(
      'Estudiante movido',
      '${estudiante.nombre} movido a ${equipoDestino.nombre}',
    );
  }

  void eliminarEstudianteDeEquipo(Usuario estudiante, Equipo equipo) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.person_remove, color: Colors.red),
            SizedBox(width: 8),
            Text('Quitar estudiante'),
          ],
        ),
        content: Text(
          '¿Quitar a ${estudiante.nombre} del equipo "${equipo.nombre}"?',
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
            onPressed: () {
              Get.back();
              _eliminarEstudianteDeEquipo(estudiante, equipo);
            },
            child: const Text('Quitar'),
          ),
        ],
      ),
    );
  }

  void _eliminarEstudianteDeEquipo(Usuario estudiante, Equipo equipo) {
    // Usar update para forzar la reactividad completa del mapa
    estudiantesPorEquipo.update(equipo.id!.toString(), (value) {
      value.remove(estudiante);
      return List<Usuario>.from(value); // Crear nueva lista para forzar cambio
    });

    // Actualizar lista de estudiantes sin equipo
    estudiantesSinEquipo.add(estudiante);

    // Forzar actualización completa de UI
    _forceUIUpdate();

    // Registrar cambio
    _registrarCambio(
      equipo.id!.toString(),
      null,
    ); // null indica remover estudiante
    hayChangiosPendientes.value = true;

    _showSuccessSnackbar(
      'Estudiante removido',
      '${estudiante.nombre} removido de ${equipo.nombre}',
    );
  }

  void eliminarEquipo(Equipo equipo) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 8),
            Text('Eliminar equipo'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('¿Eliminar el equipo "${equipo.nombre}"?'),
            const SizedBox(height: 8),
            if ((estudiantesPorEquipo[equipo.id!.toString()]?.length ?? 0) >
                0) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info, color: Colors.orange, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Los ${estudiantesPorEquipo[equipo.id!.toString()]?.length ?? 0} estudiantes quedarán sin equipo',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
            onPressed: () {
              Get.back();
              _eliminarEquipo(equipo);
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _eliminarEquipo(Equipo equipo) {
    // Mover estudiantes a la lista de sin equipo
    final estudiantesDelEquipo =
        estudiantesPorEquipo[equipo.id!.toString()] ?? [];
    for (var estudiante in estudiantesDelEquipo) {
      if (!estudiantesSinEquipo.contains(estudiante)) {
        estudiantesSinEquipo.add(estudiante);
      }
    }

    // Remover equipo localmente y forzar reactividad
    equipos.remove(equipo);
    estudiantesPorEquipo.remove(equipo.id!.toString());

    // Forzar actualización de las listas observables
    equipos.refresh();
    estudiantesPorEquipo.refresh();
    estudiantesSinEquipo.refresh();

    // Registrar equipo para eliminación
    _equiposAEliminar.add(equipo.id!.toString());
    hayChangiosPendientes.value = true;

    _showSuccessSnackbar(
      'Equipo eliminado',
      'El equipo "${equipo.nombre}" será eliminado al guardar',
    );
  }

  bool _estaEnEquipo(String estudianteId, String equipoId) {
    final estudiantes = estudiantesPorEquipo[equipoId] ?? [];
    return estudiantes.any((est) => est.id == estudianteId);
  }

  void _registrarCambio(String equipoId, String? estudianteId) {
    if (_cambiosPendientes[equipoId] == null) {
      _cambiosPendientes[equipoId] = [];
    }

    if (estudianteId != null) {
      if (!_cambiosPendientes[equipoId]!.contains(estudianteId)) {
        _cambiosPendientes[equipoId]!.add(estudianteId);
      }
    } else {
      // Si estudianteId es null, significa que necesitamos recalcular todo el equipo
      _cambiosPendientes[equipoId] = (estudiantesPorEquipo[equipoId] ?? [])
          .map((est) => est.id!.toString())
          .toList();
    }
  }

  Future<void> guardarCambios() async {
    if (!hayChangiosPendientes.value) return;

    try {
      isGuardando.value = true;

      // TODO: Implementar eliminarEquipo en CategoriaEquipoUseCase
      // Eliminar equipos marcados para eliminación
      for (String equipoId in _equiposAEliminar) {
        // await _categoriaEquipoUseCase.eliminarEquipo(equipoId);
        print('Equipo a eliminar: $equipoId');
      }

      // TODO: Implementar actualizarEstudiantesEquipo en CategoriaEquipoUseCase
      // Actualizar equipos con nuevos estudiantes
      for (String equipoId in _cambiosPendientes.keys) {
        if (!_equiposAEliminar.contains(equipoId)) {
          final estudiantesIds = (estudiantesPorEquipo[equipoId] ?? [])
              .map((est) => est.id!.toString())
              .toList();

          // await _categoriaEquipoUseCase.actualizarEstudiantesEquipo(
          //   equipoId,
          //   estudiantesIds
          // );
          print('Equipo $equipoId con estudiantes: $estudiantesIds');
        }
      }

      // Limpiar cambios pendientes
      _cambiosPendientes.clear();
      _equiposAEliminar.clear();
      hayChangiosPendientes.value = false;

      _showSuccessSnackbar(
        'Cambios guardados',
        'Todos los cambios han sido aplicados exitosamente',
      );

      // Recargar datos para asegurar consistencia
      await recargarDatos();
    } catch (e) {
      _showErrorSnackbar('Error al guardar', e.toString());
    } finally {
      isGuardando.value = false;
    }
  }

  void descartarCambios() {
    if (!hayChangiosPendientes.value) {
      Get.back();
      return;
    }

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.orange),
            SizedBox(width: 8),
            Text('Descartar cambios'),
          ],
        ),
        content: const Text(
          '¿Descartar todos los cambios realizados? Esta acción no se puede deshacer.',
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
              Get.back();

              // Recargar datos originales
              await recargarDatos();

              // Limpiar cambios pendientes
              _cambiosPendientes.clear();
              _equiposAEliminar.clear();
              hayChangiosPendientes.value = false;

              _showInfoSnackbar(
                'Cambios descartados',
                'Se han restaurado los datos originales',
              );
              Get.back();
            },
            child: const Text('Descartar'),
          ),
        ],
      ),
    );
  }

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

  void _showInfoSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      backgroundColor: Colors.blue,
      colorText: Colors.white,
      icon: const Icon(Icons.info, color: Colors.white),
      duration: const Duration(seconds: 3),
    );
  }

  @override
  void onClose() {
    super.onClose();
  }
}
