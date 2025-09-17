import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../home/domain/entities/curso_entity.dart';
import '../../domain/entities/categoria_equipo_entity.dart';
import '../../domain/entities/equipo_entity.dart';
import '../../domain/entities/tipo_asignacion.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../controllers/categoria_equipo_controller.dart';

class CategoriasEquiposPage extends StatelessWidget {
  final CursoDomain curso;

  const CategoriasEquiposPage({Key? key, required this.curso})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      CategoriaEquipoController(Get.find(), Get.find()),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadCategoriasPorCurso(curso);
    });

    return Obx(() {
      final esProfesor = controller.esProfesorDelCursoActual;

      return DefaultTabController(
        length: esProfesor ? 2 : 1,
        child: Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: _buildAppBar(esProfesor),
          body: _buildBody(controller, esProfesor),
          floatingActionButton: esProfesor ? _buildFAB(controller) : null,
        ),
      );
    });
  }

  PreferredSizeWidget _buildAppBar(bool esProfesor) {
    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Equipos y Categorías',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            curso.nombre,
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
      bottom: esProfesor
          ? const TabBar(
              tabs: [
                Tab(icon: Icon(Icons.category), text: 'Categorías'),
                Tab(icon: Icon(Icons.groups), text: 'Equipos'),
              ],
            )
          : null,
    );
  }

  Widget _buildBody(CategoriaEquipoController controller, bool esProfesor) {
    if (esProfesor) {
      return TabBarView(
        children: [
          _buildCategoriasView(controller),
          _buildEquiposView(controller),
        ],
      );
    }
    return _buildEstudianteView(controller);
  }

  Widget _buildCategoriasView(CategoriaEquipoController controller) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      return RefreshIndicator(
        onRefresh: () => controller.loadCategoriasPorCurso(curso),
        child: controller.categorias.isEmpty
            ? _buildEmptyState(
                'No hay categorías',
                'Crea categorías para organizar equipos',
                Icons.category,
                controller.mostrarDialogoCrearCategoria,
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: controller.categorias.length,
                itemBuilder: (context, index) => _buildCategoriaCard(
                  controller.categorias[index],
                  controller,
                ),
              ),
      );
    });
  }

  Widget _buildCategoriaCard(
    CategoriaEquipo categoria,
    CategoriaEquipoController controller,
  ) {
    final isManual = categoria.tipoAsignacion == TipoAsignacion.manual;
    final color = isManual ? Colors.green : Colors.orange;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(isManual ? Icons.person_add : Icons.shuffle, color: color),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        categoria.nombre,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${categoria.tipoAsignacion.name.toUpperCase()} - ${categoria.equiposIds.length} equipos',
                        style: TextStyle(color: color, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) =>
                      _handleCategoriaAction(value, categoria, controller),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'equipos',
                      child: Text('Ver equipos'),
                    ),
                    const PopupMenuItem(value: 'editar', child: Text('Editar')),
                    const PopupMenuItem(
                      value: 'eliminar',
                      child: Text('Eliminar'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Máximo ${categoria.maxEstudiantesPorEquipo} estudiantes por equipo',
            ),
            if (!isManual) ...[
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    controller.selectCategoria(categoria);
                    controller.generarEquiposAleatorios();
                  },
                  icon: const Icon(Icons.shuffle),
                  label: const Text('Generar Equipos'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _handleCategoriaAction(
    String action,
    CategoriaEquipo categoria,
    CategoriaEquipoController controller,
  ) {
    switch (action) {
      case 'equipos':
        controller.selectCategoria(categoria);
        DefaultTabController.of(Get.context!).animateTo(1);
        break;
      case 'editar':
        controller.mostrarDialogoEditarCategoria(categoria);
        break;
      case 'eliminar':
        controller.eliminarCategoria(categoria);
        break;
    }
  }

  Widget _buildEquiposView(CategoriaEquipoController controller) {
    return Column(
      children: [
        // Selector de categorías
        _buildCategorySelector(controller),
        // Botón para crear equipo
        _buildCreateTeamButton(controller),
        // Lista de equipos
        Expanded(
          child: Obx(() {
            if (controller.categoriaSeleccionada.value == null) {
              return const Center(child: Text('Selecciona una categoría'));
            }

            if (controller.isLoadingEquipos.value) {
              return const Center(child: CircularProgressIndicator());
            }

            if (controller.equipos.isEmpty) {
              return _buildEmptyState(
                'No hay equipos',
                'Crea equipos en esta categoría',
                Icons.groups,
                controller.mostrarDialogoCrearEquipo,
              );
            }

            return RefreshIndicator(
              onRefresh: () => controller.selectCategoria(
                controller.categoriaSeleccionada.value!,
              ),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: controller.equipos.length,
                itemBuilder: (context, index) =>
                    _buildEquipoCard(controller.equipos[index], controller),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildCategorySelector(CategoriaEquipoController controller) {
    return Container(
      height: 60,
      padding: const EdgeInsets.all(8),
      child: Obx(
        () => ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: controller.categorias.length,
          itemBuilder: (context, index) {
            final categoria = controller.categorias[index];

            return Obx(() {
              final isSelected =
                  controller.categoriaSeleccionada.value?.id == categoria.id;

              return GestureDetector(
                onTap: () => controller.selectCategoria(categoria),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.blue : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? Colors.blue : Colors.grey,
                    ),
                  ),
                  child: Text(
                    categoria.nombre,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            });
          },
        ),
      ),
    );
  }

  Widget _buildCreateTeamButton(CategoriaEquipoController controller) {
    return Obx(() {
      if (controller.categoriaSeleccionada.value != null) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: controller.mostrarDialogoCrearEquipo,
              icon: const Icon(Icons.group_add),
              label: const Text('Crear Nuevo Equipo'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        );
      }
      return const SizedBox.shrink();
    });
  }

  Widget _buildEquipoCard(Equipo equipo, CategoriaEquipoController controller) {
    final categoria = controller.categoriaSeleccionada.value!;
    final progress =
        equipo.estudiantesIds.length / categoria.maxEstudiantesPorEquipo;
    final isComplete = progress >= 1.0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.groups,
                  color: isComplete ? Colors.green : Colors.blue,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        equipo.nombre,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${equipo.estudiantesIds.length}/${categoria.maxEstudiantesPorEquipo} miembros',
                      ),
                    ],
                  ),
                ),
                if (isComplete)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'COMPLETO',
                      style: TextStyle(color: Colors.green, fontSize: 10),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation(
                isComplete ? Colors.green : Colors.blue,
              ),
            ),
            if (equipo.descripcion?.isNotEmpty == true) ...[
              const SizedBox(height: 8),
              Text(
                equipo.descripcion!,
                style: const TextStyle(fontStyle: FontStyle.italic),
              ),
            ],
            // Mostrar estudiantes
            if (equipo.estudiantesIds.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text(
                'Estudiantes:',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildStudentsList(equipo, controller),
            ] else ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.grey, size: 16),
                    SizedBox(width: 8),
                    Text(
                      'Sin estudiantes asignados',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
            // Botón para gestionar estudiantes (solo profesores)
            if (controller.esProfesorDelCursoActual) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _mostrarDialogoGestionarEstudiantes(
                        equipo,
                        controller,
                      ),
                      icon: const Icon(Icons.manage_accounts, size: 16),
                      label: const Text('Gestionar Estudiantes'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.blue,
                        side: const BorderSide(color: Colors.blue),
                      ),
                    ),
                  ),
                  if (!isComplete) ...[
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _mostrarDialogoAgregarEstudiante(
                          equipo,
                          controller,
                        ),
                        icon: const Icon(Icons.person_add, size: 16),
                        label: const Text('Agregar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStudentsList(
    Equipo equipo,
    CategoriaEquipoController controller,
  ) {
    return FutureBuilder<List<Usuario>>(
      future: controller.getEstudiantesDelCurso(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 8),
              Text(
                'Cargando estudiantes...',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          );
        }

        final todosEstudiantes = snapshot.data ?? [];

        return Wrap(
          spacing: 8,
          runSpacing: 4,
          children: equipo.estudiantesIds.map((studentId) {
            final estudiante = todosEstudiantes.firstWhere(
              (est) => est.id == studentId,
              orElse: () => Usuario(
                id: studentId,
                nombre: 'Usuario $studentId',
                email: '',
                password: '',
                rol: 'estudiante',
              ),
            );

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.person, size: 16, color: Colors.blue),
                  const SizedBox(width: 4),
                  Text(
                    estudiante.nombre,
                    style: const TextStyle(fontSize: 12, color: Colors.blue),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildEstudianteView(CategoriaEquipoController controller) {
    return Column(
      children: [
        _buildCategorySelector(controller),
        Expanded(
          child: Obx(() {
            if (controller.categoriaSeleccionada.value == null) {
              return const Center(child: Text('Selecciona una categoría'));
            }

            final categoria = controller.categoriaSeleccionada.value!;
            final miEquipo = controller.miEquipo.value;

            if (miEquipo != null) {
              return _buildMiEquipoView(miEquipo, controller);
            }

            if (categoria.tipoAsignacion == TipoAsignacion.aleatoria) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.schedule, size: 64, color: Colors.orange),
                    SizedBox(height: 16),
                    Text(
                      'Equipos pendientes',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text('El profesor aún no ha generado los equipos'),
                  ],
                ),
              );
            }

            return _buildEquiposDisponiblesView(controller);
          }),
        ),
      ],
    );
  }

  Widget _buildMiEquipoView(
    Equipo miEquipo,
    CategoriaEquipoController controller,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        color: Colors.green[50],
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.group, size: 48, color: Colors.green),
              const SizedBox(height: 12),
              Text(
                'Mi Equipo: ${miEquipo.nombre}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text('${miEquipo.estudiantesIds.length} miembros'),
              const SizedBox(height: 16),
              if (controller.categoriaSeleccionada.value?.tipoAsignacion ==
                  TipoAsignacion.manual)
                ElevatedButton(
                  onPressed: controller.salirDeEquipo,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text('Salir del equipo'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEquiposDisponiblesView(CategoriaEquipoController controller) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Equipos disponibles',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed: controller.mostrarDialogoCrearEquipo,
                icon: const Icon(Icons.add),
                label: const Text('Crear'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Obx(() {
              if (controller.equiposDisponibles.isEmpty) {
                return const Center(child: Text('No hay equipos disponibles'));
              }

              return ListView.builder(
                itemCount: controller.equiposDisponibles.length,
                itemBuilder: (context, index) {
                  final equipo = controller.equiposDisponibles[index];
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.groups),
                      title: Text(equipo.nombre),
                      subtitle: Text(
                        '${equipo.estudiantesIds.length}/${controller.categoriaSeleccionada.value?.maxEstudiantesPorEquipo} miembros',
                      ),
                      trailing: ElevatedButton(
                        onPressed: () => controller.unirseAEquipo(equipo),
                        child: const Text('Unirse'),
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget? _buildFAB(CategoriaEquipoController controller) {
    return FloatingActionButton.extended(
      onPressed: controller.mostrarDialogoCrearCategoria,
      icon: const Icon(Icons.add),
      label: const Text('Nueva Categoría'),
      backgroundColor: Colors.blue,
    );
  }

  Widget _buildEmptyState(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(subtitle, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onPressed,
              icon: const Icon(Icons.add),
              label: const Text('Crear'),
            ),
          ],
        ),
      ),
    );
  }

  // Diálogo para agregar estudiante individual
  void _mostrarDialogoAgregarEstudiante(
    Equipo equipo,
    CategoriaEquipoController controller,
  ) {
    Get.dialog(
      Dialog(
        child: Container(
          width: 500,
          height: 600,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.person_add, color: Colors.green),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Agregar Estudiante',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Equipo: ${equipo.nombre}',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info, color: Colors.green),
                    const SizedBox(width: 8),
                    Text(
                      '${equipo.estudiantesIds.length}/${controller.categoriaSeleccionada.value?.maxEstudiantesPorEquipo} estudiantes en el equipo',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Estudiantes disponibles del curso:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: FutureBuilder<List<Usuario>>(
                  future: controller.getEstudiantesDisponiblesParaEquipo(
                    equipo.id!.toString(),
                  ),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error,
                              size: 64,
                              color: Colors.red,
                            ),
                            const SizedBox(height: 16),
                            Text('Error: ${snapshot.error}'),
                            ElevatedButton(
                              onPressed: () => Get.back(),
                              child: const Text('Cerrar'),
                            ),
                          ],
                        ),
                      );
                    }

                    final estudiantesDisponibles = snapshot.data ?? [];

                    if (estudiantesDisponibles.isEmpty) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.people_outline,
                              size: 64,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No hay estudiantes disponibles',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              'Todos los estudiantes del curso ya están asignados a equipos',
                              style: TextStyle(color: Colors.grey),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: estudiantesDisponibles.length,
                      itemBuilder: (context, index) {
                        final estudiante = estudiantesDisponibles[index];
                        final categoria =
                            controller.categoriaSeleccionada.value!;
                        final puedeAgregar =
                            equipo.estudiantesIds.length <
                            categoria.maxEstudiantesPorEquipo;

                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.blue.withOpacity(0.1),
                              child: Text(
                                estudiante.nombre.substring(0, 1).toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(estudiante.nombre),
                            subtitle: Text(estudiante.email),
                            trailing: ElevatedButton(
                              onPressed: puedeAgregar
                                  ? () {
                                      Get.back();
                                      controller.agregarEstudianteAEquipo(
                                        equipo.id!.toString(),
                                        estudiante.id!.toString(),
                                      );
                                    }
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: puedeAgregar
                                    ? Colors.green
                                    : Colors.grey,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Agregar'),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  child: const Text('Cerrar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Diálogo para gestionar todos los estudiantes del equipo
  void _mostrarDialogoGestionarEstudiantes(
    Equipo equipo,
    CategoriaEquipoController controller,
  ) {
    // Primero cargar todos los estudiantes
    controller.getEstudiantesDelCurso();

    Get.dialog(
      Dialog(
        child: Container(
          width: 600,
          height: 700,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.manage_accounts, color: Colors.blue),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Gestionar Estudiantes',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Equipo: ${equipo.nombre}',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Contador reactivo de estudiantes
              Obx(() {
                // Buscar el equipo actualizado en la lista de equipos
                final equipoActualizado = controller.equipos.firstWhere(
                  (e) => e.id == equipo.id,
                  orElse: () => equipo,
                );

                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info, color: Colors.blue),
                      const SizedBox(width: 8),
                      Text(
                        '${equipoActualizado.estudiantesIds.length}/${controller.categoriaSeleccionada.value?.maxEstudiantesPorEquipo} estudiantes',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Estudiantes en el equipo:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      Get.back();
                      _mostrarDialogoAgregarEstudiante(equipo, controller);
                    },
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Agregar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Lista reactiva de estudiantes
              Expanded(
                child: Obx(() {
                  // Buscar el equipo actualizado en la lista de equipos
                  final equipoActualizado = controller.equipos.firstWhere(
                    (e) => e.id == equipo.id,
                    orElse: () => equipo,
                  );

                  return FutureBuilder<List<Usuario>>(
                    future: controller.getEstudiantesDelCurso(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final todosEstudiantes = snapshot.data ?? [];

                      // Filtrar solo los estudiantes que están en este equipo (usando datos actualizados)
                      final estudiantesEnEquipo = todosEstudiantes.where((
                        estudiante,
                      ) {
                        return equipoActualizado.estudiantesIds.contains(
                          estudiante.id,
                        );
                      }).toList();

                      if (estudiantesEnEquipo.isEmpty) {
                        return const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.people_outline,
                                size: 64,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'No hay estudiantes en este equipo',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                'Usa el botón "Agregar" para añadir estudiantes',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        itemCount: estudiantesEnEquipo.length,
                        itemBuilder: (context, index) {
                          final estudiante = estudiantesEnEquipo[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.blue.withOpacity(0.1),
                                child: Text(
                                  estudiante.nombre
                                      .substring(0, 1)
                                      .toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text(estudiante.nombre),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(estudiante.email),
                                  Text(
                                    'ID: ${estudiante.id}',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                              trailing: Obx(
                                () => IconButton(
                                  onPressed: controller.isRemovingStudent.value
                                      ? null
                                      : () {
                                          // Verificación adicional inmediatamente antes de la acción
                                          if (controller
                                              .isRemovingStudent
                                              .value) {
                                            return;
                                          }
                                          _confirmarRemoverEstudiante(
                                            equipoActualizado,
                                            estudiante.id!.toString(),
                                            estudiante.nombre,
                                            controller,
                                          );
                                        },
                                  icon: Icon(
                                    Icons.remove_circle,
                                    color: controller.isRemovingStudent.value
                                        ? Colors.grey
                                        : Colors.red,
                                  ),
                                  tooltip: controller.isRemovingStudent.value
                                      ? 'Procesando...'
                                      : 'Remover del equipo',
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                }),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  child: const Text('Cerrar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Confirmación para remover estudiante
  void _confirmarRemoverEstudiante(
    Equipo equipo,
    String estudianteId,
    String nombreEstudiante,
    CategoriaEquipoController controller,
  ) {
    // Verificar si ya hay una operación en curso
    if (controller.isRemovingStudent.value) {
      Get.snackbar(
        'Espera',
        'Ya hay una operación de remoción en curso. Por favor espera.',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
      return;
    }

    Get.dialog(
      AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.orange),
            SizedBox(width: 8),
            Text('Remover Estudiante'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '¿Remover a "$nombreEstudiante" del equipo "${equipo.nombre}"?',
            ),
            const SizedBox(height: 8),
            const Text(
              'Esta acción se puede deshacer agregándolo nuevamente.',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              // Cerrar inmediatamente el diálogo
              Get.back();

              // Pequeño delay para permitir que el diálogo se cierre completamente
              await Future.delayed(const Duration(milliseconds: 200));

              // Verificar que el estudiante aún esté en el equipo antes de proceder
              final equipoActual = controller.equipos.firstWhere(
                (e) => e.id == equipo.id,
                orElse: () =>
                    equipo, // Usar el equipo original si no se encuentra actualizado
              );

              if (!equipoActual.estudiantesIds.contains(
                int.parse(estudianteId),
              )) {
                // El estudiante ya no está en el equipo
                Get.snackbar(
                  'Información',
                  'El estudiante ya fue removido del equipo',
                  backgroundColor: Colors.orange,
                  colorText: Colors.white,
                  duration: const Duration(seconds: 2),
                );
                return;
              }

              // Ejecutar la operación de remover de forma asíncrona
              await _ejecutarRemoverEstudiante(
                equipo,
                estudianteId,
                controller,
              );
            },
            child: const Text('Remover'),
          ),
        ],
      ),
      barrierDismissible: false, // Prevenir cierre accidental
    );
  }

  // Método auxiliar para ejecutar la remoción
  Future<void> _ejecutarRemoverEstudiante(
    Equipo equipo,
    String estudianteId,
    CategoriaEquipoController controller,
  ) async {
    try {
      // El controlador ya maneja isRemovingStudent.value internamente
      await controller.removerEstudianteDeEquipo(
        equipo.id!.toString(),
        estudianteId,
      );

      Get.snackbar(
        'Éxito',
        'Estudiante removido correctamente del equipo',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error al remover estudiante: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
    // El estado se libera automáticamente en el controlador
  }
}
