import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domain/entities/activity.dart';
import '../controllers/activity_controller.dart';
import '../../../categories/domain/entities/equipo_entity.dart';

class ActivityAssignmentPage extends StatefulWidget {
  final Activity activity;

  const ActivityAssignmentPage({super.key, required this.activity});

  @override
  State<ActivityAssignmentPage> createState() => _ActivityAssignmentPageState();
}

class _ActivityAssignmentPageState extends State<ActivityAssignmentPage> {
  final ActivityController controller = Get.find<ActivityController>();
  List<int> equiposConActividad = [];
  bool isLoadingAssignments = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // Cargar equipos de la categoría
    await controller.loadEquiposPorCategoria(widget.activity.categoryId);

    // Cargar qué equipos ya tienen esta actividad asignada
    equiposConActividad = await controller.getEquiposConActividad(
      widget.activity.id!,
    );

    setState(() {
      isLoadingAssignments = false;
    });
  }

  Future<void> _onActivityAssigned() async {
    // Recargar datos después de asignar
    setState(() {
      isLoadingAssignments = true;
    });
    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF6366F1), // Indigo
                Color(0xFF8B5CF6), // Purple
              ],
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Asignar Actividad',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              widget.activity.name,
              style: const TextStyle(fontSize: 14, color: Colors.white70),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        children: [
          // Header con información de la actividad
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.assignment, color: Colors.blue[600], size: 24),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.activity.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  widget.activity.description,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                const SizedBox(height: 8),
                Text(
                  'Fecha de entrega: ${widget.activity.deliveryDate.day}/${widget.activity.deliveryDate.month}/${widget.activity.deliveryDate.year}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),

          // Lista de equipos de la categoría de la actividad
          Expanded(
            child: Obx(() {
              if (controller.isLoadingTeams.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.equiposDisponibles.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.group_off, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No hay equipos disponibles',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Esta categoría no tiene equipos creados',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }

              return Column(
                children: [
                  // Header con información de la categoría y botón seleccionar todos
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.group, color: Colors.blue[600], size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Equipos disponibles: ${controller.equiposDisponibles.length}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[800],
                                ),
                              ),
                              Text(
                                'Selecciona los equipos para asignar esta actividad',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () => controller.selectAllTeams(),
                          icon: const Icon(Icons.select_all, size: 18),
                          label: const Text('Todos'),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.blue[600],
                            backgroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Lista de equipos
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: controller.equiposDisponibles.length,
                      itemBuilder: (context, index) {
                        final equipo = controller.equiposDisponibles[index];
                        return _buildEquipoCard(equipo, controller);
                      },
                    ),
                  ),
                ],
              );
            }),
          ),

          // Bottom bar con botones de acción
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Obx(
                    () => Text(
                      '${controller.equiposSeleccionados.length} equipo(s) seleccionado(s)',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () => controller.clearEquiposSelection(),
                  icon: const Icon(Icons.clear_all, size: 18),
                  label: const Text('Limpiar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[200],
                    foregroundColor: Colors.grey[700],
                  ),
                ),
                const SizedBox(width: 8),
                Obx(
                  () => ElevatedButton.icon(
                    onPressed: controller.equiposSeleccionados.isNotEmpty
                        ? () async {
                            await controller.assignActivityToSelectedTeams(
                              widget.activity,
                            );
                            await _onActivityAssigned();
                          }
                        : null,
                    icon: const Icon(Icons.assignment_turned_in, size: 18),
                    label: const Text('Asignar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6366F1),
                      foregroundColor: Colors.white,
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

  Widget _buildEquipoCard(Equipo equipo, ActivityController controller) {
    return Obx(() {
      final isSelected = controller.isEquipoSelected(equipo.id!);
      final isAlreadyAssigned = equiposConActividad.contains(equipo.id!);

      return Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: isSelected ? 4 : 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isAlreadyAssigned
                ? Colors.blue[400]!
                : (isSelected ? Colors.green[400]! : Colors.grey[200]!),
            width: isAlreadyAssigned || isSelected ? 2 : 1,
          ),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: CircleAvatar(
            backgroundColor: isAlreadyAssigned
                ? Colors.blue[100]
                : (isSelected ? Colors.green[100] : Colors.grey[100]),
            child: Icon(
              isAlreadyAssigned
                  ? Icons.assignment_turned_in
                  : (isSelected ? Icons.check_circle : Icons.group),
              color: isAlreadyAssigned
                  ? Colors.blue[600]
                  : (isSelected ? Colors.green[600] : Colors.grey[600]),
              size: 24,
            ),
          ),
          title: Text(
            equipo.nombre,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              fontSize: 16,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              if (equipo.descripcion != null && equipo.descripcion!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    equipo.descripcion!,
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${equipo.estudiantesIds.length} estudiante(s)',
                      style: TextStyle(
                        color: Colors.blue[600],
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  // 🔹 NUEVO: Indicador de estado asignado
                  if (isAlreadyAssigned) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue[100],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue[300]!, width: 1),
                      ),
                      child: Text(
                        'YA ASIGNADA',
                        style: TextStyle(
                          color: Colors.blue[700],
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          trailing: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isAlreadyAssigned
                      ? Icons.assignment_turned_in
                      : (isSelected
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked),
                  color: isAlreadyAssigned
                      ? Colors.blue[600]
                      : (isSelected ? Colors.green[600] : Colors.grey[400]),
                  size: 28,
                ),
                if (isAlreadyAssigned)
                  Text(
                    'Asignada',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.blue[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
          onTap: isAlreadyAssigned
              ? null // No permitir selección si ya está asignada
              : () => controller.toggleEquipoSelection(equipo.id!),
          selected: isSelected,
          selectedTileColor: Colors.green[50],
        ),
      );
    });
  }
}
