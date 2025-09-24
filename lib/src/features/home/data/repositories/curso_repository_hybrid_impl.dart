import '../../domain/entities/curso_entity.dart';
import '../../domain/repositories/curso_repository.dart';
import '../../../../../core/data/database/hive_helper.dart';
import '../../../../../core/data/datasources/roble_api_datasource.dart';
import '../models/roble_curso_dto.dart';

class CursoRepositoryHybridImpl implements CursoRepository {
  final RobleApiDataSource _robleDataSource = RobleApiDataSource();
  static const String tableName = 'cursos';

  // ========================================================================
  // MAPEO DE IDs MEJORADO - BIDIRECCIONAL
  // ========================================================================
  static final Map<String, int> _robleToLocal = {}; // String Roble -> int local
  static final Map<int, String> _localToRoble = {}; // int local -> String Roble

  void _guardarMapeoId(String robleId, int localId) {
    try {
      _robleToLocal[robleId] = localId;
      _localToRoble[localId] = robleId;
      print('📋 [HYBRID] Mapeo ID guardado: "$robleId" <-> $localId');
    } catch (e) {
      print('⚠️ [HYBRID] Error guardando mapeo: $e');
    }
  }

  String? _obtenerRobleIdOriginal(int localId) {
    return _localToRoble[localId];
  }

  int? _obtenerLocalIdFromRoble(String robleId) {
    return _robleToLocal[robleId];
  }

  // ========================================================================
  // CREAR CURSO - ARREGLADO PARA MANEJAR IDs DE ROBLE
  // ========================================================================
  @override
  Future<int> createCurso(CursoDomain curso) async {
    try {
      print('🔍 [HYBRID] Creando curso: ${curso.nombre}');
      
      // 1. INTENTAR GUARDAR PRIMERO EN ROBLE
      print('🌐 [HYBRID] Intentando guardar en Roble...');
      final dto = RobleCursoDto.fromEntity(curso);
      final robleResponse = await _robleDataSource.create(tableName, dto.toJson());
      
      print('🔵 [HYBRID] Respuesta de Roble: $robleResponse (tipo: ${robleResponse.runtimeType})');
      
      // NUEVA LÓGICA PARA EXTRAER Y CONVERTIR ID
      final robleId = _extraerIdDeRespuestaRoble(robleResponse);
      
      if (robleId != null && robleId > 0) {
        print('✅ [HYBRID] Roble exitoso con ID: $robleId');
        
        try {
          // 2. GUARDAR EN CACHE LOCAL CON EL ID CONVERTIDO
          final cursoConId = CursoDomain(
            id: robleId,
            nombre: curso.nombre,
            descripcion: curso.descripcion,
            profesorId: curso.profesorId,
            codigoRegistro: curso.codigoRegistro,
            creadoEn: curso.creadoEn,
            categorias: curso.categorias,
            imagen: curso.imagen,
            estudiantesNombres: curso.estudiantesNombres,
            isOfflineOnly: false,
          );
          
          final hiveBox = HiveHelper.cursosBoxInstance;
          await hiveBox.put(robleId, cursoConId);
          await hiveBox.flush();
          
          print('💾 [HYBRID] También guardado en cache con ID: $robleId');
          
        } catch (hiveError) {
          print('⚠️ [HYBRID] Error en cache (no crítico): $hiveError');
          // No lanzar error - Roble funcionó y eso es lo importante
        }
        
        return robleId;
        
      } else {
        print('❌ [HYBRID] Roble no devolvió ID válido');
        throw Exception('Roble no devolvió un ID válido');
      }
      
    } catch (robleError) {
      print('❌ [HYBRID] Error en Roble: $robleError');
      print('📴 [HYBRID] Guardando en modo offline...');
      
      // 3. FALLBACK: GUARDAR SOLO EN HIVE CON ID TEMPORAL
      final hiveBox = HiveHelper.cursosBoxInstance;
      
      // Generar ID temporal único y válido para Hive
      final tempId = _generarIdTemporalValido(hiveBox);
      
      if (tempId <= 0 || tempId > 0xFFFFFFFF) {
        throw Exception('ID temporal fuera de rango válido: $tempId');
      }
      
      final cursoOffline = CursoDomain(
        id: tempId,
        nombre: curso.nombre,
        descripcion: curso.descripcion,
        profesorId: curso.profesorId,
        codigoRegistro: curso.codigoRegistro,
        creadoEn: curso.creadoEn,
        categorias: curso.categorias,
        imagen: curso.imagen,
        estudiantesNombres: curso.estudiantesNombres,
        isOfflineOnly: true,
      );
      
      await hiveBox.put(tempId, cursoOffline);
      await hiveBox.flush();
      
      print('💾 [HYBRID] Guardado offline con ID temporal: $tempId');
      return tempId;
    }
  }

  // ========================================================================
  // MÉTODO PARA EXTRAER ID DE RESPUESTA DE ROBLE
  // ========================================================================
  int? _extraerIdDeRespuestaRoble(dynamic response) {
    try {
      print('🔍 [HYBRID] Extrayendo ID de respuesta Roble...');
      
      if (response == null) {
        print('❌ [HYBRID] Respuesta es null');
        return null;
      }
      
      // Caso 1: Respuesta es directamente un objeto curso con _id
      if (response is Map<String, dynamic> && response.containsKey('_id')) {
        final rawId = response['_id'];
        print('🔍 [HYBRID] ID extraído directamente: $rawId');
        return _convertirAIdValido(rawId);
      }
      
      // Caso 2: Respuesta es directamente un Map con 'id'
      if (response is Map<String, dynamic> && response.containsKey('id')) {
        return _convertirAIdValido(response['id']);
      }
      
      // Caso 3: Respuesta tiene estructura {inserted: [...]}
      if (response is Map<String, dynamic> && response.containsKey('inserted')) {
        final inserted = response['inserted'];
        
        if (inserted is List && inserted.isNotEmpty) {
          final firstItem = inserted.first;
          
          if (firstItem is Map<String, dynamic>) {
            // Buscar _id primero, luego id
            final rawId = firstItem['_id'] ?? firstItem['id'];
            
            if (rawId != null) {
              print('🔍 [HYBRID] ID extraído de inserted: $rawId');
              return _convertirAIdValido(rawId);
            }
          }
        }
      }
      
      // Caso 4: Respuesta es directamente un string/int ID
      return _convertirAIdValido(response);
      
    } catch (e) {
      print('❌ [HYBRID] Error extrayendo ID: $e');
      return null;
    }
  }

  // ========================================================================
  // MÉTODO PARA CONVERTIR CUALQUIER TIPO A ID VÁLIDO
  // ========================================================================
  int? _convertirAIdValido(dynamic rawId) {
    try {
      if (rawId == null) return null;
      
      print('🔄 [HYBRID] Convirtiendo ID: $rawId (tipo: ${rawId.runtimeType})');
      
      // Si ya es un entero válido
      if (rawId is int && rawId > 0 && rawId <= 0xFFFFFFFF) {
        print('✅ [HYBRID] ID ya válido: $rawId');
        return rawId;
      }
      
      // Si es string, convertir usando hashCode
      if (rawId is String && rawId.isNotEmpty) {
        // ✅ VERIFICAR SI YA EXISTE MAPEO
        final existingLocalId = _obtenerLocalIdFromRoble(rawId);
        if (existingLocalId != null) {
          print('✅ [HYBRID] Usando mapeo existente: "$rawId" -> $existingLocalId');
          return existingLocalId;
        }
        
        final hashCode = rawId.hashCode;
        
        // Asegurar que esté en rango válido (positivo y dentro del límite de Hive)
        final validId = hashCode.abs() % 0x7FFFFFFF;
        final finalId = validId == 0 ? 1 : validId; // Evitar 0
        
        print('✅ [HYBRID] String convertido: "$rawId" -> $finalId');
        
        // Guardar mapeo para referencia futura
        _guardarMapeoId(rawId, finalId);
        
        return finalId;
      }
      
      // Si es número pero fuera de rango, normalizar
      if (rawId is num) {
        final normalizedId = rawId.abs().toInt() % 0x7FFFFFFF;
        final finalId = normalizedId == 0 ? 1 : normalizedId;
        
        print('✅ [HYBRID] Número normalizado: $rawId -> $finalId');
        return finalId;
      }
      
      print('❌ [HYBRID] No se pudo convertir ID: $rawId');
      return null;
      
    } catch (e) {
      print('❌ [HYBRID] Error en conversión: $e');
      return null;
    }
  }

  // ========================================================================
  // MÉTODO PARA GENERAR ID TEMPORAL VÁLIDO
  // ========================================================================
  int _generarIdTemporalValido(dynamic hiveBox) {
    try {
      // Usar timestamp pero asegurar que esté en rango válido
      var tempId = DateTime.now().millisecondsSinceEpoch % 0x7FFFFFFF;
      
      // Asegurar que no sea 0 y que no colisione con IDs existentes
      while (tempId <= 0 || (hiveBox.containsKey != null && hiveBox.containsKey(tempId))) {
        tempId = (tempId + 1) % 0x7FFFFFFF;
        if (tempId == 0) tempId = 1;
      }
      
      print('🔢 [HYBRID] ID temporal generado: $tempId');
      return tempId;
      
    } catch (e) {
      print('❌ [HYBRID] Error generando ID temporal, usando fallback');
      // Fallback a un ID simple basado en timestamp
      return (DateTime.now().millisecondsSinceEpoch % 1000000) + 1;
    }
  }

  // ========================================================================
  // OBTENER CURSOS - SIN CAMBIOS MAYORES
  // ========================================================================
  @override
  Future<List<CursoDomain>> getCursos() async {
    try {
      print('🌐 [HYBRID] Obteniendo cursos de Roble...');
      final robleData = await _robleDataSource.getAll(tableName);
      final cursosRoble = robleData.map((json) => RobleCursoDto.fromJson(json).toEntity()).toList();
      
      if (cursosRoble.isNotEmpty) {
        print('✅ [ROBLE] ${cursosRoble.length} cursos obtenidos');
        await _syncHiveCacheWithRoble(cursosRoble);
        
        final cursosOffline = await _getOfflineCursos();
        print('📴 [OFFLINE] ${cursosOffline.length} cursos offline encontrados');
        
        return [...cursosRoble, ...cursosOffline];
      } else {
        throw Exception('No hay cursos en Roble');
      }
      
    } catch (e) {
      print('❌ [ROBLE] Error: $e');
      print('📱 [HYBRID] Usando cache local...');
      
      final hiveBox = HiveHelper.cursosBoxInstance;
      return hiveBox.values.toList();
    }
  }

  // ========================================================================
  // BUSCAR POR CÓDIGO - SIN CAMBIOS MAYORES  
  // ========================================================================
  @override
  Future<CursoDomain?> getCursoByCodigoRegistro(String codigo) async {
    final codigoLimpio = codigo.trim();
    print('🔍 [HYBRID] Buscando curso con código: "$codigoLimpio"');
    
    try {
      final robleData = await _robleDataSource.getWhere(tableName, 'codigo_registro', codigoLimpio);
      
      if (robleData.isNotEmpty) {
        final cursoRoble = RobleCursoDto.fromJson(robleData.first).toEntity();
        print('✅ [ROBLE] Curso encontrado: "${cursoRoble.nombre}" (ID: ${cursoRoble.id})');
        
        final hiveBox = HiveHelper.cursosBoxInstance;
        await hiveBox.put(cursoRoble.id, cursoRoble);
        await hiveBox.flush();
        
        return cursoRoble;
      }
    } catch (e) {
      print('❌ [ROBLE] Error buscando en servidor: $e');
    }
    
    print('📱 [HYBRID] Buscando en cache local...');
    final hiveBox = HiveHelper.cursosBoxInstance;
    
    final cursosLocales = hiveBox.values.where((curso) => 
      curso.codigoRegistro.trim().toLowerCase() == codigoLimpio
    ).toList();
    
    if (cursosLocales.isNotEmpty) {
      final cursoLocal = cursosLocales.first;
      print('✅ [HIVE] Curso encontrado en cache: "${cursoLocal.nombre}"');
      return cursoLocal;
    }
    
    print('❌ [HYBRID] No se encontró curso con código: "$codigo"');
    return null;
  }

  // ========================================================================
  // MÉTODOS DE SINCRONIZACIÓN - SIN CAMBIOS MAYORES
  // ========================================================================
  Future<void> _syncHiveCacheWithRoble(List<CursoDomain> cursosRoble) async {
    final hiveBox = HiveHelper.cursosBoxInstance;
    
    final cursosOffline = hiveBox.values.where((curso) => curso.isOfflineOnly == true).toList();
    await hiveBox.clear();
    
    for (var curso in cursosRoble) {
      curso.isOfflineOnly = false;
      await hiveBox.put(curso.id, curso);
    }
    
    for (var cursoOffline in cursosOffline) {
      await hiveBox.put(cursoOffline.id, cursoOffline);
    }
    
    await hiveBox.flush();
    print('🔄 [SYNC] Cache actualizado: ${cursosRoble.length} sincronizados, ${cursosOffline.length} offline');
  }

  Future<List<CursoDomain>> _getOfflineCursos() async {
    final hiveBox = HiveHelper.cursosBoxInstance;
    return hiveBox.values.where((curso) => curso.isOfflineOnly == true).toList();
  }

  Future<void> syncOfflineCursos() async {
    print('🔄 [SYNC] Iniciando sincronización de cursos offline...');
    
    final cursosOffline = await _getOfflineCursos();
    if (cursosOffline.isEmpty) {
      print('✅ [SYNC] No hay cursos offline para sincronizar');
      return;
    }
    
    print('📴 [SYNC] Sincronizando ${cursosOffline.length} cursos offline...');
    
    for (var cursoOffline in cursosOffline) {
      try {
        final dto = RobleCursoDto.fromEntity(cursoOffline);
        final robleResponse = await _robleDataSource.create(tableName, dto.toJson());
        final serverCursoId = _extraerIdDeRespuestaRoble(robleResponse);
        
        if (serverCursoId != null && serverCursoId > 0) {
          final hiveBox = HiveHelper.cursosBoxInstance;
          
          await hiveBox.delete(cursoOffline.id);
          
          cursoOffline.id = serverCursoId;
          cursoOffline.isOfflineOnly = false;
          await hiveBox.put(serverCursoId, cursoOffline);
          await hiveBox.flush();
          
          print('✅ [SYNC] "${cursoOffline.nombre}" sincronizado (ID: ${cursoOffline.id} → $serverCursoId)');
        }
        
      } catch (e) {
        print('❌ [SYNC] Error sincronizando "${cursoOffline.nombre}": $e');
      }
    }
    
    print('🏁 [SYNC] Sincronización completada');
  }

  // ========================================================================
  // ✅ MÉTODOS CORREGIDOS - PRINCIPALES CAMBIOS AQUÍ
  // ========================================================================
  @override
Future<List<CursoDomain>> getCursosPorProfesor(int profesorId) async {
  try {
    print('🔍 [HYBRID] Obteniendo cursos del profesor: $profesorId');
    
    final data = await _robleDataSource.getWhere(tableName, 'profesor_id', profesorId);
    print('📊 [HYBRID] Datos recibidos de Roble: ${data.length} cursos');
    
    final cursos = <CursoDomain>[];
    final hiveBox = HiveHelper.cursosBoxInstance; // ✅ OBTENER BOX AQUÍ
    
    for (var json in data) {
      try {
        print('🔄 [HYBRID] Procesando curso desde Roble...');
        print('   JSON: $json');
        
        // APLICAR LA MISMA LÓGICA DE CONVERSIÓN DE ID QUE EN createCurso
        final curso = _mapJsonToCursoWithCorrectId(json);
        
        if (curso != null) {
          cursos.add(curso);
          
          // ✅ GUARDAR CADA CURSO EN CACHE INMEDIATAMENTE
          await hiveBox.put(curso.id, curso);
          print('💾 [HYBRID] Curso guardado en cache: ${curso.nombre} (ID: ${curso.id})');
          print('✅ [HYBRID] Curso mapeado: ${curso.nombre} (ID: ${curso.id})');
        } else {
          print('❌ [HYBRID] Error mapeando curso');
        }
        
      } catch (e) {
        print('❌ [HYBRID] Error procesando curso individual: $e');
      }
    }
    
    // ✅ FLUSH AL FINAL PARA ASEGURAR PERSISTENCIA
    await hiveBox.flush();
    
    print('📈 [HYBRID] Total cursos procesados: ${cursos.length}');
    return cursos;
    
  } catch (e) {
    print('❌ [ROBLE] Error obteniendo cursos del profesor: $e');
    print('📱 [HYBRID] Usando cache local...');
    
    final hiveBox = HiveHelper.cursosBoxInstance;
    final cursosLocales = hiveBox.values.where((curso) => curso.profesorId == profesorId).toList();
    
    print('📦 [HYBRID] Cursos locales encontrados: ${cursosLocales.length}');
    return cursosLocales;
  }
}

  @override
Future<List<CursoDomain>> getCursosInscritos(int usuarioId) async {
  try {
    print('🔍 [HYBRID] Obteniendo cursos inscritos para usuario: $usuarioId');
    
    final inscripciones = await _robleDataSource.getWhere('inscripciones', 'usuario_id', usuarioId);
    print('📊 [HYBRID] Inscripciones encontradas: ${inscripciones.length}');
    
    final cursos = <CursoDomain>[];
    for (var inscripcion in inscripciones) {
      try {
        final cursoRobleId = inscripcion['curso_id']; // ✅ Este es el string original
        print('🔍 [HYBRID] Obteniendo curso con Roble ID: $cursoRobleId');
        
        // ✅ CAMBIO CRÍTICO: Buscar por ID de Roble (string), no por ID convertido
        final cursoData = await _robleDataSource.getById(tableName, cursoRobleId);
        if (cursoData != null) {
          final curso = _mapJsonToCursoWithCorrectId(cursoData);
          if (curso != null) {
            cursos.add(curso);
            print('✅ [HYBRID] Curso inscrito mapeado: ${curso.nombre} (ID local: ${curso.id})');
          }
        }
      } catch (e) {
        print('❌ [HYBRID] Error procesando curso inscrito: $e');
      }
    }
    
    print('📈 [HYBRID] Total cursos inscritos: ${cursos.length}');
    return cursos;
    
  } catch (e) {
    print('❌ [ROBLE] Error obteniendo cursos inscritos: $e');
    print('📱 [HYBRID] Usando cache local...');
    
    final inscripcionesBox = HiveHelper.inscripcionesBoxInstance;
    final cursosBox = HiveHelper.cursosBoxInstance;
    
    final inscripciones = inscripcionesBox.values
        .where((inscripcion) => inscripcion.usuarioId == usuarioId)
        .toList();
    
    final cursos = <CursoDomain>[];
    for (var inscripcion in inscripciones) {
      final curso = cursosBox.get(inscripcion.cursoId);
      if (curso != null) cursos.add(curso);
    }
    
    print('📦 [HYBRID] Cursos inscritos locales: ${cursos.length}');
    return cursos;
  }
}

// ✅ MÉTODO MÁS CRÍTICO - ESTE ES EL QUE NECESITA MAYOR CAMBIO
@override
Future<CursoDomain?> getCursoById(int localId) async {
  try {
    print('🔍 [HYBRID] Obteniendo curso por ID local: $localId');
    
    // ✅ CAMBIO CRÍTICO: Obtener el ID original de Roble usando el mapeo
    final robleId = _obtenerRobleIdOriginal(localId);
    
    if (robleId != null) {
      print('🔄 [HYBRID] Buscando en Roble con ID original: $robleId');
      final data = await _robleDataSource.getById(tableName, robleId);
      
      if (data != null) {
        final curso = _mapJsonToCursoWithCorrectId(data);
        print('✅ [HYBRID] Curso encontrado en Roble: ${curso?.nombre}');
        return curso;
      }
    } else {
      print('⚠️ [HYBRID] No se encontró mapeo para ID local: $localId');
      
      // ✅ FALLBACK: Intentar buscar en Roble con todos los cursos del profesor
      // (esto es menos eficiente pero funciona si no hay mapeo)
      print('🔄 [HYBRID] Buscando en todos los cursos...');
      final allCursos = await getCursos();
      final cursoEncontrado = allCursos.where((c) => c.id == localId).firstOrNull;
      
      if (cursoEncontrado != null) {
        print('✅ [HYBRID] Curso encontrado en lista completa: ${cursoEncontrado.nombre}');
        return cursoEncontrado;
      }
    }
    
  } catch (e) {
    print('❌ [ROBLE] Error obteniendo curso por ID: $e');
  }
  
  print('📱 [HYBRID] Buscando en cache local...');
  final box = HiveHelper.cursosBoxInstance;
  final cursoLocal = box.get(localId);
  
  if (cursoLocal != null) {
    print('✅ [HYBRID] Curso encontrado en cache: ${cursoLocal.nombre}');
  } else {
    print('❌ [HYBRID] Curso no encontrado en cache');
  }
  
  return cursoLocal;
}

  @override
  Future<void> updateCurso(CursoDomain curso) async {
    try {
      if (curso.isOfflineOnly != true) {
        // ✅ OBTENER ID ORIGINAL DE ROBLE PARA ACTUALIZACIÓN
        final robleId = _obtenerRobleIdOriginal(curso.id);
        if (robleId != null) {
          final dto = RobleCursoDto.fromEntity(curso);
          await _robleDataSource.update(tableName, robleId, dto.toJson());
          print('✅ [HYBRID] Curso actualizado en Roble con ID: $robleId');
        } else {
          print('⚠️ [HYBRID] No se pudo obtener ID de Roble para actualización');
        }
      }
    } catch (e) {
      print('❌ [ROBLE] Error actualizando curso: $e');
    }
    
    final box = HiveHelper.cursosBoxInstance;
    await box.put(curso.id, curso);
    await box.flush();
  }

  @override
  Future<void> deleteCurso(int localId) async {
    try {
      final hiveBox = HiveHelper.cursosBoxInstance;
      final curso = hiveBox.get(localId);
      
      if (curso?.isOfflineOnly != true) {
        // ✅ OBTENER ID ORIGINAL DE ROBLE PARA ELIMINACIÓN
        final robleId = _obtenerRobleIdOriginal(localId);
        if (robleId != null) {
          final inscripciones = await _robleDataSource.getWhere('inscripciones', 'curso_id', robleId);
          for (var inscripcion in inscripciones) {
            await _robleDataSource.delete('inscripciones', inscripcion['_id'] ?? inscripcion['id']);
          }
          await _robleDataSource.delete(tableName, robleId);
          print('✅ [HYBRID] Curso eliminado de Roble con ID: $robleId');
        }
      }
    } catch (e) {
      print('❌ [ROBLE] Error eliminando curso: $e');
    }
    
    final box = HiveHelper.cursosBoxInstance;
    await box.delete(localId);
    await box.flush();
    
    final inscripcionesBox = HiveHelper.inscripcionesBoxInstance;
    final inscripcionesAEliminar = inscripcionesBox.values
        .where((inscripcion) => inscripcion.cursoId == localId)
        .map((inscripcion) => inscripcion.id!)
        .toList();
    
    for (var inscripcionId in inscripcionesAEliminar) {
      await inscripcionesBox.delete(inscripcionId);
    }
    await inscripcionesBox.flush();
  }

  // ========================================================================
  // MÉTODO HELPER MEJORADO
  // ========================================================================
  CursoDomain? _mapJsonToCursoWithCorrectId(Map<String, dynamic> json) {
    try {
      print('🔄 [HYBRID] Mapeando JSON a curso...');
      print('   - JSON keys: ${json.keys}');
      
      // Extraer y convertir el ID usando la misma lógica
      final rawId = json['_id'] ?? json['id'];
      final convertedId = _convertirAIdValido(rawId);
      
      if (convertedId == null || convertedId <= 0) {
        print('❌ [HYBRID] ID inválido después de conversión: $convertedId');
        return null;
      }
      
      // Crear el curso usando RobleCursoDto pero con ID corregido
      final dto = RobleCursoDto.fromJson(json);
      var curso = dto.toEntity();
      
      // FORZAR el ID correcto
      curso.id = convertedId;
      
      print('✅ [HYBRID] Curso mapeado correctamente:');
      print('   - Nombre: ${curso.nombre}');
      print('   - ID original: $rawId');
      print('   - ID convertido: $convertedId');
      
      return curso;
      
    } catch (e) {
      print('❌ [HYBRID] Error en mapeo: $e');
      return null;
    }
  }
}