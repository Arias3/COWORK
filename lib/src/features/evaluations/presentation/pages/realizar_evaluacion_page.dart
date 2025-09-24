import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domain/entities/criterios_evaluacion.dart';
import '../controllers/evaluacion_controller.dart';
import '../../../activities/domain/entities/activity.dart';
import '../../../auth/presentation/services/auth_service.dart';

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
  final EvaluacionController _evaluacionController =
      Get.find<EvaluacionController>();

  // Mapa para almacenar las calificaciones por usuario y criterio
  final Map<String, Map<String, double>> _calificaciones = {};
  final Map<String, String> _comentarios = {};
  final Map<String, TextEditingController> _comentarioControllers = {};

  bool _isLoading = false;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _obtenerUsuarioActual();
    _inicializarCalificaciones();
  }

  Future<void> _obtenerUsuarioActual() async {
    // Obtener el ID del usuario actual desde AuthService
    try {
      final authService = Get.find<AuthService>();
      final currentUser = authService.currentUser;

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

      // Inicializar cada criterio con una calificación por defecto
      for (var criterio in CriterioEvaluacion.values) {
        _calificaciones[miembroId]![criterio.name] =
            3.0; // Valor por defecto: Adecuado
      }
    }
  }

  @override
  void dispose() {
    _comentarioControllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  Future<void> _guardarEvaluacion() async {
    if (_currentUserId == null) {
      Get.snackbar(
        'Error de Autenticación',
        'No se encontró información del usuario. Por favor, inicia sesión nuevamente.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      for (var miembro in widget.miembrosEquipo) {
        final miembroId = miembro['id'].toString();

        // No evaluar a sí mismo
        if (miembroId == _currentUserId) {
          print('⏭️  Saltando auto-evaluación para usuario $_currentUserId');
          continue;
        }

        // Convertir las calificaciones de Map<String, double> a Map<CriterioEvaluacion, NivelEvaluacion>
        final Map<CriterioEvaluacion, NivelEvaluacion>
        calificacionesConvertidas = {};
        final calificacionesMiembro = _calificaciones[miembroId];

        if (calificacionesMiembro != null) {
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

            // Convertir la calificación numérica al enum NivelEvaluacion
            NivelEvaluacion nivel;
            if (calificacion >= 5.0) {
              nivel = NivelEvaluacion.excelente;
            } else if (calificacion >= 4.0) {
              nivel = NivelEvaluacion.bueno;
            } else if (calificacion >= 3.0) {
              nivel = NivelEvaluacion.adecuado;
            } else {
              nivel = NivelEvaluacion.necesitaMejorar;
            }

            if (criterio != null) {
              calificacionesConvertidas[criterio] = nivel;
            }
          });
        }

        // Guardar usando el controlador
        await _evaluacionController.guardarEvaluacion(
          periodoId: widget.evaluacionPeriodoId,
          evaluadorId: _currentUserId!,
          evaluadoId: miembroId,
          equipoId: widget.equipoId,
          calificaciones: calificacionesConvertidas,
          comentarios: _comentarios[miembroId],
        );

        print('✅ Evaluación guardada: $_currentUserId -> $miembroId');
      }

      // Mostrar mensaje de éxito
      Get.snackbar(
        'Éxito',
        'Evaluación guardada correctamente',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: Duration(seconds: 1),
      );

      // Esperar un momento para que se vea el snackbar y luego navegar
      await Future.delayed(Duration(milliseconds: 500));

      // Navegar hacia atrás con resultado exitoso
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop(true);
      } else {
        Get.back(result: true);
      }
    } catch (e) {
      print('❌ Error al guardar evaluaciones: $e');
      Get.snackbar(
        'Error',
        'No se pudo guardar la evaluación: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Evaluación - ${widget.actividad.name}'),
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
                            'Actividad: ${widget.actividad.name}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.actividad.description,
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
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _guardarEvaluacion,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6C63FF),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Guardar Evaluación',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildMiembroEvaluacion(Map<String, dynamic> miembro) {
    final miembroId = miembro['id'].toString();
    final nombre = miembro['nombre'] ?? 'Usuario';
    final apellido = miembro['apellido'] ?? '';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$nombre $apellido',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...CriterioEvaluacion.values.map(
              (criterio) => _buildCriterioEvaluacion(miembroId, criterio),
            ),
            const SizedBox(height: 16),
            TextField(
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCriterioEvaluacion(
    String miembroId,
    CriterioEvaluacion criterio,
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
        Row(
          children: NivelEvaluacion.values.map((nivel) {
            final isSelected =
                _calificaciones[miembroId]![criterio.name] ==
                nivel.calificacion;
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _calificaciones[miembroId]![criterio.name] =
                        nivel.calificacion;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF6C63FF)
                        : Colors.grey[200],
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
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
