import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domain/entities/evaluacion_periodo.dart';
import '../../domain/entities/criterios_evaluacion.dart';
import '../controllers/evaluacion_periodo_controller.dart';
import '../../../activities/domain/entities/activity.dart';
import '../../../categories/domain/usecases/categoria_equipo_usecase.dart';
import '../../../categories/domain/usecases/equipo_actividad_usecase.dart';
import '../../../auth/domain/repositories/usuario_repository.dart';

class EvaluacionDetallePage extends StatefulWidget {
  final EvaluacionPeriodo evaluacion;
  final Activity activity;

  const EvaluacionDetallePage({
    Key? key,
    required this.evaluacion,
    required this.activity,
  }) : super(key: key);

  @override
  State<EvaluacionDetallePage> createState() => _EvaluacionDetallePageState();
}

class _EvaluacionDetallePageState extends State<EvaluacionDetallePage>
    with SingleTickerProviderStateMixin {
  final EvaluacionPeriodoController _evaluacionController =
      Get.find<EvaluacionPeriodoController>();
  final CategoriaEquipoUseCase _equipoUseCase =
      Get.find<CategoriaEquipoUseCase>();
  final EquipoActividadUseCase _equipoActividadUseCase =
      Get.find<EquipoActividadUseCase>();
  final UsuarioRepository _usuarioRepository = Get.find<UsuarioRepository>();

  late TabController _tabController;

  Map<String, String> _usuariosNombres = {};
  Map<String, String> _equiposNombres = {};
  List<Map<String, dynamic>> _equiposConEstudiantes = [];
  bool _cargandoDatos = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // Diferir la carga de datos hasta después del primer frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cargarDatos();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _cargarDatos() async {
    setState(() => _cargandoDatos = true);

    try {
      // ✅ LIMPIAR DATOS ANTERIORES ANTES DE RECARGAR
      _usuariosNombres.clear();
      _equiposNombres.clear();
      _equiposConEstudiantes.clear();

      // Cargar datos de la evaluación
      await _evaluacionController.cargarEvaluacionPorId(widget.evaluacion.id);

      // Obtener equipos asignados a esta actividad
      final asignaciones = await _equipoActividadUseCase
          .getAsignacionesByActividad(widget.activity.id.toString());

      print('🔍 Cargando datos para ${asignaciones.length} asignaciones');

      // Cargar datos de equipos y estudiantes
      for (final asignacion in asignaciones) {
        final equipo = await _equipoUseCase.getEquipoById(asignacion.equipoId.toString());
        if (equipo != null) {
          _equiposNombres[equipo.id.toString()] = equipo.nombre;

          // Cargar nombres de estudiantes
          final estudiantesConNombres = <Map<String, dynamic>>[];
          for (final estudianteId in equipo.estudiantesIds) {
            final usuario = await _usuarioRepository.getUsuarioById(
              estudianteId,
            );
            if (usuario != null) {
              _usuariosNombres[estudianteId.toString()] = usuario.nombre;
              estudiantesConNombres.add({
                'id': estudianteId.toString(),
                'nombre': usuario.nombre,
                'email': usuario.email,
              });
            }
          }

          _equiposConEstudiantes.add({
            'equipo': equipo,
            'estudiantes': estudiantesConNombres,
          });
        }
      }

      print('✅ Datos cargados: ${_equiposConEstudiantes.length} equipos');
    } catch (e) {
      print('Error cargando datos: $e');
    } finally {
      setState(() => _cargandoDatos = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Detalle de Evaluación', style: TextStyle(fontSize: 18)),
            Text(
              widget.evaluacion.titulo,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
            ),
          ],
        ),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: [
            Tab(text: 'Resumen', icon: Icon(Icons.dashboard, size: 20)),
            Tab(text: 'Por Equipo', icon: Icon(Icons.groups, size: 20)),
            Tab(text: 'Por Estudiante', icon: Icon(Icons.person, size: 20)),
          ],
        ),
        actions: [
          IconButton(icon: Icon(Icons.refresh), onPressed: _cargarDatos),
        ],
      ),
      body: _cargandoDatos
          ? Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildResumenTab(),
                _buildPorEquipoTab(),
                _buildPorEstudianteTab(),
              ],
            ),
    );
  }

  Widget _buildResumenTab() {
    // TODO: Implementar estadísticas en el controller
    final estadisticas = <String, dynamic>{}; // Placeholder

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildEstadoEvaluacion(),
            SizedBox(height: 20),
            _buildEstadisticasGenerales(estadisticas),
            SizedBox(height: 20),
            _buildProgresoGeneral(estadisticas),
            SizedBox(height: 20),
            _buildAccionesRapidas(),
          ],
        ),
      );
  }

  Widget _buildEstadoEvaluacion() {
    final evaluacion = widget.evaluacion;
    Color statusColor = _getStatusColor(evaluacion.estado);
    IconData statusIcon = _getStatusIcon(evaluacion.estado);

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(statusIcon, color: statusColor),
              SizedBox(width: 8),
              Text(
                _getStatusText(evaluacion.estado),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: statusColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          if (evaluacion.descripcion != null)
            Text(
              evaluacion.descripcion!,
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  'Creado',
                  _formatDate(evaluacion.fechaCreacion),
                  Icons.calendar_today,
                ),
              ),
              if (evaluacion.fechaFin != null)
                Expanded(
                  child: _buildInfoItem(
                    'Finaliza',
                    _formatDate(evaluacion.fechaFin!),
                    Icons.event_busy,
                  ),
                ),
            ],
          ),
          if (evaluacion.estado == EstadoEvaluacionPeriodo.activo) ...[
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.access_time, color: Colors.orange, size: 16),
                  SizedBox(width: 8),
                  Text(
                    'Evaluación activa',
                    style: TextStyle(
                      color: Colors.orange[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            Text(
              value,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEstadisticasGenerales(Map<String, dynamic> stats) {
    final total = stats['total'] ?? 0;
    final completadas = stats['completadas'] ?? 0;
    final pendientes = stats['pendientes'] ?? 0;
    final porcentaje = stats['porcentajeCompletado']?.toDouble() ?? 0.0;

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Estadísticas Generales',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.blue[700],
            ),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total',
                  total.toString(),
                  Colors.blue,
                  Icons.assignment,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Completadas',
                  completadas.toString(),
                  Colors.green,
                  Icons.check_circle,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Pendientes',
                  pendientes.toString(),
                  Colors.orange,
                  Icons.pending,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            'Progreso: ${porcentaje.toStringAsFixed(1)}%',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 8),
          LinearProgressIndicator(
            value: porcentaje / 100,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(
              porcentaje >= 80
                  ? Colors.green
                  : porcentaje >= 50
                  ? Colors.orange
                  : Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildProgresoGeneral(Map<String, dynamic> stats) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Criterios de Evaluación',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.green[700],
            ),
          ),
          SizedBox(height: 12),
          ...CriterioEvaluacion.values
              .map((criterio) => _buildCriterioItem(criterio))
              .toList(),
        ],
      ),
    );
  }

  Widget _buildCriterioItem(CriterioEvaluacion criterio) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: Colors.green[600],
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  criterio.nombre,
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  criterio.descripcion,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccionesRapidas() {
    final evaluacion = widget.evaluacion;

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Acciones',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 12),
          Row(
            children: [
              if (evaluacion.estado == EstadoEvaluacionPeriodo.pendiente)
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _iniciarEvaluacion(),
                    icon: Icon(Icons.play_arrow),
                    label: Text('Iniciar Evaluación'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              if (evaluacion.estado == EstadoEvaluacionPeriodo.activo) ...[
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _finalizarEvaluacion(),
                    icon: Icon(Icons.stop),
                    label: Text('Finalizar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _cargarDatos(),
                    icon: Icon(Icons.refresh),
                    label: Text('Actualizar'),
                  ),
                ),
              ],
              if (evaluacion.estado == EstadoEvaluacionPeriodo.finalizado)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // TODO: Exportar resultados
                      Get.snackbar(
                        'Próximamente',
                        'Función de exportar en desarrollo',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    },
                    icon: Icon(Icons.download),
                    label: Text('Exportar Resultados'),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPorEquipoTab() {
    // TODO: Implementar promedios por equipos en el controller
    final promediosEquipos = <String, double>{}; // Placeholder

    return ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: _equiposConEstudiantes.length,
        itemBuilder: (context, index) {
          final equipoData = _equiposConEstudiantes[index];
          final equipo = equipoData['equipo'];
          final estudiantes =
              equipoData['estudiantes'] as List<Map<String, dynamic>>;
          final promedioEquipo = promediosEquipos[equipo.id.toString()] ?? 0.0;

          return _buildEquipoCard(equipo, estudiantes, promedioEquipo);
        },
      );
    });
  }

  Widget _buildEquipoCard(
    dynamic equipo,
    List<Map<String, dynamic>> estudiantes,
    double promedio,
  ) {
    final color = _getColorPorPromedio(promedio);

    return Card(
      margin: EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: color,
          child: Text(
            promedio.toStringAsFixed(1),
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ),
        title: Text(
          equipo.nombre,
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${estudiantes.length} estudiantes • Promedio: ${_obtenerNivelPorPromedio(promedio)}',
        ),
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: estudiantes.map((estudiante) {
                final promedioEstudiante = 0.0; // TODO: Implementar promedio por estudiante

                return _buildEstudianteItem(
                  estudiante['nombre'],
                  estudiante['email'],
                  promedioEstudiante,
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEstudianteItem(String nombre, String email, double promedio) {
    final color = _getColorPorPromedio(promedio);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: color.withOpacity(0.2),
            child: Text(
              promedio.toStringAsFixed(1),
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(nombre, style: TextStyle(fontWeight: FontWeight.w500)),
                Text(
                  email,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _obtenerNivelPorPromedio(promedio),
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPorEstudianteTab() {
    return Obx(() {
      // TODO: Implementar promedios por estudiantes en el controller
      final promediosEstudiantes = <String, double>{}; // Placeholder
      final estudiantesOrdenados = promediosEstudiantes.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      return ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: estudiantesOrdenados.length,
        itemBuilder: (context, index) {
          final entry = estudiantesOrdenados[index];
          final estudianteId = entry.key;
          final promedio = entry.value;
          final nombre =
              _usuariosNombres[estudianteId] ?? 'Usuario desconocido';

          return _buildEstudianteRankingCard(
            index + 1,
            nombre,
            promedio,
            estudianteId,
          );
        },
      );
    });
  }

  Widget _buildEstudianteRankingCard(
    int posicion,
    String nombre,
    double promedio,
    String estudianteId,
  ) {
    final color = _getColorPorPromedio(promedio);

    return Card(
      margin: EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: posicion <= 3
                ? (posicion == 1
                      ? Colors.amber
                      : posicion == 2
                      ? Colors.grey[400]
                      : Colors.brown[300])
                : color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              posicion <= 3 ? '#$posicion' : promedio.toStringAsFixed(1),
              style: TextStyle(
                fontSize: posicion <= 3 ? 12 : 14,
                fontWeight: FontWeight.w600,
                color: posicion <= 3 ? Colors.white : color,
              ),
            ),
          ),
        ),
        title: Text(nombre, style: TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text('Promedio general'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              promedio.toStringAsFixed(2),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
            Text(
              _obtenerNivelPorPromedio(promedio),
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
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

  Color _getColorPorPromedio(double promedio) {
    if (promedio >= 4.5) return Colors.green;
    if (promedio >= 3.5) return Colors.blue;
    if (promedio >= 2.5) return Colors.orange;
    return Colors.red;
  }

  String _obtenerNivelPorPromedio(double promedio) {
    if (promedio >= 4.5) return 'Excelente';
    if (promedio >= 3.5) return 'Bueno';
    if (promedio >= 2.5) return 'Adecuado';
    return 'Necesita Mejorar';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _iniciarEvaluacion() async {
    await _evaluacionController.activarEvaluacion(widget.evaluacion.id);
    await _cargarDatos();
  }

  Future<void> _finalizarEvaluacion() async {
    await _evaluacionController.finalizarEvaluacion(widget.evaluacion.id);
    await _cargarDatos();
  }
}
