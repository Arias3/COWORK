// editar_estudiantes_categoria_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/editar_estudiantes_categoria_controller.dart';
import '../../domain/entities/categoria_equipo_entity.dart';
import '../../domain/entities/equipo_entity.dart';
import '../../../auth/domain/entities/user_entity.dart';

class EditarEstudiantesCategoriaPage extends StatelessWidget {
  const EditarEstudiantesCategoriaPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      EditarEstudiantesCategoriaController(Get.find()),
    );
    final arguments = Get.arguments as Map<String, dynamic>;
    final categoria = arguments['categoria'] as CategoriaEquipo;

    // Inicializar datos
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.inicializar(categoria);
    });

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(categoria),
      body: _buildBody(controller),
      bottomNavigationBar: _buildBottomBar(controller),
    );
  }

  PreferredSizeWidget _buildAppBar(CategoriaEquipo categoria) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black87),
        onPressed: () => Get.back(),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Editar Estudiantes',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Text(
            categoria.nombre,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.normal,
              color: Colors.grey,
            ),
          ),
        ],
      ),
      actions: [
        Obx(() {
          final controller = Get.find<EditarEstudiantesCategoriaController>();
          return IconButton(
            onPressed: controller.hayChangiosPendientes.value
                ? () => controller.guardarCambios()
                : null,
            icon: Icon(
              Icons.save,
              color: controller.hayChangiosPendientes.value
                  ? Colors.green
                  : Colors.grey,
            ),
          );
        }),
      ],
    );
  }

  Widget _buildBody(EditarEstudiantesCategoriaController controller) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.equipos.isEmpty) {
        return _buildEmptyState();
      }

      return Column(
        children: [
          _buildEstadisticas(controller),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => controller.recargarDatos(),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: controller.equipos
                      .map(
                        (equipo) =>
                            _buildEquipoEditableCard(equipo, controller),
                      )
                      .toList(),
                ),
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Icon(
                Icons.groups_outlined,
                size: 64,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No hay equipos en esta categoría',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Crea equipos primero para poder editar estudiantes',
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEstadisticas(EditarEstudiantesCategoriaController controller) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Obx(
        () => Column(
          children: [
            Row(
              children: [
                const Icon(Icons.analytics, color: Colors.blue, size: 24),
                const SizedBox(width: 12),
                const Text(
                  'Estadísticas de la Categoría',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildEstadisticaItem(
                  'Equipos',
                  '${controller.equipos.length}',
                  Icons.groups,
                  Colors.blue,
                ),
                const SizedBox(width: 16),
                _buildEstadisticaItem(
                  'Estudiantes',
                  '${controller.totalEstudiantes}',
                  Icons.people,
                  Colors.green,
                ),
                const SizedBox(width: 16),
                _buildEstadisticaItem(
                  'Sin equipo',
                  '${controller.estudiantesSinEquipo.length}',
                  Icons.person_outline,
                  Colors.orange,
                ),
              ],
            ),
            if (controller.hayChangiosPendientes.value) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.edit, color: Colors.amber, size: 16),
                    const SizedBox(width: 8),
                    const Text(
                      'Hay cambios sin guardar',
                      style: TextStyle(
                        color: Colors.amber,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEstadisticaItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEquipoEditableCard(
    Equipo equipo,
    EditarEstudiantesCategoriaController controller,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header del equipo
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.groups, color: Colors.blue, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Obx(() {
                    // Forzar observación del contador de cambios UI
                    controller.uiUpdateCounter.value;
                    final estudiantesCount =
                        controller.estudiantesPorEquipo[equipo.id]?.length ?? 0;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          equipo.nombre,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          '$estudiantesCount/${controller.categoria.value?.maxEstudiantesPorEquipo ?? 0} miembros',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    );
                  }),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'eliminar_equipo':
                        controller.eliminarEquipo(equipo);
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'eliminar_equipo',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Eliminar equipo',
                            style: TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Lista de estudiantes del equipo
          Padding(
            padding: const EdgeInsets.all(16),
            child: Obx(() {
              // Forzar observación del contador de cambios UI
              controller.uiUpdateCounter.value;
              final estudiantesEquipo =
                  controller.estudiantesPorEquipo[equipo.id] ?? [];

              if (estudiantesEquipo.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.grey),
                      SizedBox(width: 12),
                      Text(
                        'No hay estudiantes en este equipo',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }

              return Column(
                children: [
                  ...estudiantesEquipo.map(
                    (estudiante) =>
                        _buildEstudianteItem(estudiante, equipo, controller),
                  ),
                  const SizedBox(height: 8),
                  _buildAgregarEstudianteButton(equipo, controller),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildEstudianteItem(
    Usuario estudiante,
    Equipo equipo,
    EditarEstudiantesCategoriaController controller,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.blue.withOpacity(0.1),
            child: Text(
              estudiante.nombre[0].toUpperCase(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${estudiante.nombre}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                if (estudiante.email.isNotEmpty)
                  Text(
                    estudiante.email,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'mover':
                  controller.mostrarDialogoMoverEstudiante(estudiante, equipo);
                  break;
                case 'eliminar':
                  controller.eliminarEstudianteDeEquipo(estudiante, equipo);
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'mover',
                child: Row(
                  children: [
                    Icon(Icons.swap_horiz, color: Colors.blue, size: 20),
                    SizedBox(width: 8),
                    Text('Mover a otro equipo'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'eliminar',
                child: Row(
                  children: [
                    Icon(Icons.person_remove, color: Colors.red, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Quitar del equipo',
                      style: TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ),
            ],
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.more_vert, size: 16, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgregarEstudianteButton(
    Equipo equipo,
    EditarEstudiantesCategoriaController controller,
  ) {
    return Obx(() {
      final puedeAgregarMas =
          (controller.estudiantesPorEquipo[equipo.id]?.length ?? 0) <
          (controller.categoria.value?.maxEstudiantesPorEquipo ?? 0);

      if (!puedeAgregarMas) {
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.info, color: Colors.orange, size: 16),
              SizedBox(width: 8),
              Text(
                'Equipo completo',
                style: TextStyle(
                  color: Colors.orange,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      }

      return InkWell(
        onTap: () => controller.mostrarDialogoAgregarEstudiante(equipo),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.blue, style: BorderStyle.solid),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person_add, color: Colors.blue, size: 16),
              SizedBox(width: 8),
              Text(
                'Agregar estudiante',
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildBottomBar(EditarEstudiantesCategoriaController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => controller.descartarCambios(),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.grey[600],
                side: BorderSide(color: Colors.grey[300]!),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('Cancelar'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Obx(
              () => ElevatedButton(
                onPressed: controller.hayChangiosPendientes.value
                    ? () => controller.guardarCambios()
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  elevation: 0,
                ),
                child: controller.isGuardando.value
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Text('Guardar cambios'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
