import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domain/entities/curso_entity.dart';
import '../../../activities/domain/entities/activity.dart';
import '../../../activities/presentation/controllers/activity_controller.dart';
import '../../../categories/domain/entities/equipo_entity.dart';
import '../../../categories/domain/entities/categoria_equipo_entity.dart';
import '../../../categories/presentation/controllers/categoria_equipo_controller.dart';
import '../../../evaluations/domain/entities/evaluacion_individual.dart';
import '../../../evaluations/presentation/controllers/evaluacion_individual_controller.dart';
import '../../../evaluations/presentation/controllers/evaluacion_periodo_controller.dart';
import '../../../evaluations/presentation/pages/realizar_evaluacion_page.dart';
import '../../../auth/presentation/controllers/roble_auth_login_controller.dart';
import '../../../auth/domain/repositories/usuario_repository.dart';

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
  late EvaluacionIndividualController _evaluacionController;
  late EvaluacionPeriodoController _evaluacionPeriodoController;
  late CategoriaEquipoController _categoriaEquipoController;
  late RobleAuthLoginController _authController;

  late TabController _tabController;
  bool _isLoading = true;
  bool _isLoadingEvaluaciones = false;
  List<Activity> _actividades = [];
  List<Equipo> _todosLosEquipos = [];
  List<Equipo> _misEquipos = [];
  List<CategoriaEquipo> _categorias = [];

  // Nueva estructura para manejar evaluaciones agrupadas por período
  final Map<String, List<EvaluacionIndividual>> _evaluacionesPorPeriodo = {};
  final Map<String, String> _periodoTitulos = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _initializarControllers();
  }

  void _initializarControllers() {
    try {
      _activityController = Get.find<ActivityController>();
      _categoriaEquipoController = Get.find<CategoriaEquipoController>();
      _evaluacionController = Get.find<EvaluacionIndividualController>();
      _evaluacionPeriodoController = Get.find<EvaluacionPeriodoController>();
      _authController = Get.find<RobleAuthLoginController>();
      _cargarDatos();
    } catch (e) {
      print('❌ Error inicializando controladores: $e');
      _reinicializarControladores();
    }
  }

  void _reinicializarControladores() {
    try {
      if (!Get.isRegistered<ActivityController>()) {
        Get.put<ActivityController>(ActivityController(), permanent: true);
      }
      if (!Get.isRegistered<CategoriaEquipoController>()) {
        Get.put<CategoriaEquipoController>(
          CategoriaEquipoController(Get.find(), Get.find()),
          permanent: true,
        );
      }

      _activityController = Get.find<ActivityController>();
      _categoriaEquipoController = Get.find<CategoriaEquipoController>();
      _evaluacionController = Get.find<EvaluacionIndividualController>();
      _evaluacionPeriodoController = Get.find<EvaluacionPeriodoController>();
      _authController = Get.find<RobleAuthLoginController>();

      print('✅ Controladores reinicializados correctamente');
      _cargarDatos();
    } catch (e) {
      print('❌ Error reinicializando controladores: $e');
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
      final usuario = _authController.currentUser.value;
      if (usuario == null) return;

      print('📚 [ESTUDIANTE] Cargando datos del curso: ${widget.curso.nombre}');

      // 1. Cargar categorías del curso
      await _categoriaEquipoController.loadCategoriasPorCurso(widget.curso);
      _categorias = _categoriaEquipoController.categorias.toList();
      print('📋 [ESTUDIANTE] Categorías encontradas: ${_categorias.length}');

      // 2. Cargar todos los equipos de todas las categorías del curso
      _todosLosEquipos.clear();
      for (final categoria in _categorias) {
        await _categoriaEquipoController.selectCategoria(categoria);
        final equiposPorCategoria = _categoriaEquipoController.equipos.toList();
        _todosLosEquipos.addAll(equiposPorCategoria);
        print(
          '⚽ [ESTUDIANTE] Categoria "${categoria.nombre}": ${equiposPorCategoria.length} equipos',
        );
      }

      print(
        '🎯 [ESTUDIANTE] Total equipos cargados: ${_todosLosEquipos.length}',
      );

      // 3. Filtrar mis equipos (en los que estoy inscrito)
      final miId = usuario.id;
      _misEquipos = _todosLosEquipos
          .where((equipo) => equipo.estudiantesIds.contains(miId))
          .toList();

      print('👥 [ESTUDIANTE] Mis equipos: ${_misEquipos.length}');

      // 4. Cargar actividades asignadas a mis equipos
      await _cargarActividadesAsignadasAMisEquipos();

      // 5. Cargar evaluaciones para mis actividades
      await _cargarEvaluacionesParaMisActividades();
    } catch (e) {
      print('❌ [ESTUDIANTE] Error cargando datos: $e');
      Get.snackbar(
        'Error',
        'Error cargando datos del curso: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _cargarActividadesAsignadasAMisEquipos() async {
    try {
      print(
        '🔍 [ESTUDIANTE] Cargando actividades asignadas específicamente a mis equipos...',
      );
      print('👥 [ESTUDIANTE] Mis equipos (${_misEquipos.length}):');
      for (final equipo in _misEquipos) {
        print(
          '   - Equipo: ${equipo.nombre} (ID: ${equipo.id}, CategoriaId: ${equipo.categoriaId})',
        );
      }

      _actividades.clear();
      final actividadesUnicas = <String, Activity>{};

      // Para cada uno de mis equipos, obtener SOLO las actividades asignadas específicamente
      for (final equipo in _misEquipos) {
        print(
          '🔍 [ESTUDIANTE] Verificando actividades asignadas al equipo ${equipo.nombre}...',
        );

        if (equipo.id != null) {
          try {
            // Obtener actividades asignadas específicamente a este equipo
            final actividadesAsignadas = await _activityController
                .getActividadesAsignadasAEquipo(equipo.id!);

            print(
              '📋 [ESTUDIANTE] Actividades asignadas al equipo ${equipo.nombre}: ${actividadesAsignadas.length}',
            );

            for (final actividad in actividadesAsignadas) {
              actividadesUnicas[actividad.id.toString()] = actividad;
              print(
                '✅ [ESTUDIANTE] Actividad agregada: "${actividad.nombre}" (ID: ${actividad.id}) para equipo ${equipo.nombre}',
              );
            }
          } catch (e) {
            print(
              '❌ [ESTUDIANTE] Error obteniendo actividades para equipo ${equipo.nombre}: $e',
            );
            // No agregar fallback - el estudiante solo debe ver actividades asignadas específicamente
          }
        } else {
          print('⚠️ [ESTUDIANTE] Equipo ${equipo.nombre} no tiene ID válido');
        }
      }

      _actividades = actividadesUnicas.values.toList();
      print(
        '🎯 [ESTUDIANTE] RESULTADO FINAL: ${_actividades.length} actividades asignadas específicamente a mis equipos',
      );

      if (_actividades.isEmpty) {
        print(
          'ℹ️ [ESTUDIANTE] No hay actividades asignadas específicamente a mis equipos',
        );
      } else {
        print('📚 [ESTUDIANTE] Actividades asignadas cargadas exitosamente:');
        for (final actividad in _actividades) {
          print('   ✅ "${actividad.nombre}" (ID: ${actividad.id})');
        }
      }
    } catch (e) {
      print('❌ [ESTUDIANTE] Error cargando actividades asignadas: $e');
    }
  }

  Future<void> _cargarEvaluacionesParaMisActividades() async {
    setState(() {
      _isLoadingEvaluaciones = true;
    });

    try {
      print('📊 [ESTUDIANTE] Cargando evaluaciones para mis actividades...');

      final usuario = _authController.currentUser.value;
      if (usuario == null) return;

      print('👤 [ESTUDIANTE] Usuario logueado ID: ${usuario.id}');
      _evaluacionesPorPeriodo.clear();
      _periodoTitulos.clear();

      for (final actividad in _actividades) {
        try {
          print(
            '🔍 [ESTUDIANTE] Verificando evaluaciones para actividad: ${actividad.nombre} (ID: ${actividad.id})',
          );

          // Cargar evaluaciones por actividad usando el método correcto
          await _evaluacionPeriodoController.cargarEvaluacionesPorActividad(
            actividad.id.toString(),
          );
          final evaluacionesPorActividad =
              _evaluacionPeriodoController.evaluacionesPorActividad;

          // Iterar sobre las evaluaciones de la actividad
          if (evaluacionesPorActividad.containsKey(actividad.id.toString())) {
            final evaluacionesDeActividad =
                evaluacionesPorActividad[actividad.id.toString()]!;
            print(
              '📋 [ESTUDIANTE] Encontradas ${evaluacionesDeActividad.length} evaluaciones de periodo para actividad ${actividad.nombre}',
            );

            for (final periodo in evaluacionesDeActividad) {
              print(
                '🔍 [ESTUDIANTE] Verificando periodo: ${periodo.titulo} (Activo: ${periodo.estaActivo})',
              );

              if (periodo.estaActivo && periodo.evaluacionEntrePares) {
                print(
                  '✅ [ESTUDIANTE] Periodo activo de evaluación entre pares encontrado',
                );

                // Cargar mis evaluaciones individuales para este período
                await _evaluacionController.cargarEvaluacionesPorPeriodo(
                  periodo.id,
                );

                final evaluacionesPorPeriodo =
                    _evaluacionController.evaluacionesPorPeriodo;
                if (evaluacionesPorPeriodo.containsKey(periodo.id)) {
                  final evaluacionesIndividuales =
                      evaluacionesPorPeriodo[periodo.id]!;
                  print(
                    '📝 [ESTUDIANTE] Encontradas ${evaluacionesIndividuales.length} evaluaciones individuales',
                  );

                  // **NUEVA LÓGICA**: Si no hay evaluaciones individuales, generarlas automáticamente
                  if (evaluacionesIndividuales.isEmpty) {
                    print(
                      '🔄 [ESTUDIANTE] No hay evaluaciones individuales, procediendo a generarlas...',
                    );
                    if (actividad.id != null) {
                      await _generarEvaluacionesAutomaticas(
                        periodo.id,
                        actividad.id!,
                      );
                    }

                    // Recargar las evaluaciones después de generarlas
                    await _evaluacionController.cargarEvaluacionesPorPeriodo(
                      periodo.id,
                    );
                    final evaluacionesActualizadas =
                        _evaluacionController.evaluacionesPorPeriodo[periodo
                            .id] ??
                        [];
                    print(
                      '🆕 [ESTUDIANTE] Después de generar: ${evaluacionesActualizadas.length} evaluaciones individuales',
                    );

                    // Debug: mostrar los evaluadores
                    for (final eval in evaluacionesActualizadas) {
                      print(
                        '   - Evaluación ID: ${eval.id}, Evaluador: ${eval.evaluadorId}, Evaluado: ${eval.evaluadoId}',
                      );
                    }

                    // Filtrar solo las evaluaciones donde yo soy el evaluador
                    final misEvaluacionesComoPertinentes =
                        evaluacionesActualizadas.where((eval) {
                          print(
                            '🔍 [ESTUDIANTE] Comparando evaluador: ${eval.evaluadorId} (${eval.evaluadorId.runtimeType}) == ${usuario.id.toString()} (String)',
                          );
                          final esElEvaluador =
                              eval.evaluadorId == usuario.id.toString();
                          print(
                            '🔍 [ESTUDIANTE] Resultado comparación: $esElEvaluador',
                          );
                          return esElEvaluador;
                        }).toList();

                    print(
                      '👤 [ESTUDIANTE] De estas, ${misEvaluacionesComoPertinentes.length} son evaluaciones que debo realizar',
                    );

                    // Agrupar evaluaciones por período
                    if (misEvaluacionesComoPertinentes.isNotEmpty) {
                      _evaluacionesPorPeriodo[periodo.id] =
                          misEvaluacionesComoPertinentes;
                      _periodoTitulos[periodo.id] = periodo.titulo;
                      print(
                        '📦 [ESTUDIANTE] Evaluaciones agrupadas para período "${periodo.titulo}": ${misEvaluacionesComoPertinentes.length}',
                      );
                    }
                  } else {
                    // Lógica existente: filtrar las evaluaciones ya existentes
                    print(
                      '📋 [ESTUDIANTE] Evaluaciones existentes encontradas:',
                    );
                    for (final eval in evaluacionesIndividuales) {
                      print(
                        '   - Evaluación ID: ${eval.id}, Evaluador: ${eval.evaluadorId}, Evaluado: ${eval.evaluadoId}',
                      );
                    }

                    final misEvaluacionesComoPertinentes =
                        evaluacionesIndividuales.where((eval) {
                          print(
                            '🔍 [ESTUDIANTE] Comparando evaluador: ${eval.evaluadorId} (${eval.evaluadorId.runtimeType}) == ${usuario.id.toString()} (String)',
                          );
                          final esElEvaluador =
                              eval.evaluadorId == usuario.id.toString();
                          print(
                            '🔍 [ESTUDIANTE] Resultado comparación: $esElEvaluador',
                          );
                          return esElEvaluador;
                        }).toList();

                    print(
                      '👤 [ESTUDIANTE] De estas, ${misEvaluacionesComoPertinentes.length} son evaluaciones que debo realizar',
                    );

                    // Agrupar evaluaciones por período
                    if (misEvaluacionesComoPertinentes.isNotEmpty) {
                      _evaluacionesPorPeriodo[periodo.id] =
                          misEvaluacionesComoPertinentes;
                      _periodoTitulos[periodo.id] = periodo.titulo;
                      print(
                        '📦 [ESTUDIANTE] Evaluaciones agrupadas para período "${periodo.titulo}": ${misEvaluacionesComoPertinentes.length}',
                      );
                    }
                  }

                  // Mostrar debug de las evaluaciones del período actual
                  final evaluacionesDelPeriodo =
                      _evaluacionesPorPeriodo[periodo.id] ?? [];
                  for (final eval in evaluacionesDelPeriodo) {
                    print(
                      '   - Evaluación ${eval.completada ? "COMPLETADA" : "PENDIENTE"} para evaluar ID: ${eval.evaluadoId}',
                    );
                  }
                }
              }
            }
          } else {
            print(
              '⚠️ [ESTUDIANTE] No se encontraron evaluaciones para actividad ${actividad.nombre}',
            );
          }
        } catch (e) {
          print(
            '❌ [ESTUDIANTE] Error cargando evaluaciones para actividad ${actividad.nombre}: $e',
          );
        }
      }

      // Calcular estadísticas de todas las evaluaciones
      int totalEvaluaciones = 0;
      int pendientes = 0;
      int completadas = 0;

      for (final evaluaciones in _evaluacionesPorPeriodo.values) {
        totalEvaluaciones += evaluaciones.length;
        pendientes += evaluaciones.where((e) => !e.completada).length;
        completadas += evaluaciones.where((e) => e.completada).length;
      }

      print(
        '📊 [ESTUDIANTE] RESUMEN FINAL: $totalEvaluaciones evaluaciones en total',
      );
      print('📊 [ESTUDIANTE] - Pendientes: $pendientes');
      print('📊 [ESTUDIANTE] - Completadas: $completadas');
      print(
        '📊 [ESTUDIANTE] - Períodos con evaluaciones: ${_evaluacionesPorPeriodo.length}',
      );
    } catch (e) {
      print('❌ [ESTUDIANTE] Error general cargando evaluaciones: $e');
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
              title: 'No hay actividades asignadas',
              subtitle:
                  'El profesor aún no ha asignado actividades específicas a tus equipos',
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
                    actividad.nombre,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              actividad.descripcion,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                SizedBox(width: 4),
                Text(
                  'Fecha de entrega: ${_formatDate(actividad.fechaEntrega)}',
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
      child: _isLoadingEvaluaciones
          ? Center(child: CircularProgressIndicator())
          : _evaluacionesPorPeriodo.isEmpty
          ? _buildEmptyState(
              icon: Icons.assessment_outlined,
              title: 'No hay evaluaciones',
              subtitle: 'Cuando haya evaluaciones activas aparecerán aquí',
            )
          : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: _evaluacionesPorPeriodo.length,
              itemBuilder: (context, index) {
                final periodoId = _evaluacionesPorPeriodo.keys.elementAt(index);
                final evaluaciones = _evaluacionesPorPeriodo[periodoId]!;
                final periodoTitulo = _periodoTitulos[periodoId]!;
                return _buildEvaluacionGrupalCard(
                  periodoId,
                  periodoTitulo,
                  evaluaciones,
                );
              },
            ),
    );
  }

  Widget _buildEvaluacionGrupalCard(
    String periodoId,
    String periodoTitulo,
    List<EvaluacionIndividual> evaluaciones,
  ) {
    // Verificar si todas las evaluaciones están completadas
    final todasCompletadas = evaluaciones.every((eval) => eval.completada);
    final totalCompaneros = evaluaciones.length;
    final completadas = evaluaciones.where((eval) => eval.completada).length;

    return Card(
      elevation: 2,
      margin: EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _realizarEvaluacionGrupal(periodoId, evaluaciones),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    todasCompletadas ? Icons.check_circle : Icons.assessment,
                    color: todasCompletadas ? Colors.green : Colors.orange,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      periodoTitulo,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: todasCompletadas
                          ? Colors.green[100]
                          : Colors.orange[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      todasCompletadas ? 'COMPLETADA' : 'PENDIENTE',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: todasCompletadas
                            ? Colors.green[800]
                            : Colors.orange[800],
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                'Compañeros a evaluar: $totalCompaneros',
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
              SizedBox(height: 4),
              Text(
                'Evaluaciones completadas: $completadas de $totalCompaneros',
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
              SizedBox(height: 8),
              LinearProgressIndicator(
                value: completadas / totalCompaneros,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation(
                  todasCompletadas ? Colors.green : Colors.orange,
                ),
              ),
              SizedBox(height: 8),
              Text(
                todasCompletadas
                    ? 'Toca para ver las evaluaciones'
                    : 'Toca para realizar evaluaciones',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
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
                  _authController.currentUser.value?.id ?? 0,
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
      final usuario = _authController.currentUser.value;
      if (usuario == null) {
        Get.snackbar('Error', 'No se encontró información del usuario');
        return;
      }

      final miId = usuario.id;

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

      // Intentar unirse al equipo usando el controlador
      await _categoriaEquipoController.unirseAEquipo(equipo);

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
    try {
      print('🔍 [OBTENER-NOMBRES] === OBTENIENDO NOMBRES DE ESTUDIANTES ===');
      print('🔍 [OBTENER-NOMBRES] IDs a buscar: $estudiantesIds');

      // Usar el repositorio de usuarios para obtener información real
      final usuarioRepository = Get.find<UsuarioRepository>();

      List<String> nombres = [];
      for (final id in estudiantesIds) {
        try {
          print('🔍 [OBTENER-NOMBRES] Buscando usuario con ID: $id');
          final usuario = await usuarioRepository.getUsuarioById(id);

          if (usuario != null) {
            final nombreCompleto = usuario.nombre.trim();
            nombres.add(
              nombreCompleto.isNotEmpty ? nombreCompleto : 'Usuario $id',
            );
            print(
              '✅ [OBTENER-NOMBRES] Usuario encontrado: "$nombreCompleto" (ID: $id)',
            );
          } else {
            nombres.add('Usuario $id');
            print('⚠️ [OBTENER-NOMBRES] Usuario no encontrado para ID: $id');
          }
        } catch (e) {
          print('❌ [OBTENER-NOMBRES] Error obteniendo usuario $id: $e');
          nombres.add('Usuario $id');
        }
      }

      print('✅ [OBTENER-NOMBRES] Nombres obtenidos: $nombres');
      return nombres;
    } catch (e) {
      print(
        '❌ [OBTENER-NOMBRES] Error general obteniendo nombres de estudiantes: $e',
      );
      return estudiantesIds.map((id) => 'Estudiante $id').toList();
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _realizarEvaluacionGrupal(
    String periodoId,
    List<EvaluacionIndividual> evaluaciones,
  ) async {
    try {
      print('🔍 [REALIZAR-EVAL-GRUPAL] === INICIANDO EVALUACIÓN GRUPAL ===');
      print('🔍 [REALIZAR-EVAL-GRUPAL] Período ID: $periodoId');
      print(
        '🔍 [REALIZAR-EVAL-GRUPAL] Total evaluaciones: ${evaluaciones.length}',
      );

      // Tomar la primera evaluación para obtener información común
      final primeraEvaluacion = evaluaciones.first;

      print(
        '🔍 [REALIZAR-EVAL-GRUPAL] Evaluación Periodo ID: ${primeraEvaluacion.evaluacionPeriodoId}',
      );
      print(
        '🔍 [REALIZAR-EVAL-GRUPAL] Evaluador ID: ${primeraEvaluacion.evaluadorId}',
      );
      print(
        '🔍 [REALIZAR-EVAL-GRUPAL] Equipo ID: ${primeraEvaluacion.equipoId}',
      );

      // 1. Obtener el período de evaluación
      print(
        '🔍 [REALIZAR-EVAL-GRUPAL] === PASO 1: CARGANDO PERÍODO DE EVALUACIÓN ===',
      );
      await _evaluacionPeriodoController.cargarEvaluacionPorId(
        primeraEvaluacion.evaluacionPeriodoId,
      );
      final periodo = _evaluacionPeriodoController.evaluacionActual;

      if (periodo == null) {
        print(
          '❌ [REALIZAR-EVAL-GRUPAL] Período no encontrado para ID: ${primeraEvaluacion.evaluacionPeriodoId}',
        );
        Get.snackbar(
          'Error',
          'No se encontró el período de evaluación',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      print('✅ [REALIZAR-EVAL-GRUPAL] Período encontrado:');
      print('   - Período ID: ${periodo.id}');
      print('   - Período título: ${periodo.titulo}');
      print('   - Actividad ID del período: ${periodo.actividadId}');
      print('   - Está activo: ${periodo.estaActivo}');
      print('   - Es evaluación entre pares: ${periodo.evaluacionEntrePares}');

      // 2. Buscar la actividad usando el actividadId del período
      print(
        '🔍 [REALIZAR-EVAL-GRUPAL] === PASO 2: BUSCANDO ACTIVIDAD ASOCIADA ===',
      );
      print(
        '🔍 [REALIZAR-EVAL-GRUPAL] Actividades disponibles (${_actividades.length}):',
      );
      for (final act in _actividades) {
        print(
          '   - Actividad ID: ${act.id} (${act.id.runtimeType}), Nombre: "${act.nombre}"',
        );
      }

      print(
        '🔍 [REALIZAR-EVAL-GRUPAL] Buscando actividad con ID: ${periodo.actividadId} (${periodo.actividadId.runtimeType})',
      );

      Activity? actividadEncontrada;
      for (final act in _actividades) {
        print(
          '🔍 [REALIZAR-EVAL-GRUPAL] Comparando: ${act.id} == ${periodo.actividadId}?',
        );
        // Convertir ambos a int para comparar correctamente
        final actividadIdInt = act.id;
        final periodoActividadIdInt =
            int.tryParse(periodo.actividadId.toString()) ?? -1;

        print(
          '🔍 [REALIZAR-EVAL-GRUPAL] Comparación convertida: $actividadIdInt == $periodoActividadIdInt?',
        );

        if (actividadIdInt == periodoActividadIdInt) {
          actividadEncontrada = act;
          print(
            '✅ [REALIZAR-EVAL-GRUPAL] ¡ACTIVIDAD ENCONTRADA! ${act.nombre}',
          );
          break;
        }
      }

      if (actividadEncontrada == null) {
        print(
          '❌ [REALIZAR-EVAL-GRUPAL] === ERROR: NO SE ENCONTRÓ LA ACTIVIDAD ASOCIADA ===',
        );
        print(
          '❌ [REALIZAR-EVAL-GRUPAL] ID buscado: ${periodo.actividadId} (${periodo.actividadId.runtimeType})',
        );
        print('❌ [REALIZAR-EVAL-GRUPAL] IDs disponibles:');
        for (final act in _actividades) {
          print('   - ${act.id} (${act.id.runtimeType})');
        }
        Get.snackbar(
          'Error',
          'No se encontró la actividad asociada',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      print(
        '✅ [REALIZAR-EVAL-GRUPAL] Actividad encontrada: "${actividadEncontrada.nombre}" (ID: ${actividadEncontrada.id})',
      );

      // 3. Obtener los miembros del equipo
      print(
        '🔍 [REALIZAR-EVAL-GRUPAL] === PASO 3: OBTENIENDO MIEMBROS DEL EQUIPO ===',
      );
      print(
        '🔍 [REALIZAR-EVAL-GRUPAL] Equipo ID buscado: ${primeraEvaluacion.equipoId}',
      );
      print(
        '🔍 [REALIZAR-EVAL-GRUPAL] Mis equipos disponibles (${_misEquipos.length}):',
      );
      for (final eq in _misEquipos) {
        print(
          '   - Equipo ID: ${eq.id} (${eq.id.runtimeType}), Nombre: "${eq.nombre}", Miembros: ${eq.estudiantesIds}',
        );
      }

      List<Map<String, dynamic>> miembrosEquipo = [];

      final equipo = _misEquipos.firstWhereOrNull(
        (e) => e.id.toString() == primeraEvaluacion.equipoId,
      );

      if (equipo != null) {
        print(
          '✅ [REALIZAR-EVAL-GRUPAL] Equipo encontrado: "${equipo.nombre}" (ID: ${equipo.id})',
        );
        print(
          '🔍 [REALIZAR-EVAL-GRUPAL] Miembros del equipo: ${equipo.estudiantesIds}',
        );

        // ✅ OBTENER NOMBRES REALES DE LOS ESTUDIANTES
        print(
          '🔄 [REALIZAR-EVAL-GRUPAL] Obteniendo nombres reales de estudiantes...',
        );
        final nombresReales = await _obtenerNombresEstudiantes(
          equipo.estudiantesIds,
        );

        for (int i = 0; i < equipo.estudiantesIds.length; i++) {
          final estudianteId = equipo.estudiantesIds[i];
          final nombreReal = i < nombresReales.length
              ? nombresReales[i]
              : 'Usuario $estudianteId';

          miembrosEquipo.add({
            'id': estudianteId,
            'nombre': nombreReal,
            'apellido': '', // Mantenemos por compatibilidad
          });
        }
        print(
          '✅ [REALIZAR-EVAL-GRUPAL] Miembros procesados con nombres reales: ${miembrosEquipo.length}',
        );
        for (final miembro in miembrosEquipo) {
          print('   - ${miembro['nombre']} (ID: ${miembro['id']})');
        }
      } else {
        print(
          '❌ [REALIZAR-EVAL-GRUPAL] No se encontró el equipo con ID: ${primeraEvaluacion.equipoId}',
        );
      }

      if (miembrosEquipo.isEmpty) {
        print(
          '❌ [REALIZAR-EVAL-GRUPAL] === ERROR: NO SE ENCONTRARON MIEMBROS DEL EQUIPO ===',
        );
        Get.snackbar(
          'Error',
          'No se encontraron miembros del equipo',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      // 4. Navegar a la página de evaluación
      print(
        '🔍 [REALIZAR-EVAL-GRUPAL] === PASO 4: NAVEGANDO A PÁGINA DE EVALUACIÓN ===',
      );
      print('🔍 [REALIZAR-EVAL-GRUPAL] Parámetros de navegación:');
      print(
        '   - Actividad: "${actividadEncontrada.nombre}" (ID: ${actividadEncontrada.id})',
      );
      print('   - Miembros equipo: ${miembrosEquipo.length} personas');
      print(
        '   - Evaluación Periodo ID: ${primeraEvaluacion.evaluacionPeriodoId}',
      );
      print('   - Equipo ID: ${primeraEvaluacion.equipoId}');

      final resultado = await Get.to(
        () => RealizarEvaluacionPage(
          actividad: actividadEncontrada!,
          miembrosEquipo: miembrosEquipo,
          evaluacionPeriodoId: primeraEvaluacion.evaluacionPeriodoId,
          equipoId: primeraEvaluacion.equipoId,
        ),
      );

      print('🔍 [REALIZAR-EVAL-GRUPAL] Resultado de navegación: $resultado');

      // ✅ RECARGA AUTOMÁTICA ROBUSTA SIEMPRE AL VOLVER (sin importar el resultado)
      print(
        '🔄 [REALIZAR-EVAL-GRUPAL] === RECARGANDO DATOS DESPUÉS DE EVALUACIÓN ===',
      );

      // Forzar actualización del estado inmediatamente
      setState(() {
        _isLoadingEvaluaciones = true;
      });

      // Recargar evaluaciones
      await _cargarEvaluacionesParaMisActividades();

      // Pequeña pausa para asegurar que los datos se reflejen en la UI
      await Future.delayed(Duration(milliseconds: 500));

      if (resultado == true) {
        print('✅ [REALIZAR-EVAL-GRUPAL] Evaluación completada exitosamente');
        Get.snackbar(
          'Actualizado',
          'Las evaluaciones han sido actualizadas',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: Duration(seconds: 2),
        );
      } else {
        print(
          'ℹ️ [REALIZAR-EVAL-GRUPAL] Usuario regresó, datos recargados automáticamente',
        );
      }

      print('✅ [REALIZAR-EVAL-GRUPAL] Recarga completada');
    } catch (e, stackTrace) {
      print(
        '❌ [REALIZAR-EVAL-GRUPAL] === ERROR GENERAL EN REALIZACIÓN DE EVALUACIÓN ===',
      );
      print('❌ [REALIZAR-EVAL-GRUPAL] Error: $e');
      print('❌ [REALIZAR-EVAL-GRUPAL] Stack trace: $stackTrace');
      Get.snackbar(
        'Error',
        'Error al preparar la evaluación: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// Genera automáticamente evaluaciones individuales para un periodo activo
  Future<void> _generarEvaluacionesAutomaticas(
    String evaluacionPeriodoId,
    int actividadId,
  ) async {
    try {
      print('🔄 [ESTUDIANTE] Iniciando generación automática de evaluaciones');
      print('🔄 [ESTUDIANTE] Periodo: $evaluacionPeriodoId');
      print('🔄 [ESTUDIANTE] Actividad: $actividadId');

      final usuario = _authController.currentUser.value;
      if (usuario == null) {
        print('❌ [ESTUDIANTE] Usuario no autenticado');
        return;
      }

      // Encontrar en qué equipos está el usuario para esta actividad
      for (final equipo in _misEquipos) {
        // Si el usuario está en este equipo, generar evaluaciones
        if (equipo.estudiantesIds.contains(usuario.id)) {
          print(
            '✅ [ESTUDIANTE] Equipo encontrado: ${equipo.nombre} (ID: ${equipo.id})',
          );
          print(
            '🔄 [ESTUDIANTE] Miembros del equipo: ${equipo.estudiantesIds}',
          );

          // Convertir los IDs de miembros a strings
          final miembrosComoStrings = equipo.estudiantesIds
              .map((id) => id.toString())
              .toList();

          // Generar evaluaciones para este equipo
          final evaluacionesGeneradas = await _evaluacionController
              .generarEvaluacionesParaPeriodo(
                evaluacionPeriodoId: evaluacionPeriodoId,
                equipoId: equipo.id.toString(),
                miembrosEquipo: miembrosComoStrings,
              );

          print(
            '✅ [ESTUDIANTE] Generadas ${evaluacionesGeneradas.length} evaluaciones para equipo ${equipo.nombre}',
          );

          // Solo necesitamos generar para un equipo por actividad
          break;
        }
      }
    } catch (e) {
      print('❌ [ESTUDIANTE] Error generando evaluaciones automáticas: $e');
    }
  }
}
