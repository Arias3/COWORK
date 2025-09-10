// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      init: HomeController(),
      builder: (controller) => Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: _buildAppBar(controller),
        body: _buildBody(controller),
        floatingActionButton: _buildFloatingActionButton(controller),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(HomeController controller) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      title: Obx(
        () => Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: Colors.blue.withOpacity(0.1),
              child: controller.userAvatar.value.isNotEmpty
                  ? ClipOval(
                      child: Image.asset(
                        controller.userAvatar.value,
                        width: 44,
                        height: 44,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Text(
                            controller.userName.value[0].toUpperCase(),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          );
                        },
                      ),
                    )
                  : Text(
                      controller.userName.value[0].toUpperCase(),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '¡Hola!',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                Text(
                  controller.userName.value,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: Colors.grey),
          onPressed: () {
            Get.snackbar(
              'Notificaciones',
              'No tienes notificaciones nuevas',
              backgroundColor: Colors.blue,
              colorText: Colors.white,
              icon: const Icon(Icons.notifications, color: Colors.white),
            );
          },
        ),
        Obx(
          () => IconButton(
            icon:
                controller.isLoadingDictados.value ||
                    controller.isLoadingInscritos.value
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh, color: Colors.grey),
            onPressed: controller.refreshData,
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildBody(HomeController controller) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeCard(controller),
          const SizedBox(height: 24),
          _buildStatsRow(controller),
          const SizedBox(height: 24),
          _buildTabBar(controller),
          const SizedBox(height: 16),
          _buildTabContent(controller),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard(HomeController controller) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
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
                    Text(
                      'Tu Panel de Cursos',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Gestiona tus cursos dictados e inscritos de manera fácil y eficiente',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(Icons.school, color: Colors.white, size: 32),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(HomeController controller) {
    return Obx(
      () => Row(
        children: [
          Expanded(
            child: _buildStatCard(
              title: 'Dictados',
              value: controller.dictados.length.toString(),
              icon: Icons.school,
              color: Colors.blue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              title: 'Inscritos',
              value: controller.inscritos.length.toString(),
              icon: Icons.library_books,
              color: Colors.green,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              title: 'Estudiantes',
              value: controller.dictados
                  .fold(0, (sum, curso) => sum + curso.estudiantes)
                  .toString(),
              icon: Icons.people,
              color: Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(HomeController controller) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(25),
      ),
      child: Obx(
        () => Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => controller.changeTab(0),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: controller.selectedTab.value == 0
                        ? Colors.blue
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: controller.selectedTab.value == 0
                        ? [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.school,
                        size: 18,
                        color: controller.selectedTab.value == 0
                            ? Colors.white
                            : Colors.grey[600],
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Dictados',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: controller.selectedTab.value == 0
                              ? Colors.white
                              : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => controller.changeTab(1),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: controller.selectedTab.value == 1
                        ? Colors.green
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: controller.selectedTab.value == 1
                        ? [
                            BoxShadow(
                              color: Colors.green.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.library_books,
                        size: 18,
                        color: controller.selectedTab.value == 1
                            ? Colors.white
                            : Colors.grey[600],
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Inscritos',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: controller.selectedTab.value == 1
                              ? Colors.white
                              : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent(HomeController controller) {
    return Obx(() {
      switch (controller.selectedTab.value) {
        case 0:
          return _buildDictadosSection(controller);
        case 1:
          return _buildInscritosSection(controller);
        default:
          return _buildDictadosSection(controller);
      }
    });
  }

  Widget _buildDictadosSection(HomeController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Cursos Dictados',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            Obx(
              () => Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${controller.dictados.length} cursos',
                  style: const TextStyle(
                    color: Colors.blue,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Obx(() {
          if (controller.isLoadingDictados.value) {
            return _buildLoadingGrid();
          }

          if (controller.dictados.isEmpty) {
            return _buildEmptyState(
              icon: Icons.school_outlined,
              title: 'No hay cursos dictados',
              subtitle: 'Crea tu primer curso para comenzar a enseñar',
              actionText: 'Crear Curso',
              onAction: controller.crearCurso,
              color: Colors.blue,
            );
          }

          return _buildCursosGrid(
            controller.dictados,
            controller,
            isDictado: true,
          );
        }),
      ],
    );
  }

  Widget _buildInscritosSection(HomeController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Cursos Inscritos',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            Obx(
              () => Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${controller.inscritos.length} cursos',
                  style: const TextStyle(
                    color: Colors.green,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Obx(() {
          if (controller.isLoadingInscritos.value) {
            return _buildLoadingGrid();
          }

          if (controller.inscritos.isEmpty) {
            return _buildEmptyState(
              icon: Icons.library_books_outlined,
              title: 'No estás inscrito en cursos',
              subtitle: 'Explora y únete a cursos interesantes para aprender',
              actionText: 'Explorar Cursos',
              onAction: controller.inscribirse,
              color: Colors.green,
            );
          }

          return _buildCursosGrid(
            controller.inscritos,
            controller,
            isDictado: false,
          );
        }),
      ],
    );
  }

  Widget _buildCursosGrid(
    List<Curso> cursos,
    HomeController controller, {
    required bool isDictado,
  }) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: cursos.length,
      itemBuilder: (context, index) {
        final curso = cursos[index];
        return _buildCursoCard(curso, controller, isDictado: isDictado);
      },
    );
  }

  Widget _buildCursoCard(
    Curso curso,
    HomeController controller, {
    required bool isDictado,
  }) {
    return GestureDetector(
      onTap: () {
        if (!isDictado) {
          Get.snackbar(
            'Información',
            'Funcionalidad de detalles próximamente',
            backgroundColor: Colors.orange,
            colorText: Colors.white,
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con imagen y menú
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  gradient: LinearGradient(
                    colors: isDictado
                        ? [
                            Colors.blue.withOpacity(0.8),
                            Colors.purple.withOpacity(0.8),
                          ]
                        : [
                            Colors.green.withOpacity(0.8),
                            Colors.teal.withOpacity(0.8),
                          ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    // Imagen de fondo
                    SizedBox(
                      width: double.infinity,
                      height: double.infinity,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                        child: curso.imagen.isNotEmpty
                            ? Image.asset(
                                curso.imagen,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: isDictado
                                            ? [
                                                Colors.blue[300]!,
                                                Colors.purple[300]!,
                                              ]
                                            : [
                                                Colors.green[300]!,
                                                Colors.teal[300]!,
                                              ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Icons.school,
                                        size: 40,
                                        color: Colors.white,
                                      ),
                                    ),
                                  );
                                },
                              )
                            : Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: isDictado
                                        ? [
                                            Colors.blue[300]!,
                                            Colors.purple[300]!,
                                          ]
                                        : [
                                            Colors.green[300]!,
                                            Colors.teal[300]!,
                                          ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.school,
                                    size: 40,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                      ),
                    ),
                    // Overlay gradient
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.7),
                          ],
                        ),
                      ),
                    ),
                    // Menú de tres puntos (solo para dictados)
                    if (isDictado)
                      Positioned(
                        top: 12,
                        right: 12,
                        child: GestureDetector(
                          onTap: () =>
                              controller.mostrarMenuCurso(curso, Get.context!),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.more_vert,
                              size: 20,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),
                    // Badge de estado
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isDictado ? Colors.blue : Colors.green,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          isDictado ? 'DICTADO' : 'INSCRITO',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Contenido
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título del curso
                    Text(
                      curso.nombre,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    // Descripción
                    if (curso.descripcion.isNotEmpty)
                      Text(
                        curso.descripcion,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const Spacer(),
                    // Footer con información adicional
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Estudiantes
                        Row(
                          children: [
                            Icon(
                              Icons.people,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${curso.estudiantes}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        // Categorías (primera categoría)
                        if (curso.categorias.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: isDictado
                                  ? Colors.blue.withOpacity(0.1)
                                  : Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              curso.categorias.first,
                              style: TextStyle(
                                fontSize: 10,
                                color: isDictado ? Colors.blue : Colors.green,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
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
    required String actionText,
    required VoidCallback onAction,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Icon(icon, size: 48, color: color),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onAction,
            icon: const Icon(Icons.add),
            label: Text(actionText),
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Expanded(
                flex: 3,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  child: const Center(child: CircularProgressIndicator()),
                ),
              ),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 16,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 12,
                        width: 120,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFloatingActionButton(HomeController controller) {
    return Obx(
      () => AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: controller.selectedTab.value == 0
            ? FloatingActionButton.extended(
                key: const ValueKey('dictados'),
                onPressed: controller.crearCurso,
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                icon: const Icon(Icons.add),
                label: const Text('Crear Curso'),
                elevation: 8,
              )
            : FloatingActionButton.extended(
                key: const ValueKey('inscritos'),
                onPressed: controller.inscribirse,
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                icon: const Icon(Icons.search),
                label: const Text('Buscar Cursos'),
                elevation: 8,
              ),
      ),
    );
  }
}
