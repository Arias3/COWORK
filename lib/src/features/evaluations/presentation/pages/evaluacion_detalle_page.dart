import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domain/entities/evaluacion_periodo.dart';
import '../../domain/entities/criterios_evaluacion.dart';
import '../controllers/evaluacion_periodo_controller.dart';
import '../controllers/evaluacion_detalle_controller_temp.dart';
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
  final EvaluacionDetalleControllerTemp _detalleController =
      Get.find<EvaluacionDetalleControllerTemp>();
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
    _tabController = TabController(length: 2, vsync: this);
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

      // Cargar estadísticas usando el controlador temporal
      await _detalleController.cargarEstadisticasCompletas(
        widget.evaluacion.id,
      );

      // Obtener todos los estudiantes y equipos que aparecen en las estadísticas
      final promediosEstudiantes = _detalleController.promediosEstudiantes;
      final promediosEquipos = _detalleController.promediosEquipos;

      print('📊 DEPURACIÓN: Estadísticas del controlador temporal:');
      print('   - Estudiantes con promedio: ${promediosEstudiantes.length}');
      print('   - Equipos con promedio: ${promediosEquipos.length}');
      print('   - Estudiantes IDs: ${promediosEstudiantes.keys.toList()}');
      print('   - Equipos IDs: ${promediosEquipos.keys.toList()}');

      print(
        '📊 Cargando nombres para ${promediosEstudiantes.length} estudiantes y ${promediosEquipos.length} equipos',
      );

      // Cargar nombres de todos los estudiantes que aparecen en las evaluaciones
      for (final estudianteId in promediosEstudiantes.keys) {
        if (!_usuariosNombres.containsKey(estudianteId)) {
          try {
            final usuario = await _usuarioRepository.getUsuarioById(
              int.parse(estudianteId),
            );
            if (usuario != null) {
              _usuariosNombres[estudianteId] = usuario.nombre;
              print('✅ Usuario cargado: ${usuario.nombre} (ID: $estudianteId)');
            } else {
              print('⚠️ Usuario no encontrado para ID: $estudianteId');
              _usuariosNombres[estudianteId] = 'Usuario no encontrado';
            }
          } catch (e) {
            print('❌ Error cargando usuario $estudianteId: $e');
            _usuariosNombres[estudianteId] = 'Error al cargar usuario';
          }
        }
      }

      // Cargar nombres de todos los equipos que aparecen en las evaluaciones
      for (final equipoId in promediosEquipos.keys) {
        if (!_equiposNombres.containsKey(equipoId)) {
          try {
            final equipo = await _equipoUseCase.getEquipoById(equipoId);
            if (equipo != null) {
              _equiposNombres[equipoId] = equipo.nombre;
              print('✅ Equipo cargado: ${equipo.nombre} (ID: $equipoId)');
            } else {
              print('⚠️ Equipo no encontrado para ID: $equipoId');
              _equiposNombres[equipoId] = 'Equipo no encontrado';
            }
          } catch (e) {
            print('❌ Error cargando equipo $equipoId: $e');
            _equiposNombres[equipoId] = 'Error al cargar equipo';
          }
        }
      }

      // Obtener equipos asignados a esta actividad para la vista detallada
      final asignaciones = await _equipoActividadUseCase
          .getAsignacionesByActividad(widget.activity.id!.toString());

      print(
        '🔍 Cargando datos detallados para ${asignaciones.length} asignaciones',
      );

      // Cargar datos detallados de equipos y estudiantes (solo los asignados a esta actividad)
      for (final asignacion in asignaciones) {
        final equipo = await _equipoUseCase.getEquipoById(
          asignacion.equipoId.toString(),
        );
        if (equipo != null) {
          // Asegurar que el nombre del equipo esté cargado
          _equiposNombres[equipo.id.toString()] = equipo.nombre;

          // Cargar datos detallados de estudiantes
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

      print(
        '✅ Datos cargados: ${_equiposConEstudiantes.length} equipos detallados, ${_usuariosNombres.length} usuarios, ${_equiposNombres.length} equipos',
      );
    } catch (e) {
      print('❌ Error cargando datos: $e');
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
            Tab(
              text: 'Equipos y Evaluadores',
              icon: Icon(Icons.groups, size: 20),
            ),
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
              children: [_buildResumenTab(), _buildEquiposYEvaluadoresTab()],
            ),
    );
  }

  Widget _buildResumenTab() {
    return Obx(() {
      final estadisticas = _detalleController.estadisticas;

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
    });
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
          // TODO: Implementar cálculo de tiempo restante
          /*
          if (evaluacion.horasRestantes != null && evaluacion.estaActiva) ...[
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
                    'Tiempo restante: X horas',
                    style: TextStyle(
                      color: Colors.orange[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
          */
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

  Widget _buildEquiposYEvaluadoresTab() {
    return Obx(() {
      final promediosEquipos = _detalleController.promediosEquipos;

      // Si no hay equipos con evaluaciones, mostrar mensaje
      if (promediosEquipos.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.groups_outlined, size: 64, color: Colors.grey[400]),
              SizedBox(height: 16),
              Text(
                'No hay equipos con evaluaciones',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Las evaluaciones aparecerán aquí una vez que se completen',
                style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }

      // Crear lista de equipos ordenados por promedio
      final equiposOrdenados = promediosEquipos.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      return ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: equiposOrdenados.length,
        itemBuilder: (context, index) {
          final entry = equiposOrdenados[index];
          final equipoId = entry.key;
          final promedio = entry.value;
          final nombreEquipo = _equiposNombres[equipoId] ?? 'Equipo $equipoId';

          // Buscar datos detallados del equipo si están disponibles
          Map<String, dynamic>? equipoDetallado;
          try {
            equipoDetallado = _equiposConEstudiantes.firstWhere(
              (e) => e['equipo'].id.toString() == equipoId,
            );
          } catch (e) {
            // No se encontró el equipo detallado
            equipoDetallado = null;
          }

          if (equipoDetallado != null) {
            // Mostrar equipo con datos detallados
            return _buildEquipoCardUnificado(
              equipoDetallado['equipo'],
              equipoDetallado['estudiantes'] as List<Map<String, dynamic>>,
              promedio,
              equipoId,
            );
          } else {
            // Mostrar equipo básico con estudiantes evaluados
            return _buildEquipoBasicoCardUnificado(
              equipoId,
              nombreEquipo,
              promedio,
            );
          }
        },
      );
    });
  }

  Widget _buildEquipoBasicoCardUnificado(
    String equipoId,
    String nombreEquipo,
    double promedio,
  ) {
    final color = _getColorPorPromedio(promedio);
    final promediosEstudiantes = _detalleController.promediosEstudiantes;

    // Obtener estudiantes que pertenecen a este equipo y tienen evaluaciones
    final estudiantesEvaluados = <MapEntry<String, double>>[];
    for (final entry in promediosEstudiantes.entries) {
      final estudianteId = entry.key;
      final promedioEstudiante = entry.value;

      // Verificar si este estudiante evaluó a miembros de este equipo
      // Para simplificar, mostraremos todos los estudiantes con evaluaciones
      estudiantesEvaluados.add(MapEntry(estudianteId, promedioEstudiante));
    }

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
          nombreEquipo,
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text('Promedio: ${_obtenerNivelPorPromedio(promedio)}'),
        trailing: Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                promedio.toStringAsFixed(2),
                style: TextStyle(
                  fontSize: 14,
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: 4),
              Icon(Icons.expand_more, size: 16, color: Colors.grey),
            ],
          ),
        ),
        children: [
          Container(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.people, color: Colors.blue[600], size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Estudiantes Evaluados (${estudiantesEvaluados.length})',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.blue[700],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                if (estudiantesEvaluados.isEmpty)
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.grey[600]),
                        SizedBox(width: 8),
                        Text(
                          'No hay estudiantes evaluados en este equipo',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  )
                else
                  ...estudiantesEvaluados.map((entry) {
                    final estudianteId = entry.key;
                    final promedioEstudiante = entry.value;
                    final nombreEstudiante =
                        _usuariosNombres[estudianteId] ??
                        'Usuario $estudianteId';

                    return _buildEstudianteItemUnificado(
                      nombreEstudiante,
                      promedioEstudiante,
                      estudianteId,
                    );
                  }).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEquipoCardUnificado(
    dynamic equipo,
    List<Map<String, dynamic>> estudiantes,
    double promedio,
    String equipoId,
  ) {
    final color = _getColorPorPromedio(promedio);
    final promediosEstudiantes = _detalleController.promediosEstudiantes;

    // Separar estudiantes del equipo que han sido evaluados vs todos los evaluados
    final estudiantesDelEquipo = <Map<String, dynamic>>[];
    final otrosEvaluados = <MapEntry<String, double>>[];

    // Agregar estudiantes del equipo con sus evaluaciones
    for (final estudiante in estudiantes) {
      final estudianteId = estudiante['id'];
      final promedioEstudiante = promediosEstudiantes[estudianteId] ?? 0.0;

      estudiantesDelEquipo.add({
        ...estudiante,
        'promedio': promedioEstudiante,
        'tieneEvaluacion': promediosEstudiantes.containsKey(estudianteId),
      });
    }

    // Agregar otros estudiantes evaluados que no están en este equipo
    for (final entry in promediosEstudiantes.entries) {
      final estudianteId = entry.key;
      final yaEstaEnEquipo = estudiantes.any((e) => e['id'] == estudianteId);

      if (!yaEstaEnEquipo) {
        otrosEvaluados.add(MapEntry(estudianteId, entry.value));
      }
    }

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
          '${estudiantes.length} miembros • Promedio: ${_obtenerNivelPorPromedio(promedio)}',
        ),
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sección: Miembros del equipo
                Row(
                  children: [
                    Icon(Icons.group, color: Colors.green[600], size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Miembros del Equipo (${estudiantesDelEquipo.length})',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.green[700],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                ...estudiantesDelEquipo.map((estudiante) {
                  return _buildEstudianteItemUnificado(
                    estudiante['nombre'],
                    estudiante['promedio'],
                    estudiante['id'],
                    esMiembroEquipo: true,
                    tieneEvaluacion: estudiante['tieneEvaluacion'],
                    email: estudiante['email'],
                  );
                }).toList(),

                // Sección: Otros evaluados (si hay)
                if (otrosEvaluados.isNotEmpty) ...[
                  SizedBox(height: 16),
                  Divider(),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.people_outline,
                        color: Colors.blue[600],
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Otros Evaluados (${otrosEvaluados.length})',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.blue[700],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  ...otrosEvaluados.map((entry) {
                    final estudianteId = entry.key;
                    final promedioEstudiante = entry.value;
                    final nombreEstudiante =
                        _usuariosNombres[estudianteId] ??
                        'Usuario $estudianteId';

                    return _buildEstudianteItemUnificado(
                      nombreEstudiante,
                      promedioEstudiante,
                      estudianteId,
                      esMiembroEquipo: false,
                      tieneEvaluacion: true,
                    );
                  }).toList(),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEstudianteItemUnificado(
    String nombre,
    double promedio,
    String estudianteId, {
    bool esMiembroEquipo = false,
    bool tieneEvaluacion = true,
    String? email,
  }) {
    final color = tieneEvaluacion
        ? _getColorPorPromedio(promedio)
        : Colors.grey;

    return Container(
      margin: EdgeInsets.symmetric(vertical: 4),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: esMiembroEquipo
            ? (tieneEvaluacion ? Colors.green[50] : Colors.orange[50])
            : Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: esMiembroEquipo
              ? (tieneEvaluacion ? Colors.green[200]! : Colors.orange[200]!)
              : Colors.blue[200]!,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Avatar con promedio o indicador
          CircleAvatar(
            radius: 18,
            backgroundColor: tieneEvaluacion
                ? color.withOpacity(0.2)
                : Colors.grey[300],
            child: tieneEvaluacion
                ? Text(
                    promedio.toStringAsFixed(1),
                    style: TextStyle(
                      fontSize: 12,
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                  )
                : Icon(Icons.pending, size: 16, color: Colors.grey[600]),
          ),
          SizedBox(width: 12),

          // Información del estudiante
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Icono indicativo del tipo
                    Icon(
                      esMiembroEquipo
                          ? (tieneEvaluacion
                                ? Icons.group
                                : Icons.group_outlined)
                          : Icons.person,
                      size: 16,
                      color: esMiembroEquipo
                          ? (tieneEvaluacion
                                ? Colors.green[600]
                                : Colors.orange[600])
                          : Colors.blue[600],
                    ),
                    SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        nombre,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2),
                Text(
                  esMiembroEquipo
                      ? (tieneEvaluacion
                            ? 'Miembro del equipo'
                            : 'Miembro (sin evaluar)')
                      : 'Evaluador externo',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
                if (email != null && email.isNotEmpty) ...[
                  SizedBox(height: 2),
                  Text(
                    email,
                    style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                  ),
                ],
              ],
            ),
          ),

          // Badge con nivel o estado
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: tieneEvaluacion
                  ? color.withOpacity(0.1)
                  : Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: tieneEvaluacion
                    ? color.withOpacity(0.3)
                    : Colors.grey[400]!,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (tieneEvaluacion) ...[
                  Text(
                    promedio.toStringAsFixed(2),
                    style: TextStyle(
                      fontSize: 12,
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    _obtenerNivelPorPromedio(promedio),
                    style: TextStyle(
                      fontSize: 10,
                      color: color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ] else ...[
                  Text(
                    'Sin evaluar',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
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
    await _evaluacionController.iniciarEvaluacionTemp(widget.evaluacion.id);
    await _cargarDatos();
  }

  Future<void> _finalizarEvaluacion() async {
    await _evaluacionController.finalizarEvaluacionTemp(widget.evaluacion.id);
    await _cargarDatos();
  }
}
