import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domain/entities/activity.dart';
import '../controllers/activity_controller.dart';
import '../../../evaluations/presentation/pages/evaluaciones_page.dart';

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
    try {
      // Limpiar selección previa
      controller.clearEquiposSelection();

      // Cargar equipos de la categoría
      await controller.loadEquiposPorCategoria(widget.activity.categoriaId);

      // Cargar qué equipos ya tienen esta actividad asignada
      equiposConActividad = await controller.getEquiposConActividad(
        widget.activity.robleId ?? widget.activity.id.toString(),
      );

      print('🔍 Equipos con actividad asignada: $equiposConActividad');
      print(
        '🔍 Total equipos disponibles: ${controller.equiposDisponibles.length}',
      );

      setState(() {
        isLoadingAssignments = false;
      });
    } catch (e) {
      print('❌ Error cargando datos de asignación: $e');
      setState(() {
        isLoadingAssignments = false;
      });
    }
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
              widget.activity.nombre,
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
          GestureDetector(
            onTap: equiposConActividad.isNotEmpty
                ? () =>
                      Get.to(() => EvaluacionesPage(activity: widget.activity))
                : null,
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: equiposConActividad.isNotEmpty
                    ? Colors.green[50]
                    : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: equiposConActividad.isNotEmpty
                    ? Border.all(color: Colors.green[300]!, width: 2)
                    : null,
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
                      Icon(
                        Icons.assignment,
                        color: equiposConActividad.isNotEmpty
                            ? Colors.green[600]
                            : Colors.blue[600],
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.activity.nombre,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: equiposConActividad.isNotEmpty
                                ? Colors.green[800]
                                : Colors.black,
                          ),
                        ),
                      ),
                      // Siempre mostrar referencia a evaluaciones
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: equiposConActividad.isNotEmpty
                              ? Colors.green[100]
                              : Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                          border: equiposConActividad.isNotEmpty
                              ? null
                              : Border.all(color: Colors.grey[300]!, width: 1),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.assessment,
                              size: 16,
                              color: equiposConActividad.isNotEmpty
                                  ? Colors.green[700]
                                  : Colors.grey[500],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              equiposConActividad.isNotEmpty
                                  ? 'Evaluar'
                                  : 'Evaluaciones',
                              style: TextStyle(
                                color: equiposConActividad.isNotEmpty
                                    ? Colors.green[700]
                                    : Colors.grey[500],
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (equiposConActividad.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Colors.green[600],
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.activity.descripcion,
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Fecha de entrega: ${widget.activity.fechaEntrega.day}/${widget.activity.fechaEntrega.month}/${widget.activity.fechaEntrega.year}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  const SizedBox(height: 12),
                  // Indicador de funcionalidad de evaluaciones
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: equiposConActividad.isNotEmpty
                          ? Colors.green[50]
                          : Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: equiposConActividad.isNotEmpty
                            ? Colors.green[200]!
                            : Colors.blue[200]!,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          equiposConActividad.isNotEmpty
                              ? Icons.touch_app
                              : Icons.info_outline,
                          size: 16,
                          color: equiposConActividad.isNotEmpty
                              ? Colors.green[600]
                              : Colors.blue[600],
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            equiposConActividad.isNotEmpty
                                ? 'Toca este card para acceder a las evaluaciones de esta actividad'
                                : 'Asigna equipos para activar el acceso directo a evaluaciones',
                            style: TextStyle(
                              color: equiposConActividad.isNotEmpty
                                  ? Colors.green[700]
                                  : Colors.blue[700],
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ), // Cierre del GestureDetector
          // Lista de equipos de la categoría de la actividad
          Expanded(
            child: Obx(() {
              if (controller.isLoadingTeams.value || isLoadingAssignments) {
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
                                'Equipos totales: ${controller.equiposDisponibles.length}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[800],
                                ),
                              ),
                              Text(
                                'Disponibles: ${controller.equiposDisponibles.length - equiposConActividad.length} | Ya asignados: ${equiposConActividad.length}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            // Solo seleccionar equipos que NO tienen la actividad asignada
                            controller.selectTeamsWithoutActivity(
                              equiposConActividad,
                            );
                            // Forzar reconstrucción de la UI
                            setState(() {});
                          },
                          icon: const Icon(Icons.select_all, size: 16),
                          label: const Text('Seleccionar Disponibles'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[600],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            textStyle: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Lista de equipos
                  Expanded(
                    child: Obx(
                      () => ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: controller.equiposDisponibles.length,
                        itemBuilder: (context, index) {
                          final equipo = controller.equiposDisponibles[index];
                          final isSelected = controller.isEquipoSelected(
                            equipo.id!,
                          );
                          final tieneActividad = equiposConActividad.contains(
                            equipo.id,
                          );

                          // Debug prints para diagnosticar problemas
                          if (index == 0) {
                            print('🐛 DEBUG - Primer equipo:');
                            print('   ID: ${equipo.id}');
                            print('   Seleccionado: $isSelected');
                            print('   Tiene actividad: $tieneActividad');
                            print(
                              '   Lista equipos con actividad: $equiposConActividad',
                            );
                          }

                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: tieneActividad
                                  ? Colors.green[50]
                                  : isSelected
                                  ? Colors.blue[50]
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: tieneActividad
                                    ? Colors.green[300]!
                                    : isSelected
                                    ? Colors.blue[400]!
                                    : Colors.grey[200]!,
                                width: tieneActividad || isSelected ? 2 : 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 5,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: tieneActividad
                                    ? Colors.green[100]
                                    : isSelected
                                    ? Colors.blue[100]
                                    : Colors.grey[100],
                                child: Icon(
                                  tieneActividad
                                      ? Icons.check_circle
                                      : isSelected
                                      ? Icons.radio_button_checked
                                      : Icons.group,
                                  color: tieneActividad
                                      ? Colors.green[600]
                                      : isSelected
                                      ? Colors.blue[600]
                                      : Colors.grey[600],
                                ),
                              ),
                              title: Text(
                                equipo.nombre,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: tieneActividad
                                      ? Colors.green[800]
                                      : isSelected
                                      ? Colors.blue[800]
                                      : Colors.black87,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    tieneActividad
                                        ? '✅ Ya tiene esta actividad asignada'
                                        : isSelected
                                        ? '🎯 Seleccionado para asignar'
                                        : '👥 ${equipo.estudiantesIds.length} integrantes',
                                    style: TextStyle(
                                      color: tieneActividad
                                          ? Colors.green[600]
                                          : isSelected
                                          ? Colors.blue[600]
                                          : Colors.grey[600],
                                      fontSize: 12,
                                      fontWeight: tieneActividad || isSelected
                                          ? FontWeight.w500
                                          : FontWeight.normal,
                                    ),
                                  ),
                                  if (tieneActividad) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      'No se puede reasignar',
                                      style: TextStyle(
                                        color: Colors.orange[600],
                                        fontSize: 11,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              trailing: tieneActividad
                                  ? Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.green[100],
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        'ASIGNADA',
                                        style: TextStyle(
                                          color: Colors.green[700],
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    )
                                  : Checkbox(
                                      value: isSelected,
                                      onChanged: (value) {
                                        print(
                                          '🔄 Toggling equipo ${equipo.id}: $isSelected -> ${!isSelected}',
                                        );
                                        controller.toggleEquipoSelection(
                                          equipo.id!,
                                        );
                                        // Forzar rebuild local también
                                        setState(() {});
                                      },
                                      activeColor: Colors.blue[600],
                                      checkColor: Colors.white,
                                      side: MaterialStateBorderSide.resolveWith(
                                        (states) => BorderSide(
                                          color:
                                              states.contains(
                                                MaterialState.selected,
                                              )
                                              ? Colors.blue[600]!
                                              : Colors.grey[400]!,
                                          width: 2,
                                        ),
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      materialTapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                              onTap: tieneActividad
                                  ? null
                                  : () {
                                      controller.toggleEquipoSelection(
                                        equipo.id!,
                                      );
                                      // Forzar rebuild local también
                                      setState(() {});
                                    },
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
      // Botón flotante para asignar
      floatingActionButton: Obx(() {
        // Solo contar equipos seleccionados que NO tienen la actividad asignada
        final selectedValidTeams = controller.equiposSeleccionados
            .where((equipoId) => !equiposConActividad.contains(equipoId))
            .length;

        if (selectedValidTeams == 0) return const SizedBox();

        return FloatingActionButton.extended(
          onPressed: () async {
            // Filtrar solo equipos que no tienen la actividad antes de asignar
            final equiposParaAsignar = controller.equiposSeleccionados
                .where((equipoId) => !equiposConActividad.contains(equipoId))
                .toList();

            if (equiposParaAsignar.isEmpty) {
              Get.snackbar(
                'Sin equipos válidos',
                'Los equipos seleccionados ya tienen esta actividad asignada',
                backgroundColor: Colors.orange[100],
                colorText: Colors.orange[800],
              );
              return;
            }

            // Temporalmente actualizar la lista de seleccionados
            controller.equiposSeleccionados.assignAll(equiposParaAsignar);

            await controller.assignActivityToSelectedTeams(widget.activity);
            await _onActivityAssigned();
          },
          backgroundColor: Colors.blue[600],
          icon: const Icon(Icons.assignment_add, color: Colors.white),
          label: Text(
            'Asignar a $selectedValidTeams equipo${selectedValidTeams != 1 ? 's' : ''}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      }),
    );
  }
}
