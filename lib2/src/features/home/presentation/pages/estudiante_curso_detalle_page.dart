import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domain/entities/curso_entity.dart';
import '../../../activities/domain/entities/activity.dart';
import '../../../activities/presentation/controllers/activity_controller.dart';
import '../../../categories/domain/entities/equipo_entity.dart';
import '../../../categories/domain/entities/categoria_equipo_entity.dart';
import '../../../categories/domain/usecases/categoria_equipo_usecase.dart';
import '../../../evaluations/domain/entities/evaluacion_individual.dart';
import '../../../evaluations/domain/usecases/evaluacion_usecase.dart';
import '../../../evaluations/presentation/controllers/evaluacion_controller.dart';
import '../../../evaluations/presentation/pages/realizar_evaluacion_page.dart';
import '../../../auth/presentation/services/auth_service.dart';

class EstudianteCursoDetallePage extends StatefulWidget {
  final CursoDomain curso;

  const EstudianteCursoDetallePage({Key? key, required this.curso})
    : super(key: key);

  @override
  State<EstudianteCursoDetallePage> createState() =>
      _EstudianteCursoDetallePageState();
}

class _EstudianteCursoDetallePageState extends State<EstudianteCursoDetallePage>
    with SingleTickerProviderStateMixin {
  late ActivityController _activityController;
  late EvaluacionController _evaluacionController;
  late CategoriaEquipoUseCase _equipoUseCase;
  final AuthService _authService = Get.find<AuthService>();

  late TabController _tabController;
  bool _isLoading = true;
  bool _isLoadingEvaluaciones = false; // Loading específico para evaluaciones
  List<Activity> _actividades = [];
  List<Equipo> _todosLosEquipos = []; // Todos los equipos del curso
  List<Equipo> _misEquipos = []; // Solo mis equipos
  List<CategoriaEquipo> _categorias = []; // Categorías del curso
  List<EvaluacionIndividual> _misEvaluaciones = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _initializarControllers();
  }

  void _initializarControllers() {
    try {
      // Asegurar que los controladores estén disponibles
      _activityController = Get.find<ActivityController>();
      _equipoUseCase = Get.find<CategoriaEquipoUseCase>();
      _evaluacionController = Get.find<EvaluacionController>();
      _cargarDatos();
    } catch (e) {
      print('❌ Error inicializando controladores: $e');
      // Intentar reinicializar controladores
      _reinicializarControladores();
    }
  }

  void _reinicializarControladores() {
    try {
      // Si no están registrados, registrarlos manualmente
      if (!Get.isRegistered<ActivityController>()) {
        Get.put<ActivityController>(ActivityController(), permanent: true);
      }

      _activityController = Get.find<ActivityController>();
      _equipoUseCase = Get.find<CategoriaEquipoUseCase>();
      _evaluacionController = Get.find<EvaluacionController>();

      print('✅ Controladores reinicializados correctamente');
      _cargarDatos();
    } catch (e) {
      print('❌ Error reinicializando controladores: $e');
      // Mostrar error al usuario
      Get.snackbar(
        'Error',
        'Error inicializando la página. Por favor, reinicia la aplicación.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _cargarDatos() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final usuario = _authService.currentUser;
      if (usuario == null) return;

      print('📚 Cargando datos del curso: ${widget.curso.nombre}');

      // 1. Cargar TODAS las categorías del curso
      final categorias = await _equipoUseCase.getCategoriasPorCurso(
        widget.curso.id!,
      );
      _categorias = categorias;
      print('📋 Categorías encontradas: ${categorias.length}');

      // 2. Cargar TODOS los equipos de TODAS las categorías del curso
      _todosLosEquipos.clear();
      for (final categoria in categorias) {
        final equiposPorCategoria = await _equipoUseCase.getEquiposPorCategoria(
          categoria.id!,
        );
        _todosLosEquipos.addAll(equiposPorCategoria);
        print(
          '⚽ Categoria "${categoria.nombre}": ${equiposPorCategoria.length} equipos',
        );
      }

      print('🎯 Total equipos cargados: ${_todosLosEquipos.length}');

      // 3. Filtrar mis equipos (en los que ya estoy inscrito)
      final miId = int.parse(usuario.id.toString());
      _misEquipos = _todosLosEquipos
          .where((equipo) => equipo.estudiantesIds.contains(miId))
          .toList();

      print('👥 Mis equipos: ${_misEquipos.length}');

      // 4. Cargar SOLO las actividades asignadas a MIS equipos
      await _cargarActividadesAsignadasAMisEquipos();

      // 5. Cargar evaluaciones para MIS actividades
      await _cargarEvaluacionesParaMisActividades();
    } catch (e) {
      print('❌ Error cargando datos: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Cargar solo las actividades que están asignadas a mis equipos
  Future<void> _cargarActividadesAsignadasAMisEquipos() async {
    try {
      print('🔍 Cargando actividades asignadas a mis equipos...');
      print('👥 Mis equipos (${_misEquipos.length}):');
      for (final equipo in _misEquipos) {
        print(
          '   - Equipo: ${equipo.nombre} (ID: ${equipo.id}, CategoriaId: ${equipo.categoriaId})',
        );
      }

      _actividades.clear();
      final actividadesUnicas = <String, Activity>{};

      // Para cada uno de mis equipos, obtener las actividades asignadas
      for (final equipo in _misEquipos) {
        print(
          '🔍 Buscando asignaciones para equipo "${equipo.nombre}" (ID: ${equipo.id})...',
        );

        final asignaciones = await _activityController.equipoActividadUseCase
            .getAsignacionesByEquipo(equipo.id!);

        print(
          '📋 Equipo "${equipo.nombre}": ${asignaciones.length} asignaciones encontradas',
        );

        for (final asignacion in asignaciones) {
          print(
            '   → Asignación: ActividadID=${asignacion.actividadId}, Estado=${asignacion.estado}',
          );

          // Obtener todas las actividades de la categoría del equipo
          final actividadesPorCategoria = await _activityController
              .activityUseCase
              .getActivities(categoryId: equipo.categoriaId);

          print(
            '   → Actividades disponibles en categoría ${equipo.categoriaId}: ${actividadesPorCategoria.length}',
          );

          // Buscar la actividad específica
          final actividad = actividadesPorCategoria.firstWhereOrNull(
            (a) => a.id == asignacion.actividadId,
          );

          if (actividad != null) {
            actividadesUnicas[actividad.id!] = actividad;
            print(
              '   ✅ Actividad encontrada: "${actividad.name}" (ID: ${actividad.id})',
            );
          } else {
            print(
              '   ❌ Actividad NO encontrada con ID: ${asignacion.actividadId}',
            );

            // DEBUG: Mostrar todas las actividades disponibles para diagnóstico
            print('   🔍 Actividades disponibles en esta categoría:');
            for (final act in actividadesPorCategoria) {
              print('      - "${act.name}" (ID: ${act.id})');
            }
          }
        }
      }

      _actividades = actividadesUnicas.values.toList();
      print(
        '🎯 RESULTADO FINAL: ${_actividades.length} actividades asignadas a mis equipos',
      );

      if (_actividades.isEmpty) {
        print('⚠️  DIAGNÓSTICO: No se encontraron actividades. Verificar:');
        print('   1. ¿Mis equipos tienen asignaciones? (EquipoActividad)');
        print('   2. ¿Las actividades existen en las categorías correctas?');
        print('   3. ¿Los IDs coinciden correctamente?');
      } else {
        print('📚 Actividades cargadas exitosamente:');
        for (final actividad in _actividades) {
          print('   ✅ "${actividad.name}" (ID: ${actividad.id})');
        }
      }
    } catch (e) {
      print('❌ Error cargando actividades asignadas: $e');
      print('📍 Stack trace: ${StackTrace.current}');
    }
  }

  /// Cargar evaluaciones solo para las actividades asignadas a mis equipos
  Future<void> _cargarEvaluacionesParaMisActividades() async {
    setState(() {
      _isLoadingEvaluaciones = true;
    });

    try {
      print('📊 Cargando evaluaciones para mis actividades...');

      final usuario = _authService.currentUser;
      if (usuario == null) return;

      _misEvaluaciones.clear();

      for (final actividad in _actividades) {
        await _evaluacionController.cargarEvaluacionesPorActividad(
          actividad.id!.toString(),
        );

        final evaluacionesPorActividad =
            _evaluacionController.evaluacionesPorActividad;

        for (final periodo in evaluacionesPorActividad) {
          if (periodo.estaActiva) {
            // Cargar TODAS mis evaluaciones para este período (pendientes y completadas)
            await _evaluacionController.cargarMisEvaluaciones(
              usuario.id.toString(),
              periodo.id,
            );

            _misEvaluaciones.addAll(_evaluacionController.misEvaluaciones);
          }
        }
      }

      print('📊 Total evaluaciones: ${_misEvaluaciones.length}');
    } catch (e) {
      print('❌ Error cargando evaluaciones: $e');
    } finally {
      setState(() {
        _isLoadingEvaluaciones = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.curso.nombre, style: TextStyle(fontSize: 18)),
            Text(
              'Vista de Estudiante',
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
            Tab(text: 'Actividades', icon: Icon(Icons.assignment, size: 20)),
            Tab(
              text: 'Todos Equipos',
              icon: Icon(Icons.groups_outlined, size: 20),
            ),
            Tab(text: 'Mis Equipos', icon: Icon(Icons.groups, size: 20)),
            Tab(text: 'Evaluaciones', icon: Icon(Icons.assessment, size: 20)),
          ],
        ),
        actions: [
          IconButton(icon: Icon(Icons.refresh), onPressed: _cargarDatos),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildActividadesTab(),
                _buildTodosLosEquiposTab(),
                _buildMisEquiposTab(),
                _buildEvaluacionesTab(),
              ],
            ),
    );
  }

  Widget _buildActividadesTab() {
    return RefreshIndicator(
      onRefresh: _cargarDatos,
      child: _actividades.isEmpty
          ? _buildEmptyState(
              icon: Icons.assignment_outlined,
              title: 'No hay actividades',
              subtitle:
                  'El profesor aún no ha creado actividades para este curso',
            )
          : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: _actividades.length,
              itemBuilder: (context, index) {
                final actividad = _actividades[index];
                return _buildActividadCard(actividad);
              },
            ),
    );
  }

  Widget _buildActividadCard(Activity actividad) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.assignment, color: Colors.deepPurple),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    actividad.name,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              actividad.description,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                SizedBox(width: 4),
                Text(
                  'Creada: ${_formatDate(actividad.deliveryDate)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMisEquiposTab() {
    return RefreshIndicator(
      onRefresh: _cargarDatos,
      child: _misEquipos.isEmpty
          ? _buildEmptyState(
              icon: Icons.groups_outlined,
              title: 'No estás en ningún equipo',
              subtitle:
                  'El profesor aún no te ha asignado a ningún equipo para este curso',
            )
          : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: _misEquipos.length,
              itemBuilder: (context, index) {
                final equipo = _misEquipos[index];
                return _buildEquipoCard(equipo);
              },
            ),
    );
  }

  Widget _buildEquipoCard(Equipo equipo) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.groups, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  equipo.nombre,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            if (equipo.descripcion?.isNotEmpty == true) ...[
              SizedBox(height: 8),
              Text(
                equipo.descripcion!,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
            SizedBox(height: 12),
            Text(
              'Miembros del equipo:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 4),
            FutureBuilder<List<String>>(
              future: _obtenerNombresEstudiantes(equipo.estudiantesIds),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Text('Cargando miembros...');
                }

                if (snapshot.hasError || !snapshot.hasData) {
                  return Text('Error cargando miembros');
                }

                final nombres = snapshot.data!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: nombres
                      .map(
                        (nombre) => Padding(
                          padding: EdgeInsets.only(bottom: 2),
                          child: Row(
                            children: [
                              Icon(
                                Icons.person,
                                size: 16,
                                color: Colors.grey[600],
                              ),
                              SizedBox(width: 4),
                              Text(nombre, style: TextStyle(fontSize: 14)),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEvaluacionesTab() {
    return RefreshIndicator(
      onRefresh: _cargarDatos,
      child: _misEvaluaciones.isEmpty
          ? _buildEmptyState(
              icon: Icons.assessment_outlined,
              title: 'No hay evaluaciones',
              subtitle: 'Cuando haya evaluaciones activas aparecerán aquí',
            )
          : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: _misEvaluaciones.length,
              itemBuilder: (context, index) {
                final evaluacion = _misEvaluaciones[index];
                return _buildEvaluacionCard(evaluacion);
              },
            ),
    );
  }

  Widget _buildEvaluacionCard(EvaluacionIndividual evaluacion) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  evaluacion.completada ? Icons.check_circle : Icons.assessment,
                  color: evaluacion.completada ? Colors.green : Colors.orange,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    evaluacion.completada
                        ? 'Evaluación Completada'
                        : 'Evaluación Pendiente',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: evaluacion.completada
                        ? Colors.green[100]
                        : Colors.orange[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    evaluacion.completada ? 'COMPLETADA' : 'PENDIENTE',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: evaluacion.completada
                          ? Colors.green[800]
                          : Colors.orange[800],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            FutureBuilder<String>(
              future: _obtenerNombreEvaluado(evaluacion.evaluadoId),
              builder: (context, snapshot) {
                return Text(
                  'Evaluar a: ${snapshot.data ?? "Cargando..."}',
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                );
              },
            ),
            SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: evaluacion.completada
                    ? null
                    : () => _realizarEvaluacion(evaluacion),
                style: ElevatedButton.styleFrom(
                  backgroundColor: evaluacion.completada
                      ? Colors.grey
                      : Colors.orange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  evaluacion.completada
                      ? 'Evaluación Completada'
                      : 'Realizar Evaluación',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: Colors.grey[400]),
            SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodosLosEquiposTab() {
    return RefreshIndicator(
      onRefresh: _cargarDatos,
      child: _categorias.isEmpty
          ? _buildEmptyState(
              icon: Icons.category_outlined,
              title: 'No hay categorías disponibles',
              subtitle: 'El profesor aún no ha creado categorías y equipos',
            )
          : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: _categorias.length,
              itemBuilder: (context, index) {
                final categoria = _categorias[index];
                return _buildCategoriaCard(categoria);
              },
            ),
    );
  }

  Widget _buildCategoriaCard(CategoriaEquipo categoria) {
    // Obtener equipos de esta categoría
    final equiposDeCategoria = _todosLosEquipos
        .where((equipo) => equipo.categoriaId == categoria.id)
        .toList();

    return Card(
      elevation: 3,
      margin: EdgeInsets.only(bottom: 20),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Encabezado de la categoría
            Row(
              children: [
                Icon(Icons.category, color: Colors.deepPurple, size: 24),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        categoria.nombre,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                      Text(
                        '${equiposDeCategoria.length} equipo(s) | Máx ${categoria.maxEstudiantesPorEquipo} por equipo',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            // Lista de equipos de esta categoría
            if (equiposDeCategoria.isEmpty)
              Container(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(
                      Icons.groups_outlined,
                      size: 50,
                      color: Colors.grey[400],
                    ),
                    SizedBox(height: 8),
                    Text(
                      'No hay equipos en esta categoría',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              )
            else
              ...equiposDeCategoria.map((equipo) {
                final estoyInscrito = equipo.estudiantesIds.contains(
                  int.parse(_authService.currentUser?.id.toString() ?? '0'),
                );
                return _buildEquipoCardParaUnirse(
                  equipo,
                  estoyInscrito,
                  categoria,
                );
              }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildEquipoCardParaUnirse(
    Equipo equipo,
    bool estoyInscrito,
    CategoriaEquipo categoria,
  ) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  estoyInscrito ? Icons.groups : Icons.groups_outlined,
                  color: estoyInscrito ? Colors.green : Colors.blue,
                  size: 24,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        equipo.nombre,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${equipo.estudiantesIds.length}/${categoria.maxEstudiantesPorEquipo} miembros',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                if (estoyInscrito)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'MI EQUIPO',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            if (equipo.descripcion?.isNotEmpty == true) ...[
              SizedBox(height: 8),
              Text(
                equipo.descripcion!,
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.grey[700],
                ),
              ),
            ],
            SizedBox(height: 12),
            LinearProgressIndicator(
              value:
                  equipo.estudiantesIds.length /
                  categoria.maxEstudiantesPorEquipo.toDouble(),
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation(
                estoyInscrito ? Colors.green : Colors.blue,
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: estoyInscrito
                        ? null
                        : (equipo.estudiantesIds.length >=
                                  categoria.maxEstudiantesPorEquipo
                              ? null
                              : () => _unirseAEquipo(equipo, categoria)),
                    icon: Icon(
                      estoyInscrito ? Icons.check : Icons.person_add,
                      size: 18,
                    ),
                    label: Text(
                      estoyInscrito
                          ? 'Ya formas parte'
                          : (equipo.estudiantesIds.length >=
                                    categoria.maxEstudiantesPorEquipo
                                ? 'Equipo completo'
                                : 'Unirme al equipo'),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: estoyInscrito
                          ? Colors.green
                          : Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _unirseAEquipo(Equipo equipo, CategoriaEquipo categoria) async {
    try {
      final usuario = _authService.currentUser;
      if (usuario == null) {
        Get.snackbar('Error', 'No se encontró información del usuario');
        return;
      }

      final miId = int.parse(usuario.id.toString());

      // Verificar si ya está en un equipo de esta categoría
      final yaEnCategoria = _todosLosEquipos
          .where((eq) => eq.categoriaId == categoria.id)
          .any((eq) => eq.estudiantesIds.contains(miId));

      if (yaEnCategoria) {
        Get.snackbar(
          'Aviso',
          'Ya estás inscrito en un equipo de esta categoría',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return;
      }

      // Mostrar diálogo de confirmación
      bool? confirmar = await Get.dialog<bool>(
        AlertDialog(
          title: Text('Confirmar'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('¿Deseas unirte al equipo "${equipo.nombre}"?'),
              SizedBox(height: 8),
              Text(
                'Categoría: ${categoria.nombre}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              Text(
                'Solo puedes estar en un equipo por categoría.',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
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
              child: Text('Confirmar'),
            ),
          ],
        ),
      );

      if (confirmar != true) return;

      // Intentar unirse al equipo
      await _equipoUseCase.unirseAEquipo(miId, equipo.id!);

      Get.snackbar(
        'Éxito',
        'Te has unido al equipo "${equipo.nombre}" correctamente',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Recargar datos
      await _cargarDatos();
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo unir al equipo: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<List<String>> _obtenerNombresEstudiantes(
    List<int> estudiantesIds,
  ) async {
    // Esta función debería implementarse para obtener nombres reales de estudiantes
    // Por ahora retornamos nombres de ejemplo
    return estudiantesIds.map((id) => 'Estudiante $id').toList();
  }

  Future<String> _obtenerNombreEvaluado(String evaluadoId) async {
    try {
      final usuarios = await _authService.obtenerTodosLosUsuarios();
      final evaluadoIdInt = int.tryParse(evaluadoId) ?? 0;
      final usuario = usuarios.firstWhere(
        (u) => u.id == evaluadoIdInt,
        orElse: () => throw Exception('Usuario no encontrado'),
      );

      return usuario.nombre;
    } catch (e) {
      print('Error obteniendo nombre para evaluado $evaluadoId: $e');
      return 'Estudiante $evaluadoId';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _realizarEvaluacion(EvaluacionIndividual evaluacion) async {
    try {
      print('🔄 [REALIZAR-EVAL] Iniciando _realizarEvaluacion');
      print('🔄 [REALIZAR-EVAL] Evaluación: ${evaluacion.toString()}');
      print(
        '🔄 [REALIZAR-EVAL] evaluacionPeriodoId: ${evaluacion.evaluacionPeriodoId}',
      );

      // 1. Obtener el período de evaluación para conseguir el actividadId
      final evaluacionUseCase = Get.find<EvaluacionUseCase>();
      print('🔄 [REALIZAR-EVAL] Buscando período de evaluación...');

      final periodo = await evaluacionUseCase.obtenerEvaluacionPeriodo(
        evaluacion.evaluacionPeriodoId,
      );

      print(
        '🔄 [REALIZAR-EVAL] Período obtenido: ${periodo?.toString() ?? "NULL"}',
      );
      if (periodo != null) {
        print(
          '🔄 [REALIZAR-EVAL] Período - actividadId: ${periodo.actividadId}',
        );
      }

      if (periodo == null) {
        print(
          '❌ [REALIZAR-EVAL] ERROR: No se encontró el período de evaluación',
        );
        Get.snackbar(
          'Error',
          'No se encontró el período de evaluación',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      // 2. Buscar la actividad usando el actividadId del período
      print(
        '🔄 [REALIZAR-EVAL] Buscando actividad con ID: ${periodo.actividadId}',
      );
      print(
        '🔄 [REALIZAR-EVAL] Actividades disponibles: ${_actividades.length}',
      );
      for (int i = 0; i < _actividades.length; i++) {
        print(
          '🔄 [REALIZAR-EVAL] Actividad $i: "${_actividades[i].name}" (ID: ${_actividades[i].id})',
        );
      }

      Activity? actividadEncontrada;
      for (final act in _actividades) {
        if (act.id == periodo.actividadId) {
          actividadEncontrada = act;
          break;
        }
      }

      print(
        '🔄 [REALIZAR-EVAL] Actividad encontrada: ${actividadEncontrada?.name ?? "NULL"}',
      );

      if (actividadEncontrada == null) {
        print('❌ [REALIZAR-EVAL] ERROR: No se encontró la actividad asociada');
        print('❌ [REALIZAR-EVAL] Buscando actividadId: ${periodo.actividadId}');
        print('❌ [REALIZAR-EVAL] En actividades:');
        for (final act in _actividades) {
          print('❌ [REALIZAR-EVAL]   - "${act.name}" (ID: ${act.id})');
        }
        Get.snackbar(
          'Error',
          'No se encontró la actividad asociada',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      // 3. Obtener los miembros del equipo para esta evaluación
      print('🔄 [REALIZAR-EVAL] Obteniendo miembros del equipo...');
      print(
        '🔄 [REALIZAR-EVAL] equipoId de evaluación: ${evaluacion.equipoId}',
      );
      print(
        '🔄 [REALIZAR-EVAL] Mis equipos disponibles: ${_misEquipos.length}',
      );

      List<Map<String, dynamic>> miembrosEquipo = [];

      // Encontrar el equipo correspondiente
      final equipo = _misEquipos.firstWhereOrNull(
        (e) => e.id.toString() == evaluacion.equipoId,
      );

      print(
        '🔄 [REALIZAR-EVAL] Equipo encontrado: ${equipo?.nombre ?? "NULL"}',
      );
      if (equipo != null) {
        print(
          '🔄 [REALIZAR-EVAL] Estudiantes del equipo: ${equipo.estudiantesIds}',
        );
      }

      if (equipo != null) {
        // Convertir IDs de estudiantes a información de miembros
        for (final estudianteId in equipo.estudiantesIds) {
          try {
            print('🔄 [REALIZAR-EVAL] Buscando usuario con ID: $estudianteId');
            final usuarios = await _authService.obtenerTodosLosUsuarios();
            final usuario = usuarios.firstWhere(
              (u) => u.id == estudianteId,
              orElse: () => throw Exception('Usuario no encontrado'),
            );

            miembrosEquipo.add({
              'id': estudianteId,
              'nombre': usuario.nombre,
              'apellido': '', // No hay apellido en la entidad Usuario
            });
            print(
              '🔄 [REALIZAR-EVAL] Usuario agregado: ${usuario.nombre} (ID: $estudianteId)',
            );
          } catch (e) {
            print(
              '❌ [REALIZAR-EVAL] Error obteniendo información del estudiante $estudianteId: $e',
            );
          }
        }
      }

      print(
        '🔄 [REALIZAR-EVAL] Total miembros encontrados: ${miembrosEquipo.length}',
      );

      if (miembrosEquipo.isEmpty) {
        print('❌ [REALIZAR-EVAL] ERROR: No se encontraron miembros del equipo');
        Get.snackbar(
          'Error',
          'No se encontraron miembros del equipo',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      // 3. Navegar a la página de evaluación
      print('🔄 [REALIZAR-EVAL] Navegando a RealizarEvaluacionPage...');
      print('🔄 [REALIZAR-EVAL] Parámetros de navegación:');
      print(
        '   - actividad: ${actividadEncontrada.name} (ID: ${actividadEncontrada.id})',
      );
      print('   - miembrosEquipo: ${miembrosEquipo.length} miembros');
      print('   - evaluacionPeriodoId: ${evaluacion.evaluacionPeriodoId}');
      print('   - equipoId: ${evaluacion.equipoId}');

      final resultado = await Get.to(
        () => RealizarEvaluacionPage(
          actividad: actividadEncontrada!, // Ya verificamos que no es null
          miembrosEquipo: miembrosEquipo,
          evaluacionPeriodoId: evaluacion.evaluacionPeriodoId,
          equipoId: evaluacion.equipoId,
        ),
      );

      print('🔄 [REALIZAR-EVAL] Resultado de navegación: $resultado');

      // Si la evaluación fue exitosa, recargar las evaluaciones
      if (resultado == true) {
        print(
          '✅ [REALIZAR-EVAL] Evaluación completada, recargando evaluaciones...',
        );
        // Recargar inmediatamente las evaluaciones
        await _cargarEvaluacionesParaMisActividades();

        // Mostrar mensaje de confirmación adicional
        Get.snackbar(
          'Actualizado',
          'Las evaluaciones han sido actualizadas',
          backgroundColor: Colors.blue,
          colorText: Colors.white,
          duration: Duration(seconds: 1),
        );
      }
    } catch (e) {
      print('❌ [REALIZAR-EVAL] ERROR COMPLETO: $e');
      print('❌ [REALIZAR-EVAL] TIPO DE ERROR: ${e.runtimeType}');
      print('❌ [REALIZAR-EVAL] STACK TRACE: ${StackTrace.current}');
      Get.snackbar(
        'Error',
        'Error al preparar la evaluación: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
