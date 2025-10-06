import 'dart:math';
import '../entities/categoria_equipo_entity.dart';
import '../entities/equipo_entity.dart';

import '../repositories/categoria_equipo_repository.dart';
import '../repositories/equipo_repository.dart';
import '../../../home/domain/repositories/inscripcion_repository.dart';
import '../entities/tipo_asignacion.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/domain/repositories/usuario_repository.dart';

class CategoriaEquipoUseCase {
  final CategoriaEquipoRepository _categoriaRepository;
  final EquipoRepository _equipoRepository;
  final InscripcionRepository _inscripcionRepository;
  final UsuarioRepository _usuarioRepository;

  CategoriaEquipoUseCase(
    this._categoriaRepository,
    this._equipoRepository,
    this._inscripcionRepository,
    this._usuarioRepository,
  );

  // ===================== CATEGORÍAS =====================

  Future<List<CategoriaEquipo>> getCategoriasPorCurso(int cursoId) =>
      _categoriaRepository.getCategoriasPorCurso(cursoId);

  Future<CategoriaEquipo?> getCategoriaById(int id) =>
      _categoriaRepository.getCategoriaById(id);

  Future<int> createCategoria({
    required String nombre,
    required int cursoId,
    required TipoAsignacion tipoAsignacion,
    int maxEstudiantesPorEquipo = 4,
  }) async {
    if (nombre.trim().isEmpty) {
      throw Exception('El nombre de la categoría es obligatorio');
    }

    final categoria = CategoriaEquipo(
      nombre: nombre.trim(),
      cursoId: cursoId,
      tipoAsignacion: tipoAsignacion,
      maxEstudiantesPorEquipo: maxEstudiantesPorEquipo,
    );

    return await _categoriaRepository.createCategoria(categoria);
  }

  Future<void> updateCategoria(
    int id, {
    String? nombre,
    String? descripcion,
    int? maxEstudiantesPorEquipo,
    TipoAsignacion? tipoAsignacion,
  }) async {
    final categoria = await _categoriaRepository.getCategoriaById(id);
    if (categoria == null) throw Exception('Categoría no encontrada');

    if (nombre != null) categoria.nombre = nombre;
    if (descripcion != null) categoria.descripcion = descripcion;
    if (maxEstudiantesPorEquipo != null) {
      categoria.maxEstudiantesPorEquipo = maxEstudiantesPorEquipo;
    }
    if (tipoAsignacion != null) categoria.tipoAsignacion = tipoAsignacion;

    await _categoriaRepository.updateCategoria(categoria);
  }

  Future<void> deleteCategoria(int id) async {
    await _equipoRepository.deleteEquiposPorCategoria(id);
    await _categoriaRepository.deleteCategoria(id);
  }

  // ===================== EQUIPOS =====================

  Future<List<Equipo>> getEquiposPorCategoria(int categoriaId) =>
      _equipoRepository.getEquiposPorCategoria(categoriaId);

  Future<Equipo?> getEquipoById(int equipoId) =>
      _equipoRepository.getEquipoById(equipoId);

  Future<void> generarEquiposAleatorios(int categoriaId) async {
    final categoria = await _categoriaRepository.getCategoriaById(categoriaId);
    if (categoria == null) throw Exception('Categoría no encontrada');

    if (categoria.tipoAsignacion != TipoAsignacion.aleatoria) {
      throw Exception('Esta categoría no permite asignación aleatoria');
    }

    // Obtener estudiantes inscritos en el curso
    final inscripciones = await _inscripcionRepository.getInscripcionesPorCurso(
      categoria.cursoId,
    );
    final estudiantesIds = inscripciones.map((i) => i.usuarioId).toList();

    if (estudiantesIds.isEmpty) {
      throw Exception('No hay estudiantes inscritos en este curso');
    }

    // Limpiar equipos existentes
    await _equipoRepository.deleteEquiposPorCategoria(categoriaId);

    // Mezclar estudiantes aleatoriamente
    estudiantesIds.shuffle(Random());

    // Crear equipos
    final numEquipos =
        (estudiantesIds.length / categoria.maxEstudiantesPorEquipo).ceil();
    final equiposIds = <int>[];

    for (int i = 0; i < numEquipos; i++) {
      final inicioIndex = i * categoria.maxEstudiantesPorEquipo;
      final finIndex = (inicioIndex + categoria.maxEstudiantesPorEquipo).clamp(
        0,
        estudiantesIds.length,
      );

      final estudiantesEquipo = estudiantesIds.sublist(inicioIndex, finIndex);

      final equipo = Equipo(
        nombre: 'Equipo ${i + 1}',
        categoriaId: categoriaId,
        estudiantesIds: estudiantesEquipo,
        color: _generarColorAleatorio(),
      );

      final equipoId = await _equipoRepository.createEquipo(equipo);
      equiposIds.add(equipoId);
    }

    // Actualizar categoría con los IDs de equipos
    categoria.equiposIds = equiposIds;
    categoria.equiposGenerados = true;
    await _categoriaRepository.updateCategoria(categoria);
  }

  Future<void> unirseAEquipo(int estudianteId, int equipoId) async {
    final equipo = await _equipoRepository.getEquipoById(equipoId);
    if (equipo == null) throw Exception('Equipo no encontrado');

    final categoria = await _categoriaRepository.getCategoriaById(
      equipo.categoriaId,
    );
    if (categoria == null) throw Exception('Categoría no encontrada');

    if (categoria.tipoAsignacion != TipoAsignacion.manual) {
      throw Exception('Esta categoría no permite unirse manualmente');
    }

    // Verificar si ya está en un equipo de esta categoría
    final equipoActual = await _equipoRepository.getEquipoPorEstudiante(
      estudianteId,
      categoria.id!,
    );
    if (equipoActual != null) {
      throw Exception('Ya estás en un equipo de esta categoría');
    }

    // Verificar límite de estudiantes
    if (equipo.estudiantesIds.length >= categoria.maxEstudiantesPorEquipo) {
      throw Exception('Este equipo ya está completo');
    }

    // Agregar estudiante al equipo
    equipo.estudiantesIds = [...equipo.estudiantesIds, estudianteId];
    await _equipoRepository.updateEquipo(equipo);
  }

  Future<void> salirDeEquipo(int estudianteId, int categoriaId) async {
    final equipo = await _equipoRepository.getEquipoPorEstudiante(
      estudianteId,
      categoriaId,
    );
    if (equipo == null) {
      throw Exception('No estás en ningún equipo de esta categoría');
    }

    final categoria = await _categoriaRepository.getCategoriaById(categoriaId);
    if (categoria?.tipoAsignacion != TipoAsignacion.manual) {
      throw Exception('No puedes salir de un equipo de asignación aleatoria');
    }

    // Remover estudiante del equipo
    equipo.estudiantesIds = equipo.estudiantesIds
        .where((id) => id != estudianteId)
        .toList();
    await _equipoRepository.updateEquipo(equipo);
  }

  Future<Equipo?> getEquipoPorEstudiante(int estudianteId, int categoriaId) =>
      _equipoRepository.getEquipoPorEstudiante(estudianteId, categoriaId);

  Future<int> crearEquipo({
    required String nombre,
    required int categoriaId,
    List<int> estudiantesIds = const [],
    String? color,
  }) async {
    if (nombre.trim().isEmpty) {
      throw Exception('El nombre del equipo es obligatorio');
    }

    final equipo = Equipo(
      nombre: nombre.trim(),
      categoriaId: categoriaId,
      estudiantesIds: estudiantesIds,
      color: color ?? _generarColorAleatorio(),
    );

    return await _equipoRepository.createEquipo(equipo);
  }

  // ===================== GESTIÓN DE ESTUDIANTES =====================

  /// Obtiene todos los estudiantes inscritos en un curso
  Future<List<Usuario>> getEstudiantesDelCurso(int cursoId) async {
    try {
      final inscripciones = await _inscripcionRepository
          .getInscripcionesPorCurso(cursoId);
      final estudiantesIds = inscripciones.map((i) => i.usuarioId).toList();

      if (estudiantesIds.isEmpty) return [];

      final estudiantes = <Usuario>[];

      // Obtener detalles de cada estudiante
      for (final id in estudiantesIds) {
        try {
          final usuario = await _usuarioRepository.getUsuarioById(id);
          if (usuario != null && usuario.rol == 'estudiante') {
            estudiantes.add(usuario);
          }
        } catch (e) {
          print('Error getting user $id: $e');
        }
      }

      return estudiantes;
    } catch (e) {
      print('Error getting students from course: $e');
      return [];
    }
  }

  /// Obtiene estudiantes disponibles para asignar a un equipo específico
  /// (estudiantes del curso que NO están en ningún equipo de la categoría)
  Future<List<Usuario>> getEstudiantesDisponiblesParaEquipo(
    String equipoId,
    int categoriaId,
  ) async {
    try {
      // Obtener la categoría para saber a qué curso pertenece
      final categoria = await _categoriaRepository.getCategoriaById(
        categoriaId,
      );
      if (categoria == null) return [];

      // Obtener todos los estudiantes inscritos en el curso
      final todosEstudiantes = await getEstudiantesDelCurso(categoria.cursoId);

      // Obtener todos los equipos de esta categoría
      final equipos = await _equipoRepository.getEquiposPorCategoria(
        categoriaId,
      );

      // Recopilar IDs de estudiantes que ya están en equipos
      final estudiantesEnEquipos = <int>{};
      for (final equipo in equipos) {
        estudiantesEnEquipos.addAll(equipo.estudiantesIds);
      }

      // Filtrar estudiantes disponibles (no están en ningún equipo de esta categoría)
      final disponibles = todosEstudiantes.where((estudiante) {
        return !estudiantesEnEquipos.contains(estudiante.id);
      }).toList();

      return disponibles;
    } catch (e) {
      print('Error getting available students: $e');
      return [];
    }
  }

  /// Agrega un estudiante a un equipo específico
  Future<void> agregarEstudianteAEquipo(
    String equipoId,
    String estudianteId,
  ) async {
    try {
      final equipo = await _equipoRepository.getEquipoById(int.parse(equipoId));
      if (equipo == null) throw Exception('Equipo no encontrado');

      final categoria = await _categoriaRepository.getCategoriaById(
        equipo.categoriaId,
      );
      if (categoria == null) throw Exception('Categoría no encontrada');

      final studentIdInt = int.parse(estudianteId);

      // Verificar si el estudiante ya está en este equipo
      if (equipo.estudiantesIds.contains(studentIdInt)) {
        throw Exception('El estudiante ya está en este equipo');
      }

      // Verificar capacidad del equipo
      if (equipo.estudiantesIds.length >= categoria.maxEstudiantesPorEquipo) {
        throw Exception('El equipo ya está completo');
      }

      // Verificar si el estudiante ya está en otro equipo de esta categoría
      final equipoActual = await _equipoRepository.getEquipoPorEstudiante(
        studentIdInt,
        categoria.id!,
      );
      if (equipoActual != null) {
        throw Exception(
          'El estudiante ya está en otro equipo de esta categoría',
        );
      }

      // Agregar estudiante al equipo
      equipo.estudiantesIds = [...equipo.estudiantesIds, studentIdInt];
      await _equipoRepository.updateEquipo(equipo);
    } catch (e) {
      throw Exception('Error al agregar estudiante: $e');
    }
  }

  /// Remueve un estudiante de un equipo específico
  Future<void> removerEstudianteDeEquipo(
    String equipoId,
    String estudianteId,
  ) async {
    try {
      final equipo = await _equipoRepository.getEquipoById(int.parse(equipoId));
      if (equipo == null) throw Exception('Equipo no encontrado');

      final studentIdInt = int.parse(estudianteId);

      // Remover estudiante del equipo
      equipo.estudiantesIds = equipo.estudiantesIds
          .where((id) => id != studentIdInt)
          .toList();

      await _equipoRepository.updateEquipo(equipo);
    } catch (e) {
      throw Exception('Error al remover estudiante: $e');
    }
  }

  // ===================== UTILIDADES =====================

  String _generarColorAleatorio() {
    final colores = [
      '#FF6B6B',
      '#4ECDC4',
      '#45B7D1',
      '#96CEB4',
      '#FFEAA7',
      '#DDA0DD',
      '#98D8C8',
      '#F7DC6F',
      '#BB8FCE',
      '#85C1E9',
    ];
    return colores[Random().nextInt(colores.length)];
  }
}
