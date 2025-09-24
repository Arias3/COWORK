import '../entities/curso_entity.dart';
import '../repositories/curso_repository.dart';
import '../repositories/inscripcion_repository.dart';
import '../entities/inscripcion_entity.dart';

class CursoUseCase {
  final CursoRepository _cursoRepository;
  final InscripcionRepository _inscripcionRepository;

  CursoUseCase(this._cursoRepository, this._inscripcionRepository);

  Future<List<CursoDomain>> getCursos() => _cursoRepository.getCursos();

  Future<List<CursoDomain>> getCursosPorProfesor(int profesorId) =>
      _cursoRepository.getCursosPorProfesor(profesorId);

  Future<List<CursoDomain>> getCursosInscritos(int usuarioId) async {
    final inscripciones = await _inscripcionRepository
        .getInscripcionesPorUsuario(usuarioId);

    final cursos = <CursoDomain>[];
    for (final inscripcion in inscripciones) {
      final curso = await getCursoById(inscripcion.cursoId);
      if (curso != null) {
        cursos.add(curso);
      } else {
        print('⚠️ No se encontró curso para ID ${inscripcion.cursoId}');
      }
    }
    return cursos;
  }

  Future<CursoDomain?> getCursoById(int id) =>
      _cursoRepository.getCursoById(id);

  Future<CursoDomain?> getCursoByCodigoRegistro(String codigo) =>
      _cursoRepository.getCursoByCodigoRegistro(codigo);

  Future<int> createCurso({
    required String nombre,
    required String descripcion,
    required int profesorId,
    required String codigoRegistro,
    String? imagen,
    List<String>? categorias,
    List<String>? estudiantesNombres,
  }) async {
    // Validaciones básicas
    if (nombre.trim().isEmpty)
      throw Exception('El nombre del curso es obligatorio');
    if (descripcion.trim().isEmpty)
      throw Exception('La descripción es obligatoria');
    if (codigoRegistro.trim().isEmpty)
      throw Exception('El código de registro es obligatorio');

    // ✅ VALIDACIÓN CRÍTICA: Verificar que el código no exista
    final cursoExistente = await _cursoRepository.getCursoByCodigoRegistro(
      codigoRegistro.trim(),
    );
    if (cursoExistente != null) {
      throw Exception('Ya existe un curso con el código "$codigoRegistro"');
    }

    // ✅ CORRECCIÓN: Usar el código que recibimos como parámetro
    final curso = CursoDomain(
      nombre: nombre.trim(),
      descripcion: descripcion.trim(),
      profesorId: profesorId,
      codigoRegistro: codigoRegistro.trim(), // ← Usamos el código recibido
      imagen: imagen ?? 'assets/images/default_course.png',
      categorias: categorias ?? [],
      estudiantesNombres: estudiantesNombres ?? [],
    );

    return await _cursoRepository.createCurso(curso);
  }

  Future<void> updateCurso(CursoDomain curso) =>
      _cursoRepository.updateCurso(curso);

  Future<void> deleteCurso(int id) => _cursoRepository.deleteCurso(id);

  Future<void> inscribirseEnCurso(int usuarioId, String codigoRegistro) async {
    print('🔍 Buscando curso con código: "$codigoRegistro"');

    final curso = await _cursoRepository.getCursoByCodigoRegistro(
      codigoRegistro.trim(),
    );
    if (curso == null) {
      print('❌ No se encontró curso con código: "$codigoRegistro"');
      throw Exception('Código de curso no válido');
    }

    print('✅ Curso encontrado: ${curso.nombre} (ID: ${curso.id})');

    final yaInscrito = await _inscripcionRepository.estaInscrito(
      usuarioId,
      curso.id,
    );
    if (yaInscrito) {
      throw Exception('Ya estás inscrito en este curso');
    }

    final inscripcion = Inscripcion(usuarioId: usuarioId, cursoId: curso.id);

    await _inscripcionRepository.createInscripcion(inscripcion);
    print('✅ Usuario $usuarioId inscrito en curso ${curso.id}');
  }

  // Método auxiliar para generar códigos automáticos si es necesario
  String generateCourseCode(String nombre) {
    final timestamp = DateTime.now().millisecondsSinceEpoch
        .toString()
        .substring(7);
    final nameCode = nombre.replaceAll(' ', '').toUpperCase().substring(0, 3);
    return '$nameCode$timestamp';
  }

  // Método para validar disponibilidad de código
  Future<bool> isCodigoDisponible(String codigo) async {
    final curso = await _cursoRepository.getCursoByCodigoRegistro(codigo);
    return curso == null;
  }

  Future<List<Inscripcion>> getInscripcionesPorCurso(int cursoId) async {
    return await _inscripcionRepository.getInscripcionesPorCurso(cursoId);
  }
}
