import 'package:hive_flutter/hive_flutter.dart';
import '../../../src/features/auth/domain/entities/user_entity.dart';
import '../../../src/features/home/domain/entities/curso_entity.dart';
import '../../../src/features/home/domain/entities/inscripcion_entity.dart';
import '../../../src/features/categories/domain/entities/categoria_equipo_entity.dart';
import '../../../src/features/categories/domain/entities/equipo_entity.dart';
import '../../../src/features/categories/domain/entities/equipo_actividad_entity.dart';
import '../../../src/features/categories/domain/entities/tipo_asignacion.dart';
import '../../../src/features/activities/domain/entities/activity.dart';
import '../../../src/features/evaluations/domain/entities/evaluacion_periodo.dart';
import '../../../src/features/evaluations/domain/entities/evaluacion_individual.dart';

class HiveHelper {
  static const String usuariosBox = 'usuarios';
  static const String cursosBox = 'cursos';
  static const String inscripcionesBox = 'inscripciones';
  static const String categoriasEquipoBox = 'categorias_equipo';
  static const String equiposBox = 'equipos';
  static const String equipoActividadBox = 'equipo_actividad';
  static const String activitiesBox = 'activities';
  static const String evaluacionesPeriodoBox = 'evaluaciones_periodo';
  static const String evaluacionesIndividualBox = 'evaluaciones_individual';

  // Boxes existentes
  static Box<Usuario>? _usuariosBox;
  static Box<CursoDomain>? _cursosBox;
  static Box<Inscripcion>? _inscripcionesBox;

  // Nuevos boxes
  static Box<CategoriaEquipo>? _categoriasEquipoBox;
  static Box<Equipo>? _equiposBox;
  static Box<EquipoActividad>? _equipoActividadBox;
  static Box<Activity>? _activitiesBox;
  static Box<EvaluacionPeriodo>? _evaluacionesPeriodoBox;
  static Box<EvaluacionIndividual>? _evaluacionesIndividualBox;

  // Getters para boxes existentes
  static Box<Usuario> get usuariosBoxInstance => _usuariosBox!;
  static Box<CursoDomain> get cursosBoxInstance => _cursosBox!;
  static Box<Inscripcion> get inscripcionesBoxInstance => _inscripcionesBox!;

  // Getters para nuevos boxes
  static Box<CategoriaEquipo> get categoriasEquipoBoxInstance =>
      _categoriasEquipoBox!;
  static Box<Equipo> get equiposBoxInstance => _equiposBox!;
  static Box<EquipoActividad> get equipoActividadBoxInstance =>
      _equipoActividadBox!;
  static Box<Activity> get activitiesBoxInstance => _activitiesBox!;
  static Box<EvaluacionPeriodo> get evaluacionesPeriodoBoxInstance =>
      _evaluacionesPeriodoBox!;
  static Box<EvaluacionIndividual> get evaluacionesIndividualBoxInstance =>
      _evaluacionesIndividualBox!;

  static Future<void> initHive() async {
    await Hive.initFlutter();

    // Registrar adaptadores existentes
    Hive.registerAdapter(UsuarioAdapter());
    Hive.registerAdapter(CursoDomainAdapter());
    Hive.registerAdapter(InscripcionAdapter());

    // Registrar nuevos adaptadores
    Hive.registerAdapter(CategoriaEquipoAdapter());
    Hive.registerAdapter(EquipoAdapter());
    Hive.registerAdapter(EquipoActividadAdapter());
    Hive.registerAdapter(TipoAsignacionAdapter());
    Hive.registerAdapter(ActivityAdapter());
    Hive.registerAdapter(EvaluacionPeriodoAdapter());
    Hive.registerAdapter(EvaluacionIndividualAdapter());
    Hive.registerAdapter(EstadoEvaluacionPeriodoAdapter());

    // Abrir boxes existentes
    _usuariosBox = await Hive.openBox<Usuario>(usuariosBox);
    _cursosBox = await Hive.openBox<CursoDomain>(cursosBox);
    _inscripcionesBox = await Hive.openBox<Inscripcion>(inscripcionesBox);

    // Abrir nuevos boxes
    _categoriasEquipoBox = await Hive.openBox<CategoriaEquipo>(
      categoriasEquipoBox,
    );
    _equiposBox = await Hive.openBox<Equipo>(equiposBox);
    _equipoActividadBox = await Hive.openBox<EquipoActividad>(
      equipoActividadBox,
    );
    _activitiesBox = await Hive.openBox<Activity>(activitiesBox);
    _evaluacionesPeriodoBox = await Hive.openBox<EvaluacionPeriodo>(
      evaluacionesPeriodoBox,
    );
    _evaluacionesIndividualBox = await Hive.openBox<EvaluacionIndividual>(
      evaluacionesIndividualBox,
    );

    // Cargar datos iniciales si no existen
    await _loadInitialData();
  }

  static Future<void> _loadInitialData() async {
    // Obtener instancias para usar en _loadInitialData
    final usuariosBoxInstance = _usuariosBox!;
    final cursosBoxInstance = _cursosBox!;
    final inscripcionesBoxInstance = _inscripcionesBox!;
    final categoriasEquipoBoxInstance = _categoriasEquipoBox!;

    // Solo cargar datos si las cajas están vacías
    if (usuariosBoxInstance.isEmpty) {
      // Crear usuarios de prueba
      final usuarios = [
        Usuario(
          id: 1,
          nombre: 'Profesor A',
          email: 'a@a.com',
          password: '123456',
          rol: 'profesor',
        ),
        Usuario(
          id: 2,
          nombre: 'Estudiante B',
          email: 'b@b.com',
          password: '123456',
          rol: 'estudiante',
        ),
        Usuario(
          id: 3,
          nombre: 'Estudiante C',
          email: 'c@c.com',
          password: '123456',
          rol: 'estudiante',
        ),
        Usuario(
          id: 4,
          nombre: 'María González',
          email: 'maria@test.com',
          password: '123456',
          rol: 'estudiante',
        ),
        Usuario(
          id: 5,
          nombre: 'Juan Pérez',
          email: 'juan@test.com',
          password: '123456',
          rol: 'estudiante',
        ),
        Usuario(
          id: 6,
          nombre: 'Ana Silva',
          email: 'ana@test.com',
          password: '123456',
          rol: 'estudiante',
        ),
      ];

      for (var usuario in usuarios) {
        await usuariosBoxInstance.put(usuario.id, usuario);
        await usuariosBoxInstance.flush();
      }
    }

    if (cursosBoxInstance.isEmpty) {
      // Crear cursos de prueba
      final cursos = [
        CursoDomain(
          id: 1,
          nombre: 'Cálculo Diferencial',
          descripcion: 'Curso completo de cálculo diferencial para ingeniería',
          profesorId: 1,
          codigoRegistro: 'CAL001',
          imagen: 'assets/images/calculo.png',
          categorias: ['Matemáticas', 'Ciencias'],
          estudiantesNombres: ['Ana García', 'Luis Martínez'],
        ),
        CursoDomain(
          id: 2,
          nombre: 'Análisis de Datos',
          descripcion: 'Aprende a analizar datos con Python y R',
          profesorId: 1,
          codigoRegistro: 'ANA002',
          imagen: 'assets/images/analisis.png',
          categorias: ['Programación', 'Tecnología'],
          estudiantesNombres: ['Carlos Ruiz'],
        ),
        CursoDomain(
          id: 3,
          nombre: 'Flutter Avanzado',
          descripcion: 'Desarrollo de aplicaciones móviles avanzadas',
          profesorId: 1,
          codigoRegistro: 'FLU003',
          imagen: 'assets/images/flutter.png',
          categorias: ['Programación', 'Tecnología'],
          estudiantesNombres: [],
        ),
      ];

      for (var curso in cursos) {
        await cursosBoxInstance.put(curso.id, curso);
        await cursosBoxInstance.flush();
      }
    }

    if (inscripcionesBoxInstance.isEmpty) {
      // Crear inscripciones de prueba
      final inscripciones = [
        Inscripcion(id: 1, usuarioId: 2, cursoId: 3),
        Inscripcion(id: 2, usuarioId: 3, cursoId: 3),
        Inscripcion(id: 3, usuarioId: 4, cursoId: 3),
        Inscripcion(id: 4, usuarioId: 5, cursoId: 3),
        Inscripcion(id: 5, usuarioId: 6, cursoId: 3),
      ];

      for (var inscripcion in inscripciones) {
        await inscripcionesBoxInstance.put(inscripcion.id, inscripcion);
        await inscripcionesBoxInstance.flush();
      }
    }

    // Cargar datos de prueba para categorías y equipos
    if (categoriasEquipoBoxInstance.isEmpty) {
      final categorias = [
        CategoriaEquipo(
          id: 1,
          nombre: 'Proyecto Final',
          cursoId: 3, // Flutter Avanzado
          tipoAsignacion: TipoAsignacion.manual,
          maxEstudiantesPorEquipo: 4,
          equiposIds: [],
          equiposGenerados: false,
        ),
        CategoriaEquipo(
          id: 2,
          nombre: 'Laboratorio 1',
          cursoId: 3, // Flutter Avanzado
          tipoAsignacion: TipoAsignacion.aleatoria,
          maxEstudiantesPorEquipo: 3,
          equiposIds: [],
          equiposGenerados: false,
        ),
      ];

      for (var categoria in categorias) {
        await categoriasEquipoBoxInstance.put(categoria.id, categoria);
        await categoriasEquipoBoxInstance.flush();
      }
    }

    // Cargar datos de prueba para actividades
    if (activitiesBoxInstance.isEmpty) {
      final activities = [
        Activity(
          id: '1',
          name: 'Diseño de la Interfaz',
          description: 'Crear mockups y prototipos de la aplicación',
          categoryId: 1, // Proyecto Final
          deliveryDate: DateTime.now().add(Duration(days: 7)),
        ),
        Activity(
          id: '2',
          name: 'Implementación del Backend',
          description: 'Desarrollar las APIs necesarias para la aplicación',
          categoryId: 1, // Proyecto Final
          deliveryDate: DateTime.now().add(Duration(days: 14)),
        ),
        Activity(
          id: '3',
          name: 'Ejercicio de Widgets',
          description: 'Práctica con widgets básicos de Flutter',
          categoryId: 2, // Laboratorio 1
          deliveryDate: DateTime.now().subtract(Duration(days: 2)),
        ),
        Activity(
          id: '4',
          name: 'Navegación entre Pantallas',
          description: 'Implementar navegación usando GetX',
          categoryId: 2, // Laboratorio 1
          deliveryDate: DateTime.now().add(Duration(days: 3)),
        ),
      ];

      for (var activity in activities) {
        await activitiesBoxInstance.put(activity.id, activity);
        await activitiesBoxInstance.flush();
      }
    }

    // Los equipos se crearán cuando el profesor genere equipos o los estudiantes se unan manualmente
    // Por ahora dejamos la caja de equipos vacía para demostrar la funcionalidad
  }

  static Future<void> closeBoxes() async {
    await Hive.close();
  }
}
