import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/new_course_controller.dart';
import '../../../auth/presentation/controllers/roble_auth_login_controller.dart';

class NewCoursePage extends StatelessWidget {
  const NewCoursePage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<NewCourseController>(
      init: Get.find<NewCourseController>(), // Forzar inicialización
      builder: (controller) {
        print('UI: Controlador obtenido: ${controller.runtimeType}');
        return Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: _buildAppBar(),
          body: _buildBody(controller),
          floatingActionButton: _buildFloatingActionButton(controller),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black87),
        onPressed: () => Get.back(),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.add_circle, color: Colors.blue, size: 24),
          ),
          const SizedBox(width: 12),
          const Text(
            'Crear Nuevo Curso',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(NewCourseController controller) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeCard(),
          const SizedBox(height: 24),
          _buildFormCard(controller),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[600]!, Colors.purple[500]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Nuevo Curso',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Completa la información para crear tu curso',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard(NewCourseController controller) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildNameSection(controller),
          const SizedBox(height: 24),
          _buildDescriptionSection(controller),
          const SizedBox(height: 24),
          _buildRegistrationCodeSection(controller),
          const SizedBox(height: 24),
          _buildCategoriesSection(controller),
          const SizedBox(height: 24),
          _buildStudentsSection(controller),
        ],
      ),
    );
  }

  Widget _buildNameSection(NewCourseController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.book, color: Colors.blue, size: 20),
            const SizedBox(width: 8),
            const Text(
              'Nombre del curso',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const Text(' *', style: TextStyle(color: Colors.red, fontSize: 16)),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          onChanged: (value) => controller.nombreCurso.value = value,
          decoration: InputDecoration(
            hintText: 'Ej: Curso de Flutter Avanzado',
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.blue, width: 2),
            ),
            contentPadding: const EdgeInsets.all(16),
            prefixIcon: const Icon(Icons.edit, color: Colors.grey),
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionSection(NewCourseController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.description, color: Colors.green, size: 20),
            const SizedBox(width: 8),
            const Text(
              'Descripción',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          onChanged: (value) => controller.descripcion.value = value,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Describe de qué trata tu curso...',
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.green, width: 2),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoriesSection(NewCourseController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.category, color: Colors.purple, size: 20),
            const SizedBox(width: 8),
            const Text(
              'Categorías',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Selecciona las categorías que mejor describan tu curso:',
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
              const SizedBox(height: 12),
              Obx(
                () => Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: controller.categorias.map((categoria) {
                    final isSelected = controller.selectedCategorias.contains(
                      categoria,
                    );
                    return GestureDetector(
                      onTap: () => controller.toggleCategoria(categoria),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.purple : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? Colors.purple
                                : Colors.grey[300]!,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: Colors.purple.withOpacity(0.3),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isSelected)
                              const Icon(
                                Icons.check,
                                size: 16,
                                color: Colors.white,
                              ),
                            if (isSelected) const SizedBox(width: 4),
                            Text(
                              categoria,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.grey[700],
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 8),
              Obx(
                () => Text(
                  '${controller.selectedCategorias.length} categorías seleccionadas',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStudentsSection(NewCourseController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.people, color: Colors.orange, size: 20),
            const SizedBox(width: 8),
            const Text(
              'Estudiantes Registrados',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const Spacer(),
            // Botón para agregar por email
            TextButton.icon(
              onPressed: () => _mostrarDialogoAgregarPorEmail(controller),
              icon: const Icon(Icons.person_add, size: 16, color: Colors.green),
              label: const Text(
                'Agregar',
                style: TextStyle(fontSize: 11, color: Colors.green),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              ),
            ),
            // Botón de sincronización con RobleAuth
            Obx(() => TextButton.icon(
              onPressed: controller.isLoadingStudents.value
                  ? null
                  : () async {
                      // Mostrar un diálogo de progreso
                      Get.dialog(
                        AlertDialog(
                          title: const Text('Sincronizando con RobleAuth'),
                          content: const Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 16),
                              Text('Verificando usuarios disponibles...'),
                            ],
                          ),
                        ),
                        barrierDismissible: false,
                      );
                      
                      try {
                        await Get.find<RobleAuthLoginController>()
                            .sincronizarTodosLosUsuariosDeRobleAuth();
                        
                        await Future.delayed(const Duration(milliseconds: 500));
                        await controller.cargarEstudiantes();
                        
                        Get.back(); // Cerrar diálogo
                        
                        Get.snackbar(
                          'Sincronización Exitosa',
                          'Los usuarios se han actualizado desde RobleAuth',
                          backgroundColor: Colors.green[100],
                          colorText: Colors.green[800],
                          icon: const Icon(Icons.check_circle, color: Colors.green),
                        );
                      } catch (e) {
                        Get.back(); // Cerrar diálogo
                        
                        Get.snackbar(
                          'Información',
                          'Los usuarios se sincronizarán automáticamente al iniciar sesión',
                          backgroundColor: Colors.blue[100],
                          colorText: Colors.blue[800],
                          icon: const Icon(Icons.info, color: Colors.blue),
                          duration: const Duration(seconds: 4),
                        );
                      }
                    },
              icon: controller.isLoadingStudents.value
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        color: Colors.blue,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.sync, size: 16),
              label: Text(
                controller.isLoadingStudents.value 
                    ? 'Sincronizando...' 
                    : 'Sincronizar',
                style: const TextStyle(fontSize: 11),
              ),
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              ),
            )),
          ],
        ),
        const SizedBox(height: 12),

        // Widget informativo sobre sincronización
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue[200]!, width: 1),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue[600], size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sincronización automática habilitada',
                      style: TextStyle(
                        color: Colors.blue[800],
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Los usuarios se cargan desde RobleAuth automáticamente. Si no ves algún estudiante, usa "Sincronizar RobleAuth".',
                      style: TextStyle(
                        color: Colors.blue[700],
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Buscador mejorado
        _buildStudentSearch(controller),
        const SizedBox(height: 16),

        // Lista de estudiantes seleccionados
        _buildSelectedStudentsList(controller),
        const SizedBox(height: 16),

        // Lista de estudiantes disponibles
        _buildAvailableStudentsList(controller),
      ],
    );
  }

  Widget _buildStudentSearch(NewCourseController controller) {
    print('UI: _buildStudentSearch llamado');
    print('UI: Controller hashCode: ${controller.hashCode}');
    final searchController = TextEditingController();

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: searchController,
                  decoration: const InputDecoration(
                    hintText: 'Buscar estudiante por nombre o email...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    prefixIcon: Icon(Icons.search, color: Colors.grey),
                  ),
                  onChanged: (value) => controller.searchQuery.value = value,
                ),
              ),
              Container(
                margin: const EdgeInsets.all(4),
                child: Obx(
                  () => ElevatedButton(
                    onPressed: controller.isLoadingStudents.value
                        ? null
                        : () async {
                            await controller.cargarEstudiantes();
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      elevation: 0,
                    ),
                    child: controller.isLoadingStudents.value
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.refresh, size: 20),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Sugerencias de búsqueda
        Obx(() {
          if (controller.searchQuery.value.isEmpty ||
              controller.searchQuery.value.length < 2) {
            return const SizedBox();
          }

          final sugerencias = controller.estudiantesDisponibles
              .take(3)
              .toList();

          if (sugerencias.isEmpty) {
            return const SizedBox();
          }

          return Container(
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    'Sugerencias:',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
                ...sugerencias
                    .map(
                      (estudiante) => InkWell(
                        onTap: () {
                          controller.agregarEstudiante(estudiante);
                          searchController.clear();
                          controller.searchQuery.value = '';
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 12,
                                backgroundColor: Colors.blue.withOpacity(0.1),
                                child: Text(
                                  estudiante.nombre[0].toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.blue,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      estudiante.nombre,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      estudiante.email,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.add_circle_outline,
                                size: 16,
                                color: Colors.green,
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildSelectedStudentsList(NewCourseController controller) {
    return Obx(() {
      if (controller.estudiantesSeleccionados.isEmpty) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.grey[200]!,
              style: BorderStyle.solid,
            ),
          ),
          child: Column(
            children: [
              Icon(Icons.people_outline, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 12),
              Text(
                'No hay estudiantes seleccionados',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Sincroniza con RobleAuth y busca estudiantes registrados',
                style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Tip: Usa el botón "Sincronizar RobleAuth" para cargar todos los usuarios',
                style: TextStyle(fontSize: 12, color: Colors.blue[400], fontStyle: FontStyle.italic),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${controller.estudiantesSeleccionados.length} estudiantes seleccionados',
                  style: const TextStyle(
                    color: Colors.green,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: controller.limpiarSeleccion,
                icon: const Icon(Icons.clear_all, size: 16),
                label: const Text('Limpiar'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red,
                  textStyle: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            constraints: const BoxConstraints(maxHeight: 200),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: controller.estudiantesSeleccionados.length,
              itemBuilder: (context, index) {
                final estudiante = controller.estudiantesSeleccionados[index];
                return Container(
                  margin: const EdgeInsets.symmetric(
                    vertical: 2,
                    horizontal: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green[100]!),
                  ),
                  child: ListTile(
                    dense: true,
                    leading: CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.green.withOpacity(0.1),
                      child: Text(
                        estudiante.nombre[0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    title: Text(
                      estudiante.nombre,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(
                      estudiante.email,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.remove_circle_outline,
                        color: Colors.red,
                        size: 20,
                      ),
                      onPressed: () =>
                          controller.eliminarEstudiante(estudiante),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      );
    });
  }

  Widget _buildAvailableStudentsList(NewCourseController controller) {
    return Obx(() {
      if (controller.isLoadingStudents.value) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: const Center(
            child: Column(
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 12),
                Text('Cargando estudiantes...'),
              ],
            ),
          ),
        );
      }

      if (controller.estudiantesDisponibles.isEmpty) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.orange[200]!),
          ),
          child: Column(
            children: [
              Icon(Icons.search_off, size: 32, color: Colors.orange[600]),
              const SizedBox(height: 8),
              Text(
                controller.searchQuery.value.isEmpty
                    ? 'No hay más estudiantes disponibles'
                    : 'No se encontraron estudiantes',
                style: TextStyle(
                  color: Colors.orange[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                controller.searchQuery.value.isEmpty
                    ? 'Todos los estudiantes están seleccionados'
                    : 'Intenta con otros términos de búsqueda',
                style: TextStyle(color: Colors.orange[600], fontSize: 12),
              ),
            ],
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${controller.estudiantesDisponibles.length} estudiantes disponibles',
              style: const TextStyle(
                color: Colors.blue,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            constraints: const BoxConstraints(maxHeight: 250),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: controller.estudiantesDisponibles.length,
              itemBuilder: (context, index) {
                final estudiante = controller.estudiantesDisponibles[index];
                return Container(
                  margin: const EdgeInsets.symmetric(
                    vertical: 2,
                    horizontal: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[100]!),
                  ),
                  child: ListTile(
                    dense: true,
                    leading: CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.blue.withOpacity(0.1),
                      child: Text(
                        estudiante.nombre[0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    title: Text(
                      estudiante.nombre,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          estudiante.email,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          'Registrado: ${_formatDate(estudiante.creadoEn)}',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.add_circle_outline,
                        color: Colors.green,
                        size: 20,
                      ),
                      onPressed: () => controller.agregarEstudiante(estudiante),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      );
    });
  }

  // Función auxiliar para formatear fechas
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget? _buildFloatingActionButton(NewCourseController controller) {
    return Obx(
      () => FloatingActionButton.extended(
        onPressed: controller.isLoading.value
            ? null
            : () async {
                final success = await controller.crearCurso();
                if (success) {
                  _showSuccessDialog();
                }
              },
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        icon: controller.isLoading.value
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.check),
        label: Text(
          controller.isLoading.value ? 'Creando...' : 'Crear Curso',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 8,
      ),
    );
  }

  void _showSuccessDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 48,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              '¡Curso Creado!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Tu curso ha sido creado exitosamente',
              style: TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      Get.back(); // Cerrar diálogo
                      Get.back(); // Volver a home
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'Continuar',
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Get.back(); // Cerrar diálogo
                      Get.back(); // Volver a home
                      // Aquí podrías agregar lógica para compartir
                      Get.snackbar(
                        'Compartir',
                        'Funcionalidad de compartir próximamente',
                        backgroundColor: Colors.blue,
                        colorText: Colors.white,
                        icon: const Icon(Icons.share, color: Colors.white),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Compartir',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      barrierDismissible: false,
    );
  }

  // Add this method to your NewCoursePage class
  Widget _buildRegistrationCodeSection(NewCourseController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.vpn_key, color: Colors.purple, size: 20),
            const SizedBox(width: 8),
            const Text(
              'Código de Registro',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const Text(' *', style: TextStyle(color: Colors.red, fontSize: 16)),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Los estudiantes usarán este código para inscribirse al curso:',
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Obx(
                      () => TextField(
                        controller:
                            TextEditingController(
                                text: controller.codigoRegistro.value,
                              )
                              ..selection = TextSelection.collapsed(
                                offset: controller.codigoRegistro.value.length,
                              ),
                        onChanged: (value) => controller.codigoRegistro.value =
                            value.toUpperCase(),
                        decoration: InputDecoration(
                          hintText: 'Ej: PROG001, FLU2024',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: Colors.purple,
                              width: 2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.all(12),
                          prefixIcon: const Icon(Icons.tag, color: Colors.grey),
                        ),
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: controller.generarCodigoAleatorio,
                    icon: const Icon(Icons.shuffle, size: 16),
                    label: const Text('Generar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: Colors.blue,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Mínimo 4 caracteres. Se recomienda usar letras y números.',
                        style: TextStyle(fontSize: 12, color: Colors.blue[700]),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _mostrarDialogoAgregarPorEmail(NewCourseController controller) {
    final emailController = TextEditingController();
    
    Get.dialog(
      AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.person_add, color: Colors.green),
            SizedBox(width: 8),
            Text('Agregar Estudiante por Email'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ingresa el email del estudiante registrado en RobleAuth:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email del estudiante',
                hintText: 'ejemplo@dominio.com',
                prefixIcon: const Icon(Icons.email),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.green, width: 2),
                ),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: Colors.blue),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'El estudiante debe estar registrado en RobleAuth',
                      style: TextStyle(fontSize: 12, color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
          Obx(() => ElevatedButton(
            onPressed: controller.isLoadingStudents.value
                ? null
                : () async {
                    final email = emailController.text.trim();
                    if (email.isNotEmpty) {
                      Get.back(); // Cerrar diálogo
                      await controller.buscarEstudiantePorEmail(email);
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: controller.isLoadingStudents.value
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Buscar y Agregar'),
          )),
        ],
      ),
    );
  }
}
