import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domain/use_case/curso_usecase.dart';
import '../../../auth/presentation/controllers/roble_auth_login_controller.dart';
import '../../../auth/domain/use_case/usuario_usecase.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/domain/repositories/usuario_repository.dart';
import './home_controller.dart';
import 'dart:math';

// Extensión para firstWhereOrNull si no está disponible
extension IterableExtension<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T) test) {
    for (T element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}

class NewCourseController extends GetxController {
  final CursoUseCase cursoUseCase;
  final RobleAuthLoginController authController;
  final UsuarioUseCase usuarioUseCase;

  NewCourseController(
    this.cursoUseCase,
    this.authController,
    this.usuarioUseCase,
  );

  // Variables existentes
  var nombreCurso = ''.obs;
  var descripcion = ''.obs;
  var selectedCategorias = <String>[].obs;
  var isLoading = false.obs;

  // Variables para manejo de usuarios
  var todosLosEstudiantes = <Usuario>[].obs;
  var estudiantesDisponibles = <Usuario>[].obs;
  var estudiantesSeleccionados = <Usuario>[].obs;
  var searchQuery = ''.obs;
  var isLoadingStudents = false.obs;

  var codigoRegistro = ''.obs;

  // Categorías disponibles
  var categorias = [
    'Matemáticas',
    'Programación',
    'Diseño',
    'Idiomas',
    'Ciencias',
    'Arte',
    'Negocios',
    'Tecnología',
  ].obs;

  @override
  void onInit() {
    super.onInit();
    print('🚀 NewCourseController iniciado');

    // Debug del estado inicial de autenticación
    print('🔐 Estado inicial de autenticación:');
    print('currentUser: ${authController.currentUser.value?.nombre}');
    if (authController.currentUser.value != null) {
      print('User ID: ${authController.currentUser.value!.id}');
      print('User Role: ${authController.currentUser.value!.rol}');
    }

    cargarEstudiantes();

    // Escuchar cambios en la búsqueda
    debounce(searchQuery, (query) {
      filtrarEstudiantes();
    }, time: const Duration(milliseconds: 500));
  }

  // ========================================================================
  // MÉTODOS PARA CARGAR Y FILTRAR ESTUDIANTES
  // ========================================================================

  Future<void> cargarEstudiantes() async {
    try {
      isLoadingStudents.value = true;
      print('🔄 Cargando estudiantes desde BD...');

      final usuarios = await usuarioUseCase.getUsuarios();
      print('👥 Total usuarios: ${usuarios.length}');

      // Obtener el usuario actual
      final usuarioActual = authController.currentUser.value;
      print(
        '👤 Usuario actual: ${usuarioActual?.nombre} (ID: ${usuarioActual?.id})',
      );

      // Filtrar solo estudiantes (excluir profesores Y al usuario actual)
      todosLosEstudiantes.value = usuarios
          .where(
            (usuario) =>
                usuario.rol == 'estudiante' &&
                usuario.id != usuarioActual?.id, // Excluir al usuario actual
          )
          .toList();

      print(
        '🎓 Estudiantes encontrados (sin incluir usuario actual): ${todosLosEstudiantes.length}',
      );

      // Inicialmente todos están disponibles
      estudiantesDisponibles.value = List.from(todosLosEstudiantes);
    } catch (e) {
      print('❌ Error cargando estudiantes: $e');
      // Solo mostrar mensaje de error si es crítico para el usuario
      if (todosLosEstudiantes.isEmpty) {
        Get.snackbar(
          'Error',
          'No se pudieron cargar los estudiantes. Verifica tu conexión.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }
    } finally {
      isLoadingStudents.value = false;
    }
  }

  void filtrarEstudiantes() {
    if (searchQuery.value.trim().isEmpty) {
      // Sin búsqueda, mostrar todos los disponibles
      estudiantesDisponibles.value = todosLosEstudiantes
          .where(
            (estudiante) => !estudiantesSeleccionados.any(
              (selected) => selected.id == estudiante.id,
            ),
          )
          .toList();
    } else {
      // Filtrar por nombre o email
      final query = searchQuery.value.toLowerCase();
      final resultados = <Usuario>[];

      for (var estudiante in todosLosEstudiantes) {
        final yaSeleccionado = estudiantesSeleccionados.any(
          (selected) => selected.id == estudiante.id,
        );

        if (!yaSeleccionado) {
          final coincideNombre = estudiante.nombre.toLowerCase().contains(
            query,
          );
          final coincideEmail = estudiante.email.toLowerCase().contains(query);

          if (coincideNombre || coincideEmail) {
            resultados.add(estudiante);
          }
        }
      }

      estudiantesDisponibles.value = resultados;
    }

    // Forzar actualización de UI
    estudiantesDisponibles.refresh();
  }

  // ========================================================================
  // MÉTODOS PARA MANEJAR SELECCIÓN DE ESTUDIANTES
  // ========================================================================

  void agregarEstudiante(Usuario estudiante) {
    if (!estudiantesSeleccionados.any((e) => e.id == estudiante.id)) {
      estudiantesSeleccionados.add(estudiante);
      filtrarEstudiantes(); // Actualizar lista disponible

      // Mensaje removido para mejor fluidez - el cambio visual es suficiente
      print('✅ Estudiante "${estudiante.nombre}" agregado al curso');
    }
  }

  void eliminarEstudiante(Usuario estudiante) {
    estudiantesSeleccionados.removeWhere((e) => e.id == estudiante.id);
    filtrarEstudiantes(); // Actualizar lista disponible

    // Mensaje removido para mejor fluidez - el cambio visual es suficiente
    print('✅ Estudiante "${estudiante.nombre}" eliminado del curso');
  }

  void limpiarSeleccion() {
    estudiantesSeleccionados.clear();
    filtrarEstudiantes();

    // Mensaje removido para mejor fluidez - acción simple que no necesita confirmación
    print('✅ Se eliminaron todos los estudiantes seleccionados');
  }

  // ========================================================================
  // MÉTODOS PARA CATEGORÍAS
  // ========================================================================

  void toggleCategoria(String categoria) {
    if (selectedCategorias.contains(categoria)) {
      selectedCategorias.remove(categoria);
    } else {
      selectedCategorias.add(categoria);
    }
  }

  // ========================================================================
  // MÉTODOS DE VERIFICACIÓN Y DIAGNÓSTICO
  // ========================================================================

  Future<bool> verificarSaludBaseDatos() async {
    print('🏥 === VERIFICACIÓN DE SALUD DE BD ===');

    try {
      final usuarios = await usuarioUseCase.getUsuarios();
      print('👥 Total usuarios en BD: ${usuarios.length}');

      final currentUser = authController.currentUser.value;
      if (currentUser == null) {
        print('❌ No hay usuario logueado');
        return false;
      }

      // Contar usuarios con el mismo email
      final usuariosConMismoEmail = usuarios
          .where(
            (u) =>
                u.email.toLowerCase().trim() ==
                currentUser.email.toLowerCase().trim(),
          )
          .toList();

      print(
        '📧 Usuarios con email "${currentUser.email}": ${usuariosConMismoEmail.length}',
      );

      if (usuariosConMismoEmail.length > 1) {
        print(
          '⚠️ ADVERTENCIA: ${usuariosConMismoEmail.length} usuarios con el mismo email',
        );

        for (int i = 0; i < usuariosConMismoEmail.length; i++) {
          final u = usuariosConMismoEmail[i];
          print('  ${i + 1}. ID: ${u.id}, Nombre: ${u.nombre}, Rol: ${u.rol}');
        }

        // Mostrar diálogo de advertencia
        final continuar = await Get.dialog<bool>(
          AlertDialog(
            title: Text('Usuarios Duplicados Detectados'),
            content: Text(
              'Se encontraron ${usuariosConMismoEmail.length} usuarios con tu email. '
              'Esto puede causar problemas. ¿Deseas continuar?',
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Get.back(result: true),
                child: Text('Continuar'),
              ),
            ],
          ),
        );

        return continuar ?? false;
      }

      // Verificar que el usuario actual tenga ID válido
      if (currentUser.id == null || currentUser.id! <= 0) {
        print('⚠️ Usuario actual sin ID válido: ${currentUser.id}');
        return false;
      }

      print('✅ BD está saludable para crear curso');
      return true;
    } catch (e) {
      print('❌ Error verificando BD: $e');
      return false;
    }
  }

  Future<void> diagnosticarUsuariosDuplicados() async {
    print('\n🔍 === DIAGNÓSTICO DE USUARIOS DUPLICADOS ===');

    try {
      final usuarios = await usuarioUseCase.getUsuarios();
      print('📊 Total usuarios en BD: ${usuarios.length}');

      // Agrupar por email
      final usuariosPorEmail = <String, List<Usuario>>{};
      for (final usuario in usuarios) {
        final email = usuario.email.toLowerCase().trim();
        usuariosPorEmail.putIfAbsent(email, () => []).add(usuario);
      }

      // Mostrar duplicados
      bool hayDuplicados = false;
      usuariosPorEmail.forEach((email, listaUsuarios) {
        if (listaUsuarios.length > 1) {
          hayDuplicados = true;
          print('⚠️ DUPLICADO - Email: $email');
          for (int i = 0; i < listaUsuarios.length; i++) {
            final u = listaUsuarios[i];
            print(
              '  ${i + 1}. ID: ${u.id}, Nombre: ${u.nombre}, Rol: ${u.rol}, AuthID: ${u.authUserId}',
            );
          }
        }
      });

      if (!hayDuplicados) {
        print('✅ No se encontraron usuarios duplicados');
      }

      // Mostrar usuario actual del controlador
      print('\n👤 Usuario actual en AuthController:');
      final currentUser = authController.currentUser.value;
      if (currentUser != null) {
        print('  - ID: ${currentUser.id}');
        print('  - Nombre: ${currentUser.nombre}');
        print('  - Email: ${currentUser.email}');
        print('  - Rol: ${currentUser.rol}');
        print('  - AuthID: ${currentUser.authUserId}');
      } else {
        print('  - No hay usuario actual');
      }
    } catch (e) {
      print('❌ Error en diagnóstico: $e');
    }

    print('=== FIN DIAGNÓSTICO ===\n');
  }

  Future<void> limpiarUsuariosDuplicados() async {
    print('🧹 === LIMPIANDO USUARIOS DUPLICADOS ===');

    try {
      final usuarios = await usuarioUseCase.getUsuarios();
      final usuariosPorEmail = <String, List<Usuario>>{};

      // Agrupar por email
      for (final usuario in usuarios) {
        final email = usuario.email.toLowerCase().trim();
        usuariosPorEmail.putIfAbsent(email, () => []).add(usuario);
      }

      // Eliminar duplicados (mantener el que tenga ID más reciente)
      int eliminados = 0;
      for (final entry in usuariosPorEmail.entries) {
        final listaUsuarios = entry.value;

        if (listaUsuarios.length > 1) {
          // Ordenar por ID (mantener el más reciente)
          listaUsuarios.sort((a, b) => (b.id ?? 0).compareTo(a.id ?? 0));

          // Eliminar todos excepto el primero
          for (int i = 1; i < listaUsuarios.length; i++) {
            final usuarioAEliminar = listaUsuarios[i];
            if (usuarioAEliminar.id != null) {
              try {
                final usuarioRepo = Get.find<UsuarioRepository>();
                await usuarioRepo.deleteUsuario(usuarioAEliminar.id!);
                eliminados++;
                print(
                  '🗑️ Eliminado: ${usuarioAEliminar.nombre} (ID: ${usuarioAEliminar.id})',
                );
              } catch (e) {
                print('❌ Error eliminando usuario ${usuarioAEliminar.id}: $e');
              }
            }
          }
        }
      }

      print('✅ Limpieza completada. Usuarios eliminados: $eliminados');

      // Recargar estudiantes después de la limpieza
      await cargarEstudiantes();
    } catch (e) {
      print('❌ Error en limpieza: $e');
    }

    print('=== FIN LIMPIEZA ===\n');
  }

  // ========================================================================
  // MÉTODO PRINCIPAL PARA CREAR CURSO (SIMPLIFICADO)
  // ========================================================================

  Future<bool> crearCurso() async {
    print('🔐 === INICIANDO CREACIÓN DE CURSO ===');

    // PRIMERA VERIFICACIÓN: Salud de BD
    if (!await verificarSaludBaseDatos()) {
      print('❌ Verificación de BD falló - Abortando creación');
      Get.snackbar(
        'Error de Base de Datos',
        'Se detectaron problemas en la base de datos. No se puede crear el curso.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    // Validaciones del formulario
    if (nombreCurso.value.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'El nombre del curso es obligatorio',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    if (descripcion.value.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'La descripción del curso es obligatoria',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    if (!validarCodigoRegistro()) {
      return false;
    }

    try {
      isLoading.value = true;

      // PASO 1: Obtener usuario con ID válido
      int? userId = await _garantizarUsuarioConId();

      if (userId == null) {
        Get.snackbar(
          'Error de Usuario',
          'No se pudo verificar tu perfil de profesor. Contacta al administrador.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: Duration(seconds: 4),
        );
        return false;
      }

      print('✅ Usuario profesor confirmado con ID: $userId');

      // PASO 2: Crear el curso
      final totalEstudiantes = estudiantesSeleccionados.length;
      final estudiantesNombres = estudiantesSeleccionados
          .map((e) => e.nombre)
          .toList();

      print('📚 Creando curso:');
      print('  - Nombre: ${nombreCurso.value.trim()}');
      print('  - Profesor ID: $userId');
      print('  - Código: ${codigoRegistro.value.trim()}');
      print('  - Estudiantes: ${estudiantesNombres.join(", ")}');

      final cursoId = await cursoUseCase.createCurso(
        nombre: nombreCurso.value.trim(),
        descripcion: descripcion.value.trim(),
        profesorId: userId,
        codigoRegistro: codigoRegistro.value.trim(),
        categorias: selectedCategorias.toList(),
        estudiantesNombres: estudiantesNombres,
      );

      print('✅ Curso creado con ID: $cursoId');

      // PASO 3: Inscribir estudiantes automáticamente
      await _inscribirEstudiantesAutomaticamente(cursoId);

      // PASO 4: Refrescar datos y limpiar formulario
      try {
        final homeController = Get.find<HomeController>();
        await homeController.refreshData();
        print('✅ HomeController actualizado');
      } catch (e) {
        print('⚠️ No se pudo actualizar HomeController: $e');
      }

      _limpiarFormulario();

      // Mensaje único y completo al final
      final estudiantesText = totalEstudiantes > 0
          ? " con $totalEstudiantes estudiante(s) inscritos"
          : "";

      Get.snackbar(
        '¡Curso Creado Exitosamente!',
        'Curso "${nombreCurso.value}" creado con código "${codigoRegistro.value}"$estudiantesText.',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );

      return true;
    } catch (e) {
      print('❌ Error completo en crearCurso: $e');

      Get.snackbar(
        'Error',
        'Error al crear curso: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 5),
      );
      return false;
    } finally {
      isLoading.value = false;
      print('=== FIN CREACIÓN DE CURSO ===\n');
    }
  }

  // ========================================================================
  // MÉTODO SIMPLIFICADO PARA GARANTIZAR USUARIO CON ID
  // ========================================================================

  Future<int?> _garantizarUsuarioConId() async {
    print('🔍 === GARANTIZANDO USUARIO CON ID ===');

    final currentUser = authController.currentUser.value;
    if (currentUser == null) {
      print('❌ No hay usuario logueado');
      return null;
    }

    print('👤 Usuario actual: ${currentUser.nombre} (${currentUser.email})');
    print('💳 ID actual: ${currentUser.id}');

    // PASO 1: Si ya tiene un ID válido, usarlo directamente
    if (currentUser.id != null && currentUser.id! > 0) {
      print('✅ Usuario ya tiene ID válido: ${currentUser.id}');
      return currentUser.id!;
    }

    print('⚠️ Usuario sin ID válido - Buscando en BD...');

    try {
      final usuarioRepo = Get.find<UsuarioRepository>();

      // PASO 2: Buscar usuario existente por email (MÁS CONFIABLE)
      Usuario? usuarioExistente;
      try {
        usuarioExistente = await usuarioRepo.getUsuarioByEmail(
          currentUser.email.toLowerCase().trim(),
        );
        if (usuarioExistente?.id != null && usuarioExistente!.id! > 0) {
          print('✅ Encontrado por email con ID: ${usuarioExistente.id}');

          // Actualizar el usuario en el controlador auth
          authController.currentUser.value = usuarioExistente;
          return usuarioExistente.id!;
        }
      } catch (e) {
        print('⚠️ Error buscando por email: $e');
      }

      // PASO 3: Buscar por authUserId como fallback
      if (usuarioExistente == null && currentUser.authUserId != null) {
        try {
          final todosUsuarios = await usuarioRepo.getUsuarios();
          usuarioExistente = todosUsuarios.firstWhereOrNull(
            (u) =>
                u.authUserId == currentUser.authUserId &&
                u.id != null &&
                u.id! > 0,
          );

          if (usuarioExistente != null) {
            print('✅ Encontrado por authUserId con ID: ${usuarioExistente.id}');

            // Actualizar el usuario en el controlador auth
            authController.currentUser.value = usuarioExistente;
            return usuarioExistente.id!;
          }
        } catch (e) {
          print('⚠️ Error buscando por authUserId: $e');
        }
      }

      // PASO 4: SOLO crear si NO existe y es profesor
      if (usuarioExistente == null) {
        print('❌ Usuario NO encontrado en BD');

        // Verificar que sea profesor antes de crear
        if (currentUser.rol != 'profesor') {
          print('❌ Usuario no es profesor, no se puede crear curso');
          Get.snackbar(
            'Error',
            'Solo los profesores pueden crear cursos. Tu rol actual: ${currentUser.rol}',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          return null;
        }

        print('🆕 Creando nuevo usuario profesor...');

        // VERIFICACIÓN FINAL antes de crear (prevenir duplicados)
        final verificacionFinal = await usuarioRepo.getUsuarioByEmail(
          currentUser.email.toLowerCase().trim(),
        );
        if (verificacionFinal != null &&
            verificacionFinal.id != null &&
            verificacionFinal.id! > 0) {
          print('⚠️ PREVENCIÓN: Usuario encontrado en verificación final');
          authController.currentUser.value = verificacionFinal;
          return verificacionFinal.id!;
        }

        try {
          final nuevoId = await usuarioRepo.createUsuario(currentUser);

          if (nuevoId != null && nuevoId > 0) {
            currentUser.id = nuevoId;
            authController.currentUser.value = currentUser;

            print('✅ Usuario creado exitosamente con ID: $nuevoId');

            // Solo mensaje si es realmente necesario para el usuario
            // Get.snackbar removido para evitar saturación de mensajes

            return nuevoId;
          } else {
            print('❌ Repository devolvió ID inválido: $nuevoId');

            // Generar ID temporal como último recurso
            final tempId = DateTime.now().millisecondsSinceEpoch % 0x7FFFFFFF;
            final finalId = tempId == 0 ? 1 : tempId;
            currentUser.id = finalId;

            print('🔧 Usando ID temporal: $finalId');

            // Mensaje removido - solo log para debug
            // Get.snackbar removido para evitar saturación

            return finalId;
          }
        } catch (e) {
          print('❌ Error creando usuario: $e');

          // Último recurso: ID temporal
          final tempId = DateTime.now().millisecondsSinceEpoch % 0x7FFFFFFF;
          final finalId = tempId == 0 ? 1 : tempId;
          currentUser.id = finalId;

          print('🔧 Fallback: ID temporal: $finalId');

          Get.snackbar(
            'Error al Crear Usuario',
            'Se usará un perfil temporal. Error: ${e.toString()}',
            backgroundColor: Colors.red,
            colorText: Colors.white,
            duration: Duration(seconds: 5),
          );

          return finalId;
        }
      }
    } catch (e) {
      print('❌ Error general en garantizar usuario: $e');
      return null;
    }

    print('❌ No se pudo garantizar usuario con ID');
    return null;
  }

  // ========================================================================
  // MÉTODO PARA INSCRIBIR ESTUDIANTES AUTOMÁTICAMENTE
  // ========================================================================

  // REEMPLAZA el método _inscribirEstudiantesAutomaticamente en NewCourseController

  Future<void> _inscribirEstudiantesAutomaticamente(int cursoId) async {
    if (estudiantesSeleccionados.isEmpty) {
      print('📝 No hay estudiantes para inscribir');
      return;
    }

    try {
      print(
        '👥 Inscribiendo ${estudiantesSeleccionados.length} estudiantes...',
      );

      // OPCIÓN 1: Usar el código que ya tenemos en lugar de buscar el curso
      final codigoCurso = codigoRegistro.value.trim();

      if (codigoCurso.isEmpty) {
        print('❌ No hay código de registro disponible');
        throw Exception('Código de registro no disponible');
      }

      print('📋 Usando código de registro: $codigoCurso');

      int exitosos = 0;
      int fallidos = 0;

      // Inscribir cada estudiante seleccionado
      for (final estudiante in estudiantesSeleccionados) {
        if (estudiante.id != null) {
          try {
            print(
              '🔄 Inscribiendo a ${estudiante.nombre} (ID: ${estudiante.id}) en curso $codigoCurso',
            );

            await cursoUseCase.inscribirseEnCurso(estudiante.id!, codigoCurso);
            exitosos++;
            print('✅ ${estudiante.nombre} inscrito correctamente');
          } catch (e) {
            fallidos++;
            print('❌ Error inscribiendo a ${estudiante.nombre}: $e');
          }
        } else {
          fallidos++;
          print('❌ ${estudiante.nombre} no tiene ID válido');
        }
      }

      print('📊 Inscripciones: $exitosos exitosas, $fallidos fallidas');

      if (fallidos > 0) {
        Get.snackbar(
          'Inscripciones Parciales',
          '$exitosos estudiantes inscritos, $fallidos fallaron. Revisa manualmente.',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: Duration(seconds: 4),
        );
      } else if (exitosos > 0) {
        print('✅ Todos los estudiantes inscritos correctamente');
        // Mensaje simplificado y combinado con el mensaje principal del curso
      }
    } catch (e) {
      print('⚠️ Error en inscripciones automáticas: $e');
      Get.snackbar(
        'Error en Inscripciones',
        'El curso se creó correctamente pero las inscripciones fallaron. Puedes inscribir a los estudiantes manualmente usando el código: ${codigoRegistro.value}',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        duration: Duration(seconds: 6),
      );
    }
  }

  // ========================================================================
  // MÉTODO PARA LIMPIAR FORMULARIO
  // ========================================================================

  void _limpiarFormulario() {
    print('🧹 Limpiando formulario...');
    nombreCurso.value = '';
    descripcion.value = '';
    codigoRegistro.value = '';
    selectedCategorias.clear();
    estudiantesSeleccionados.clear();
    searchQuery.value = '';
    filtrarEstudiantes();
    print('✅ Formulario limpio');
  }

  // ========================================================================
  // GETTERS Y UTILIDADES
  // ========================================================================

  int get totalEstudiantesDisponibles => estudiantesDisponibles.length;
  int get totalEstudiantesSeleccionados => estudiantesSeleccionados.length;

  bool get hayEstudiantesSeleccionados => estudiantesSeleccionados.isNotEmpty;
  bool get hayEstudiantesDisponibles => estudiantesDisponibles.isNotEmpty;

  String get resumenSeleccion {
    if (estudiantesSeleccionados.isEmpty) {
      return 'No hay estudiantes seleccionados';
    }
    return '${estudiantesSeleccionados.length} estudiante(s) seleccionado(s)';
  }

  void generarCodigoAleatorio() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    final codigo = String.fromCharCodes(
      Iterable.generate(
        6,
        (_) => chars.codeUnitAt(random.nextInt(chars.length)),
      ),
    );
    codigoRegistro.value = codigo;
  }

  bool validarCodigoRegistro() {
    if (codigoRegistro.value.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'El código de registro es obligatorio',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    if (codigoRegistro.value.trim().length < 4) {
      Get.snackbar(
        'Error',
        'El código debe tener al menos 4 caracteres',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    return true;
  }

  // ========================================================================
  // MÉTODOS DE DEBUG ADICIONALES (para UI)
  // ========================================================================

  void mostrarEstadisticas() {
    print('\n📊 === ESTADÍSTICAS DE ESTUDIANTES ===');
    print('🔢 Contadores:');
    print('  - Total en BD: ${todosLosEstudiantes.length}');
    print('  - Disponibles para mostrar: ${estudiantesDisponibles.length}');
    print('  - Seleccionados: ${estudiantesSeleccionados.length}');
    print('🔍 Estado de búsqueda:');
    print('  - Query: "${searchQuery.value}"');
    print('  - Query length: ${searchQuery.value.length}');
    print('  - Loading: ${isLoadingStudents.value}');

    print('\n👥 Estudiantes en BD:');
    if (todosLosEstudiantes.isNotEmpty) {
      for (var i = 0; i < todosLosEstudiantes.length; i++) {
        final est = todosLosEstudiantes[i];
        print('  ${i + 1}. ${est.nombre} (${est.email}) - ID: ${est.id}');
      }
    } else {
      print('  ❌ Lista vacía');
    }

    print('\n📋 Estudiantes disponibles para UI:');
    if (estudiantesDisponibles.isNotEmpty) {
      for (var i = 0; i < estudiantesDisponibles.length; i++) {
        final est = estudiantesDisponibles[i];
        print('  ${i + 1}. ${est.nombre} (${est.email})');
      }
    } else {
      print('  ❌ Lista vacía');
    }

    if (estudiantesSeleccionados.isNotEmpty) {
      print('\n✅ Estudiantes seleccionados:');
      for (var i = 0; i < estudiantesSeleccionados.length; i++) {
        final est = estudiantesSeleccionados[i];
        print('  ${i + 1}. ${est.nombre} (${est.email})');
      }
    }
    print('=== FIN ESTADÍSTICAS ===\n');
  }

  void debugBusqueda() {
    print('\n🔍 === DEBUG BÚSQUEDA ===');
    print('searchQuery.value: "${searchQuery.value}"');
    print('searchQuery.value.length: ${searchQuery.value.length}');
    print(
      'searchQuery.value.trim().isEmpty: ${searchQuery.value.trim().isEmpty}',
    );
    print('estudiantesDisponibles.length: ${estudiantesDisponibles.length}');
    print('=== FIN DEBUG BÚSQUEDA ===\n');
  }
}
