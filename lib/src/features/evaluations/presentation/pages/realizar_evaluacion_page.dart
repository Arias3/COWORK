import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domain/entities/criterios_evaluacion.dart';
import '../controllers/evaluacion_individual_controller.dart';
import '../../../activities/domain/entities/activity.dart';
import '../../../auth/presentation/controllers/roble_auth_login_controller.dart';

class RealizarEvaluacionPage extends StatefulWidget {
  final Activity actividad;
  final List<Map<String, dynamic>> miembrosEquipo;
  final String evaluacionPeriodoId;
  final String equipoId;

  const RealizarEvaluacionPage({
    Key? key,
    required this.actividad,
    required this.miembrosEquipo,
    required this.evaluacionPeriodoId,
    required this.equipoId,
  }) : super(key: key);

  @override
  _RealizarEvaluacionPageState createState() => _RealizarEvaluacionPageState();
}

class _RealizarEvaluacionPageState extends State<RealizarEvaluacionPage> {
  final EvaluacionIndividualController _evaluacionController =
      Get.find<EvaluacionIndividualController>();

  // Mapa para almacenar las calificaciones por usuario y criterio
  final Map<String, Map<String, double>> _calificaciones = {};
  final Map<String, String> _comentarios = {};
  final Map<String, TextEditingController> _comentarioControllers = {};
  final Map<String, bool> _evaluacionesEnviadas = {}; // Track sent evaluations
  final Map<String, bool> _enviandoEvaluacion =
      {}; // Track loading state per student

  bool _isLoading = false;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _inicializarPagina();
  }

  Future<void> _inicializarPagina() async {
    setState(() {
      _isLoading = true;
    });

    await _obtenerUsuarioActual();
    _inicializarCalificaciones();
    await _cargarEvaluacionesExistentes();

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _obtenerUsuarioActual() async {
    // Obtener el ID del usuario actual desde RobleAuthLoginController
    try {
      final authController = Get.find<RobleAuthLoginController>();
      final currentUser = authController.currentUser.value;

      if (currentUser != null && currentUser.id != null) {
        _currentUserId = currentUser.id.toString();
        print(
          '✅ Usuario actual obtenido: ${currentUser.nombre} (ID: $_currentUserId)',
        );
      } else {
        print('❌ No se encontró usuario autenticado');
        _currentUserId = null;
      }
    } catch (e) {
      print('❌ Error obteniendo usuario actual: $e');
      _currentUserId = null;
    }
  }

  void _inicializarCalificaciones() {
    for (var miembro in widget.miembrosEquipo) {
      final miembroId = miembro['id'].toString();
      _calificaciones[miembroId] = {};
      _comentarios[miembroId] = '';
      _comentarioControllers[miembroId] = TextEditingController();
      _evaluacionesEnviadas[miembroId] = false; // Initialize sent status
      _enviandoEvaluacion[miembroId] = false; // Initialize loading status

      // Inicializar cada criterio con una calificación por defecto
      for (var criterio in CriterioEvaluacion.values) {
        _calificaciones[miembroId]![criterio.name] =
            3.0; // Valor por defecto: Adecuado
      }
    }
  }

  Future<void> _cargarEvaluacionesExistentes() async {
    if (_currentUserId == null) return;

    print('🔍 [CARGAR-EVAL] Cargando evaluaciones existentes...');

    for (var miembro in widget.miembrosEquipo) {
      final miembroId = miembro['id'].toString();

      // No cargar para el usuario actual (no puede evaluarse a sí mismo)
      if (miembroId == _currentUserId) continue;

      try {
        print(
          '🔍 [CARGAR-EVAL] Verificando evaluación para miembro: $miembroId',
        );

        // Cargar evaluación específica para este miembro
        await _evaluacionController.cargarEvaluacionEspecifica(
          widget.evaluacionPeriodoId,
          _currentUserId!,
          miembroId,
        );

        // Verificar si existe una evaluación
        final evaluacionExistente = _evaluacionController.evaluacionActual;

        if (evaluacionExistente != null && evaluacionExistente.completada) {
          print(
            '✅ [CARGAR-EVAL] Evaluación existente encontrada y completada para: $miembroId',
          );

          // Marcar como enviada
          setState(() {
            _evaluacionesEnviadas[miembroId] = true;
          });

          // Cargar las calificaciones existentes desde el mapa de calificaciones original
          final calificacionesExistentes = evaluacionExistente.calificaciones;
          print(
            '🔍 [CARGAR-EVAL] Calificaciones existentes raw: $calificacionesExistentes',
          );
          print(
            '🔍 [CARGAR-EVAL] Tipo: ${calificacionesExistentes.runtimeType}',
          );
          print('🔍 [CARGAR-EVAL] Tamaño: ${calificacionesExistentes.length}');

          calificacionesExistentes.forEach((criterioKey, calificacion) {
            print(
              '🔄 [CARGAR-EVAL] Cargando calificación: $criterioKey = $calificacion',
            );
            print(
              '🔄 [CARGAR-EVAL] Estado anterior en miembro: ${_calificaciones[miembroId]![criterioKey]}',
            );
            _calificaciones[miembroId]![criterioKey] = calificacion;
            print(
              '🔄 [CARGAR-EVAL] Estado después: ${_calificaciones[miembroId]![criterioKey]}',
            );
          });

          // Cargar comentarios existentes
          if (evaluacionExistente.comentarios != null &&
              evaluacionExistente.comentarios!.isNotEmpty) {
            _comentarios[miembroId] = evaluacionExistente.comentarios!;
            _comentarioControllers[miembroId]!.text =
                evaluacionExistente.comentarios!;
          }

          print(
            '📝 [CARGAR-EVAL] Calificaciones cargadas: ${_calificaciones[miembroId]}',
          );
          print(
            '💬 [CARGAR-EVAL] Comentarios cargados: "${_comentarios[miembroId]}"',
          );
        } else {
          print(
            'ℹ️ [CARGAR-EVAL] No hay evaluación completada para: $miembroId',
          );
        }
      } catch (e) {
        print('❌ [CARGAR-EVAL] Error cargando evaluación para $miembroId: $e');
      }
    }

    // Actualizar la UI después de cargar todas las evaluaciones
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _comentarioControllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  Future<void> _guardarEvaluacionIndividual(String miembroId) async {
    if (_currentUserId == null) {
      Get.snackbar(
        'Error de Autenticación',
        'No se encontró información del usuario. Por favor, inicia sesión nuevamente.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    setState(() {
      _enviandoEvaluacion[miembroId] = true;
    });

    try {
      print('🔄 [GUARDAR-EVAL] Guardando evaluación para miembro: $miembroId');

      // 1. Establecer calificaciones temporales en el controlador
      final calificacionesMiembro = _calificaciones[miembroId];
      print(
        '🔍 [GUARDAR-EVAL] Calificaciones del miembro completas: $calificacionesMiembro',
      );

      if (calificacionesMiembro != null) {
        print('🔍 [GUARDAR-EVAL] Iniciando conversión de calificaciones...');
        calificacionesMiembro.forEach((criterioKey, calificacion) {
          // Convertir la clave string al enum CriterioEvaluacion
          CriterioEvaluacion? criterio;
          switch (criterioKey) {
            case 'puntualidad':
              criterio = CriterioEvaluacion.puntualidad;
              break;
            case 'contribuciones':
              criterio = CriterioEvaluacion.contribuciones;
              break;
            case 'compromiso':
              criterio = CriterioEvaluacion.compromiso;
              break;
            case 'actitud':
              criterio = CriterioEvaluacion.actitud;
              break;
          }

          if (criterio != null) {
            print(
              '🔄 [GUARDAR-EVAL] Estableciendo calificación temporal: ${criterio.name} = $calificacion',
            );
            _evaluacionController.actualizarCalificacionTemporal(
              criterio,
              calificacion,
            );
          }
        });
      }

      // 2. Establecer comentarios temporales
      final comentarios = _comentarios[miembroId] ?? '';
      if (comentarios.isNotEmpty) {
        print(
          '🔄 [GUARDAR-EVAL] Estableciendo comentarios temporales: "$comentarios"',
        );
        _evaluacionController.actualizarComentariosTemporal(comentarios);
      }

      // 3. Verificar estado del controlador antes de guardar
      print('🔍 [GUARDAR-EVAL] Estado del controlador antes de guardar:');
      print(
        '🔍 [GUARDAR-EVAL] - Calificaciones temporales: ${_evaluacionController.calificacionesTemporales}',
      );
      print(
        '🔍 [GUARDAR-EVAL] - Comentarios temporales: "${_evaluacionController.comentariosTemporales}"',
      );

      // 4. Guardar directamente SIN cargar evaluación específica (para no limpiar las calificaciones temporales)
      print('� [GUARDAR-EVAL] Guardando evaluación directamente...');
      final exito = await _evaluacionController
          .crearOActualizarEvaluacionConCalificaciones(
            evaluacionPeriodoId: widget.evaluacionPeriodoId,
            evaluadorId: _currentUserId!,
            evaluadoId: miembroId,
            equipoId: widget.equipoId,
            calificaciones: calificacionesMiembro ?? {},
            comentarios: comentarios.isNotEmpty ? comentarios : null,
            completar: true, // Marcar como completada
          );

      if (exito) {
        print(
          '✅ [GUARDAR-EVAL] Evaluación guardada exitosamente: $_currentUserId -> $miembroId',
        );

        // Verificar que el widget esté montado antes de llamar setState
        if (mounted) {
          setState(() {
            _evaluacionesEnviadas[miembroId] = true;
          });
        }

        Get.snackbar(
          'Éxito',
          'Evaluación guardada correctamente',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: Duration(seconds: 2),
        );
      } else {
        print(
          '❌ [GUARDAR-EVAL] Error guardando evaluación: $_currentUserId -> $miembroId',
        );
        Get.snackbar(
          'Error',
          'No se pudo guardar la evaluación',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('❌ [GUARDAR-EVAL] Error al guardar evaluación: $e');
      Get.snackbar(
        'Error',
        'No se pudo guardar la evaluación: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() {
        _enviandoEvaluacion[miembroId] = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Evaluación - ${widget.actividad.nombre}'),
        backgroundColor: const Color(0xFF6C63FF),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Actividad: ${widget.actividad.nombre}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.actividad.descripcion,
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Evalúa a tus compañeros de equipo:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ...widget.miembrosEquipo
                      .where(
                        (miembro) => miembro['id'].toString() != _currentUserId,
                      ) // Excluir al usuario actual
                      .map((miembro) => _buildMiembroEvaluacion(miembro)),
                ],
              ),
            ),
    );
  }

  Widget _buildMiembroEvaluacion(Map<String, dynamic> miembro) {
    final miembroId = miembro['id'].toString();
    final nombre = miembro['nombre'] ?? 'Usuario';
    final apellido = miembro['apellido'] ?? '';
    final evaluacionEnviada = _evaluacionesEnviadas[miembroId] ?? false;
    final enviandoEvaluacion = _enviandoEvaluacion[miembroId] ?? false;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '$nombre $apellido',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (evaluacionEnviada)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Enviado',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            ...CriterioEvaluacion.values.map(
              (criterio) => _buildCriterioEvaluacion(
                miembroId,
                criterio,
                evaluacionEnviada,
              ),
            ),
            const SizedBox(height: 16),
            if (evaluacionEnviada)
              // Mostrar comentarios en modo de solo lectura
              _buildComentariosReadOnly(miembroId)
            else
              // Mostrar campo de comentarios editable
              _buildComentariosEditable(miembroId),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: evaluacionEnviada || enviandoEvaluacion
                    ? null
                    : () => _guardarEvaluacionIndividual(miembroId),
                style: ElevatedButton.styleFrom(
                  backgroundColor: evaluacionEnviada
                      ? Colors.green[100]
                      : const Color(0xFF6C63FF),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: evaluacionEnviada
                      ? BorderSide(color: Colors.green[300]!, width: 1)
                      : null,
                ),
                child: enviandoEvaluacion
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Enviando...',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (evaluacionEnviada)
                            Icon(
                              Icons.check_circle,
                              color: Colors.green[600],
                              size: 20,
                            ),
                          if (evaluacionEnviada) const SizedBox(width: 8),
                          Text(
                            evaluacionEnviada
                                ? 'Evaluación Completada'
                                : 'Enviar Evaluación',
                            style: TextStyle(
                              color: evaluacionEnviada
                                  ? Colors.green[600]
                                  : Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCriterioEvaluacion(
    String miembroId,
    CriterioEvaluacion criterio,
    bool evaluacionEnviada,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          criterio.nombre,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        Text(
          criterio.descripcion,
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
        const SizedBox(height: 8),
        if (evaluacionEnviada)
          // Mostrar solo la calificación seleccionada en modo de solo lectura
          _buildCalificacionReadOnly(miembroId, criterio)
        else
          // Mostrar todas las opciones para seleccionar
          _buildCalificacionEditable(miembroId, criterio),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildCalificacionReadOnly(
    String miembroId,
    CriterioEvaluacion criterio,
  ) {
    final calificacionSeleccionada = _calificaciones[miembroId]![criterio.name];
    final nivelSeleccionado = NivelEvaluacion.values.firstWhere(
      (nivel) => nivel.calificacion == calificacionSeleccionada,
      orElse: () => NivelEvaluacion.adecuado,
    );

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              nivelSeleccionado.calificacion.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              nivelSeleccionado.nombre,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          Icon(Icons.lock_outline, size: 16, color: Colors.grey[500]),
        ],
      ),
    );
  }

  Widget _buildCalificacionEditable(
    String miembroId,
    CriterioEvaluacion criterio,
  ) {
    return Row(
      children: NivelEvaluacion.values.map((nivel) {
        final isSelected =
            _calificaciones[miembroId]![criterio.name] == nivel.calificacion;
        return Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _calificaciones[miembroId]![criterio.name] = nivel.calificacion;
              });
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF6C63FF) : Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF6C63FF)
                      : Colors.grey[300]!,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    nivel.calificacion.toString(),
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    nivel.nombre,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black54,
                      fontSize: 10,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildComentariosReadOnly(String miembroId) {
    final comentarios = _comentarios[miembroId] ?? '';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Comentarios adicionales',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              Icon(Icons.lock_outline, size: 16, color: Colors.grey[500]),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            comentarios.isEmpty ? 'Sin comentarios' : comentarios,
            style: TextStyle(
              fontSize: 14,
              color: comentarios.isEmpty ? Colors.grey[500] : Colors.grey[700],
              fontStyle: comentarios.isEmpty
                  ? FontStyle.italic
                  : FontStyle.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComentariosEditable(String miembroId) {
    return TextField(
      controller: _comentarioControllers[miembroId],
      decoration: const InputDecoration(
        labelText: 'Comentarios adicionales',
        hintText: 'Escribe tus comentarios sobre este compañero...',
        border: OutlineInputBorder(),
      ),
      maxLines: 3,
      onChanged: (value) {
        _comentarios[miembroId] = value;
      },
    );
  }
}
