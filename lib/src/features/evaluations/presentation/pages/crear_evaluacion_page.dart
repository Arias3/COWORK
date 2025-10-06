import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/evaluacion_periodo_controller.dart';
import '../../../activities/domain/entities/activity.dart';
import '../../../auth/presentation/controllers/roble_auth_login_controller.dart';

class CrearEvaluacionPage extends StatefulWidget {
  final Activity activity;

  const CrearEvaluacionPage({Key? key, required this.activity})
    : super(key: key);

  @override
  State<CrearEvaluacionPage> createState() => _CrearEvaluacionPageState();
}

class _CrearEvaluacionPageState extends State<CrearEvaluacionPage> {
  final EvaluacionPeriodoController _evaluacionController =
      Get.find<EvaluacionPeriodoController>();
  final RobleAuthLoginController _authController =
      Get.find<RobleAuthLoginController>();

  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _descripcionController = TextEditingController();

  bool _permitirAutoEvaluacion = false;
  bool _tieneLimiteTiempo = false;
  int _duracionHoras = 24;
  bool _iniciarInmediatamente = true;

  @override
  void initState() {
    super.initState();
    _tituloController.text = 'Evaluación de Equipo - ${widget.activity.nombre}';
    _updateDescripcion(); // Actualizar descripción inicial
  }

  void _updateDescripcion() {
    String descripcion =
        'Evaluación entre compañeros de equipo para medir puntualidad, contribuciones, compromiso y actitud.';

    // Agregar información sobre las opciones seleccionadas
    List<String> opciones = [];

    if (_permitirAutoEvaluacion) {
      opciones.add('Incluye auto-evaluación');
    }

    if (_tieneLimiteTiempo) {
      opciones.add('Límite de $_duracionHoras horas');
    }

    if (_iniciarInmediatamente) {
      opciones.add('Inicia inmediatamente');
    } else {
      opciones.add('Requiere activación manual');
    }

    if (opciones.isNotEmpty) {
      descripcion += '\n\nOpciones: ${opciones.join(', ')}.';
    }

    _descripcionController.text = descripcion;
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Crear Evaluación'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildActivityInfo(),
              SizedBox(height: 24),
              _buildEvaluationForm(),
              SizedBox(height: 24),
              _buildCriteriosInfo(),
              SizedBox(height: 32),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivityInfo() {
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
          Row(
            children: [
              Icon(Icons.assignment, color: Colors.blue[700]),
              SizedBox(width: 8),
              Text(
                'Actividad',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.blue[700],
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            widget.activity.nombre,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 4),
          Text(
            widget.activity.descripcion,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildEvaluationForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Configuración de la Evaluación',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 16),

        // Título
        TextFormField(
          controller: _tituloController,
          decoration: InputDecoration(
            labelText: 'Título de la Evaluación',
            hintText: 'Ingresa el título...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            prefixIcon: Icon(Icons.title),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'El título es obligatorio';
            }
            return null;
          },
        ),
        SizedBox(height: 16),

        // Descripción
        TextFormField(
          controller: _descripcionController,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: 'Descripción (opcional)',
            hintText: 'Describe el propósito de esta evaluación...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            prefixIcon: Icon(Icons.description),
          ),
        ),
        SizedBox(height: 20),

        // Opciones avanzadas
        Text(
          'Opciones',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 12),

        // Permitir auto-evaluación
        SwitchListTile(
          title: Text('Permitir auto-evaluación'),
          subtitle: Text('Los estudiantes pueden evaluarse a sí mismos'),
          value: _permitirAutoEvaluacion,
          onChanged: (value) {
            setState(() {
              _permitirAutoEvaluacion = value;
              _updateDescripcion();
            });
          },
          contentPadding: EdgeInsets.zero,
        ),

        // Límite de tiempo
        SwitchListTile(
          title: Text('Establecer límite de tiempo'),
          subtitle: Text('La evaluación se cerrará automáticamente'),
          value: _tieneLimiteTiempo,
          onChanged: (value) {
            setState(() {
              _tieneLimiteTiempo = value;
              _updateDescripcion();
            });
          },
          contentPadding: EdgeInsets.zero,
        ),

        // Duración si tiene límite
        if (_tieneLimiteTiempo) ...[
          SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Duración: $_duracionHoras horas',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              Expanded(
                child: Slider(
                  value: _duracionHoras.toDouble(),
                  min: 1,
                  max: 168, // Una semana
                  divisions: 167,
                  label: '$_duracionHoras horas',
                  onChanged: (value) {
                    setState(() {
                      _duracionHoras = value.round();
                      _updateDescripcion();
                    });
                  },
                ),
              ),
            ],
          ),
        ],

        SizedBox(height: 8),

        // Iniciar inmediatamente
        SwitchListTile(
          title: Text('Iniciar inmediatamente'),
          subtitle: Text('Los estudiantes podrán evaluar de inmediato'),
          value: _iniciarInmediatamente,
          onChanged: (value) {
            setState(() {
              _iniciarInmediatamente = value;
              _updateDescripcion();
            });
          },
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }

  Widget _buildCriteriosInfo() {
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
          Row(
            children: [
              Icon(Icons.checklist, color: Colors.green[700]),
              SizedBox(width: 8),
              Text(
                'Criterios de Evaluación',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.green[700],
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            'Los estudiantes evaluarán a sus compañeros en los siguientes aspectos:',
            style: TextStyle(fontSize: 14),
          ),
          SizedBox(height: 8),
          _buildCriterioItem(
            '📅',
            'Puntualidad',
            'Asistencia y cumplimiento de horarios',
          ),
          _buildCriterioItem(
            '💡',
            'Contribuciones',
            'Aportes al trabajo del equipo',
          ),
          _buildCriterioItem(
            '🎯',
            'Compromiso',
            'Dedicación y responsabilidad',
          ),
          _buildCriterioItem('🤝', 'Actitud', 'Comportamiento y colaboración'),
          SizedBox(height: 8),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.amber[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Escala de Calificación:',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 4),
                Text('• Necesita Mejorar: 2.0'),
                Text('• Adecuado: 3.0'),
                Text('• Bueno: 4.0'),
                Text('• Excelente: 5.0'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCriterioItem(String emoji, String titulo, String descripcion) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: TextStyle(fontSize: 16)),
          SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titulo, style: TextStyle(fontWeight: FontWeight.w500)),
                Text(
                  descripcion,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Obx(() {
      return Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _evaluacionController.isLoading
                  ? null
                  : _crearEvaluacion,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _evaluacionController.isLoading
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Text('Creando evaluación...'),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.play_arrow),
                        SizedBox(width: 8),
                        Text(
                          _iniciarInmediatamente
                              ? 'Crear e Iniciar Evaluación'
                              : 'Crear Evaluación',
                        ),
                      ],
                    ),
            ),
          ),
          SizedBox(height: 12),
          TextButton(
            onPressed: _evaluacionController.isLoading
                ? null
                : () => Get.back(),
            child: Text('Cancelar'),
          ),
        ],
      );
    });
  }

  Future<void> _crearEvaluacion() async {
    print('🔄 Iniciando proceso de crear evaluación...');
    if (_formKey.currentState!.validate()) {
      final usuario = _authController.currentUser.value;
      if (usuario == null) {
        print('❌ Usuario no encontrado');
        Get.snackbar(
          'Error',
          'No se encontró información del usuario',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      try {
        print('✅ Usuario encontrado: ${usuario.email}');
        print('📝 Datos de evaluación:');
        print('   - Actividad ID: ${widget.activity.id}');
        print('   - Título: ${_tituloController.text.trim()}');
        print('   - Profesor ID: ${usuario.id}');
        print('   - Iniciar inmediatamente: $_iniciarInmediatamente');

        await _evaluacionController.crearEvaluacionPeriodo(
          actividadId: widget.activity.id.toString(),
          titulo: _tituloController.text.trim(),
          descripcion: _descripcionController.text.trim().isNotEmpty
              ? _descripcionController.text.trim()
              : null,
          fechaInicio: _iniciarInmediatamente
              ? DateTime.now()
              : DateTime.now(), // Si no es inmediato, se puede configurar después
          fechaFin: _tieneLimiteTiempo
              ? DateTime.now().add(Duration(hours: _duracionHoras))
              : null,
          profesorId: usuario.id.toString(),
          evaluacionEntrePares: true, // Siempre permitir evaluación entre pares
          permitirAutoEvaluacion:
              _permitirAutoEvaluacion, // Usar la opción correcta
          criteriosEvaluacion: [
            'Puntualidad',
            'Contribuciones',
            'Compromiso',
            'Actitud',
          ],
          habilitarComentarios: true, // Siempre permitir comentarios
          puntuacionMaxima: 5.0, // Escala de 2.0 a 5.0
        );

        // Si está marcado "iniciar inmediatamente", activar la evaluación
        if (_iniciarInmediatamente &&
            _evaluacionController.evaluacionActual != null) {
          print('🚀 Activando evaluación inmediatamente...');
          await _evaluacionController.activarEvaluacion(
            _evaluacionController.evaluacionActual!.id,
          );
        }

        print('🎉 Evaluación creada exitosamente');

        // Usar WidgetsBinding para asegurar que la navegación ocurra después del frame actual
        WidgetsBinding.instance.addPostFrameCallback((_) {
          print('🔙 Navegando de vuelta con resultado exitoso');
          if (mounted && Navigator.canPop(context)) {
            Navigator.pop(context, true);
          }
        });
      } catch (e) {
        print('❌ Error al crear evaluación: $e');

        // También usar el callback para errores
        WidgetsBinding.instance.addPostFrameCallback((_) {
          print('🔙 Navegando de vuelta después del error');
          if (mounted && Navigator.canPop(context)) {
            Navigator.pop(context, false);
          }
        });
      }
    } else {
      print('❌ Formulario no válido');
    }
  }
}
