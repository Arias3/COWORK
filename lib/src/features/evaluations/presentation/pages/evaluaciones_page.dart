import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domain/entities/evaluacion_periodo.dart';
import '../controllers/evaluacion_periodo_controller.dart';
import '../../../activities/domain/entities/activity.dart';
import 'crear_evaluacion_page.dart';
import 'evaluacion_detalle_simple_page.dart';

class EvaluacionesPage extends StatefulWidget {
  final Activity activity;

  const EvaluacionesPage({Key? key, required this.activity}) : super(key: key);

  @override
  State<EvaluacionesPage> createState() => _EvaluacionesPageState();
}

class _EvaluacionesPageState extends State<EvaluacionesPage> {
  late final EvaluacionPeriodoController _evaluacionController;

  // Variables para selección múltiple
  bool _modoSeleccion = false;
  Set<String> _evaluacionesSeleccionadas = <String>{};

  @override
  void initState() {
    super.initState();
    _evaluacionController = Get.find<EvaluacionPeriodoController>();
    _cargarEvaluaciones();
  }

  Future<void> _cargarEvaluaciones() async {
    await _evaluacionController.cargarEvaluacionesPorActividad(
      widget.activity.id.toString(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _modoSeleccion ? _buildAppBarSeleccion() : _buildAppBarNormal(),
      body: Obx(() {
        if (_evaluacionController.isLoading) {
          return Center(child: CircularProgressIndicator());
        }

        final evaluaciones =
            _evaluacionController.evaluacionesPorActividad[widget.activity.id
                .toString()] ??
            [];

        return Stack(
          children: [
            RefreshIndicator(
              onRefresh: _cargarEvaluaciones,
              child: evaluaciones.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: EdgeInsets.all(16),
                      itemCount: evaluaciones.length,
                      itemBuilder: (context, index) {
                        final evaluacion = evaluaciones[index];
                        return _buildEvaluacionCard(evaluacion);
                      },
                    ),
            ),
            // Botón flotante de eliminar
            if (_modoSeleccion && _evaluacionesSeleccionadas.isNotEmpty)
              _buildBotonEliminarFlotante(),
          ],
        );
      }),
      floatingActionButton: _modoSeleccion
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _crearNuevaEvaluacion(),
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
              icon: Icon(Icons.add),
              label: Text('Nueva Evaluación'),
            ),
    );
  }

  AppBar _buildAppBarNormal() {
    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Evaluaciones', style: TextStyle(fontSize: 18)),
          Text(
            widget.activity.nombre,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
          ),
        ],
      ),
      backgroundColor: Colors.deepPurple,
      foregroundColor: Colors.white,
      actions: [
        IconButton(
          icon: Icon(Icons.select_all),
          onPressed: () {
            setState(() {
              _modoSeleccion = true;
            });
          },
        ),
        IconButton(icon: Icon(Icons.refresh), onPressed: _cargarEvaluaciones),
      ],
    );
  }

  AppBar _buildAppBarSeleccion() {
    return AppBar(
      title: Text('${_evaluacionesSeleccionadas.length} seleccionadas'),
      backgroundColor: Colors.red[700],
      foregroundColor: Colors.white,
      leading: IconButton(
        icon: Icon(Icons.close),
        onPressed: () {
          setState(() {
            _modoSeleccion = false;
            _evaluacionesSeleccionadas.clear();
          });
        },
      ),
      actions: [
        TextButton(
          onPressed: _seleccionarTodas,
          child: Text(
            'Seleccionar todas',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildBotonEliminarFlotante() {
    return Positioned(
      bottom: 20,
      left: 20,
      child: FloatingActionButton.extended(
        onPressed: _confirmarEliminarSeleccionadas,
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        icon: Icon(Icons.delete),
        label: Text('Eliminar (${_evaluacionesSeleccionadas.length})'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assessment_outlined, size: 80, color: Colors.grey[400]),
            SizedBox(height: 16),
            Text(
              'No hay evaluaciones creadas',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Crea la primera evaluación para que los estudiantes puedan evaluarse entre compañeros de equipo',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _crearNuevaEvaluacion(),
              icon: Icon(Icons.add),
              label: Text('Crear Evaluación'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEvaluacionCard(EvaluacionPeriodo evaluacion) {
    Color statusColor = _getStatusColor(evaluacion.estado);
    IconData statusIcon = _getStatusIcon(evaluacion.estado);
    bool isSelected = _evaluacionesSeleccionadas.contains(evaluacion.id);

    return Card(
      elevation: 2,
      margin: EdgeInsets.only(bottom: 16),
      color: isSelected ? Colors.red[50] : null,
      child: InkWell(
        onTap: () {
          if (_modoSeleccion) {
            _toggleSeleccion(evaluacion.id);
          } else {
            _abrirDetalleEvaluacion(evaluacion);
          }
        },
        onLongPress: () {
          if (!_modoSeleccion) {
            setState(() {
              _modoSeleccion = true;
              _evaluacionesSeleccionadas.add(evaluacion.id);
            });
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      evaluacion.titulo,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      if (_modoSeleccion)
                        Checkbox(
                          value: isSelected,
                          onChanged: (bool? value) {
                            _toggleSeleccion(evaluacion.id);
                          },
                          activeColor: Colors.red,
                        ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          border: Border.all(color: statusColor),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(statusIcon, size: 14, color: statusColor),
                            SizedBox(width: 4),
                            Text(
                              _getStatusText(evaluacion.estado),
                              style: TextStyle(
                                color: statusColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (evaluacion.descripcion != null) ...[
                SizedBox(height: 8),
                Text(
                  evaluacion.descripcion!,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
              SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                  SizedBox(width: 4),
                  Text(
                    'Creado: ${_formatDate(evaluacion.fechaCreacion)}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
              if (evaluacion.fechaFin != null) ...[
                SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.event_busy, size: 14, color: Colors.grey[600]),
                    SizedBox(width: 4),
                    Text(
                      'Finaliza: ${_formatDate(evaluacion.fechaFin!)}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
              if (!_modoSeleccion) ...[
                SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (evaluacion.estado == EstadoEvaluacionPeriodo.pendiente)
                      TextButton.icon(
                        onPressed: () => _iniciarEvaluacion(evaluacion.id),
                        icon: Icon(Icons.play_arrow, size: 16),
                        label: Text('Iniciar'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.green[700],
                        ),
                      ),
                    if (evaluacion.estado == EstadoEvaluacionPeriodo.activo)
                      TextButton.icon(
                        onPressed: () => _finalizarEvaluacion(evaluacion.id),
                        icon: Icon(Icons.stop, size: 16),
                        label: Text('Finalizar'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red[700],
                        ),
                      ),
                    SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: () => _abrirDetalleEvaluacion(evaluacion),
                      icon: Icon(Icons.visibility, size: 16),
                      label: Text('Ver Detalle'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.deepPurple,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _toggleSeleccion(String evaluacionId) {
    setState(() {
      if (_evaluacionesSeleccionadas.contains(evaluacionId)) {
        _evaluacionesSeleccionadas.remove(evaluacionId);
        // Si no hay selecciones, salir del modo selección
        if (_evaluacionesSeleccionadas.isEmpty) {
          _modoSeleccion = false;
        }
      } else {
        _evaluacionesSeleccionadas.add(evaluacionId);
      }
    });
  }

  void _seleccionarTodas() {
    setState(() {
      final evaluaciones =
          _evaluacionController.evaluacionesPorActividad[widget.activity.id
              .toString()] ??
          [];
      _evaluacionesSeleccionadas.addAll(evaluaciones.map((e) => e.id));
    });
  }

  Future<void> _confirmarEliminarSeleccionadas() async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        title: Text('Eliminar Evaluaciones'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '¿Estás seguro de que deseas eliminar ${_evaluacionesSeleccionadas.length} evaluación(es)?',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '⚠️ Esta acción eliminará permanentemente:',
                    style: TextStyle(
                      color: Colors.red[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text('• Las evaluaciones seleccionadas y su configuración'),
                  Text('• Todas las evaluaciones individuales asociadas'),
                  Text('• Los resultados y estadísticas'),
                  SizedBox(height: 8),
                  Text(
                    'Esta acción no se puede deshacer.',
                    style: TextStyle(
                      color: Colors.red[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('Eliminar'),
          ),
        ],
      ),
    );

    if (result == true) {
      await _eliminarEvaluacionesSeleccionadas();
    }
  }

  Future<void> _eliminarEvaluacionesSeleccionadas() async {
    for (final evaluacionId in _evaluacionesSeleccionadas) {
      try {
        await _evaluacionController.eliminarEvaluacion(evaluacionId);
      } catch (e) {
        print('Error eliminando evaluación $evaluacionId: $e');
      }
    }

    setState(() {
      _modoSeleccion = false;
      _evaluacionesSeleccionadas.clear();
    });

    Get.snackbar(
      'Éxito',
      'Evaluaciones eliminadas correctamente',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  Color _getStatusColor(EstadoEvaluacionPeriodo estado) {
    switch (estado) {
      case EstadoEvaluacionPeriodo.pendiente:
        return Colors.orange;
      case EstadoEvaluacionPeriodo.activo:
        return Colors.green;
      case EstadoEvaluacionPeriodo.finalizado:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(EstadoEvaluacionPeriodo estado) {
    switch (estado) {
      case EstadoEvaluacionPeriodo.pendiente:
        return Icons.pending;
      case EstadoEvaluacionPeriodo.activo:
        return Icons.play_circle;
      case EstadoEvaluacionPeriodo.finalizado:
        return Icons.check_circle;
    }
  }

  String _getStatusText(EstadoEvaluacionPeriodo estado) {
    switch (estado) {
      case EstadoEvaluacionPeriodo.pendiente:
        return 'Pendiente';
      case EstadoEvaluacionPeriodo.activo:
        return 'Activa';
      case EstadoEvaluacionPeriodo.finalizado:
        return 'Finalizada';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _crearNuevaEvaluacion() async {
    final result = await Get.to<bool>(
      () => CrearEvaluacionPage(activity: widget.activity),
    );

    if (result == true) {
      await _cargarEvaluaciones();
    }
  }

  void _abrirDetalleEvaluacion(EvaluacionPeriodo evaluacion) {
    Get.to(
      () => EvaluacionDetalleSimplePage(
        evaluacion: evaluacion,
        activity: widget.activity,
      ),
    );
  }

  Future<void> _iniciarEvaluacion(String periodoId) async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        title: Text('Iniciar Evaluación'),
        content: Text(
          '¿Estás seguro de que deseas iniciar esta evaluación? Los estudiantes podrán comenzar a evaluarse inmediatamente.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: Text('Iniciar'),
          ),
        ],
      ),
    );

    if (result == true) {
      await _evaluacionController.activarEvaluacion(periodoId);
      await _cargarEvaluaciones();
    }
  }

  Future<void> _finalizarEvaluacion(String periodoId) async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        title: Text('Finalizar Evaluación'),
        content: Text(
          '¿Estás seguro de que deseas finalizar esta evaluación? Los estudiantes ya no podrán evaluar y se cerrarán todas las evaluaciones pendientes.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('Finalizar'),
          ),
        ],
      ),
    );

    if (result == true) {
      await _evaluacionController.finalizarEvaluacion(periodoId);
      await _cargarEvaluaciones();
    }
  }
}
