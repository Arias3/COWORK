import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../../domain/entities/curso_entity.dart';
import './new_course_page.dart';
import './estudiante_curso_detalle_page.dart';
import '../../../auth/presentation/services/auth_service.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
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
              child: Text(
                (controller.authService.currentUser != null &&
                        controller.authService.currentUser!.nombre.isNotEmpty)
                    ? controller.authService.currentUser!.nombre[0]
                          .toUpperCase()
                    : 'U',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
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
                    controller.authService.currentUser?.nombre ?? 'Usuario',
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        // Usar Builder para acceder al MediaQuery
        Builder(
          builder: (context) {
            final isSmallScreen = MediaQuery.of(context).size.width < 400;

            if (isSmallScreen) {
              // En pantallas pequeñas, usar PopupMenuButton
              return PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.grey),
                onSelected: (value) async {
                  switch (value) {
                    case 'notifications':
                      Get.snackbar(
                        'Notificaciones',
                        'No tienes notificaciones nuevas',
                        backgroundColor: Colors.blue,
                        colorText: Colors.white,
                        icon: const Icon(
                          Icons.notifications,
                          color: Colors.white,
                        ),
                      );
                      break;
                    case 'refresh':
                      controller.refreshData();
                      break;
                    case 'logout':
                      final authService = Get.find<AuthService>();
                      await authService.logout();
                      Get.offAllNamed('/local-login');
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'notifications',
                    child: Row(
                      children: [
                        Icon(Icons.notifications_outlined, color: Colors.grey),
                        SizedBox(width: 8),
                        Text('Notificaciones'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'refresh',
                    child: Obx(
                      () => Row(
                        children: [
                          controller.isLoadingDictados.value ||
                                  controller.isLoadingInscritos.value
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.refresh, color: Colors.blue),
                          const SizedBox(width: 8),
                          const Text('Actualizar'),
                        ],
                      ),
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Cerrar sesión'),
                      ],
                    ),
                  ),
                ],
              );
            } else {
              // En pantallas grandes, mostrar todos los botones
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.notifications_outlined,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      Get.snackbar(
                        'Notificaciones',
                        'No tienes notificaciones nuevas',
                        backgroundColor: Colors.blue,
                        colorText: Colors.white,
                        icon: const Icon(
                          Icons.notifications,
                          color: Colors.white,
                        ),
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
                          : const Icon(Icons.refresh, color: Colors.blue),
                      onPressed: controller.refreshData,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout, color: Colors.red),
                    onPressed: () async {
                      final authService = Get.find<AuthService>();
                      await authService.logout();
                      Get.offAllNamed('/local-login');
                    },
                    tooltip: 'Cerrar sesión',
                  ),
                ],
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildBody(HomeController controller) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 600;
        final padding = isSmallScreen ? 12.0 : 16.0;
        final spacing = isSmallScreen ? 16.0 : 24.0;

        return SingleChildScrollView(
          padding: EdgeInsets.all(padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeCard(controller),
              SizedBox(height: spacing),
              _buildStatsRow(controller),
              SizedBox(height: spacing),
              _buildTabBar(controller),
              const SizedBox(height: 16),
              _buildTabContent(controller),
            ],
          ),
        );
      },
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 600;

        if (isSmallScreen) {
          // En pantallas pequeñas, usar Column con 2 filas
          return Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Obx(
                      () => _buildStatCard(
                        title: 'Dictados',
                        value: controller.dictados.length.toString(),
                        icon: Icons.school,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Obx(
                      () => _buildStatCard(
                        title: 'Inscritos',
                        value: controller.inscritos.length.toString(),
                        icon: Icons.library_books,
                        color: Colors.green,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FutureBuilder<int>(
                  future: _getTotalEstudiantesReales(controller),
                  builder: (context, snapshot) {
                    return _buildStatCard(
                      title: 'Estudiantes',
                      value: snapshot.data?.toString() ?? '...',
                      icon: Icons.people,
                      color: Colors.orange,
                    );
                  },
                ),
              ),
            ],
          );
        } else {
          // En pantallas grandes, usar Row horizontal
          return Row(
            children: [
              Expanded(
                child: Obx(
                  () => _buildStatCard(
                    title: 'Dictados',
                    value: controller.dictados.length.toString(),
                    icon: Icons.school,
                    color: Colors.blue,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Obx(
                  () => _buildStatCard(
                    title: 'Inscritos',
                    value: controller.inscritos.length.toString(),
                    icon: Icons.library_books,
                    color: Colors.green,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FutureBuilder<int>(
                  future: _getTotalEstudiantesReales(controller),
                  builder: (context, snapshot) {
                    return _buildStatCard(
                      title: 'Estudiantes',
                      value: snapshot.data?.toString() ?? '...',
                      icon: Icons.people,
                      color: Colors.orange,
                    );
                  },
                ),
              ),
            ],
          );
        }
      },
    );
  }

  Future<int> _getTotalEstudiantesReales(HomeController controller) async {
    int total = 0;
    for (var curso in controller.dictados) {
      final numEstudiantes = await controller.getNumeroEstudiantesReales(
        curso.id!,
      );
      total += numEstudiantes;
    }
    return total;
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
              onAction: () {
                Get.to(() => NewCoursePage());
              },
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
              onAction: () => _mostrarDialogoInscripcion(controller),
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
    List<CursoDomain> cursos,
    HomeController controller, {
    required bool isDictado,
  }) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: isDictado
            ? 0.56
            : 0.75, // Ajuste final para eliminar esos 2.3px
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
    CursoDomain curso,
    HomeController controller, {
    required bool isDictado,
  }) {
    return GestureDetector(
      onTap: () {
        if (!isDictado) {
          // Navegar a la página de detalles del curso para estudiantes
          Get.to(() => EstudianteCursoDetallePage(curso: curso));
        }
      },
      onLongPress: () =>
          _mostrarMenuCurso(curso, controller, isEstudiante: !isDictado),
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
            // Header con imagen y menú (sin cambios)
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
                    Container(
                      width: double.infinity,
                      height: double.infinity,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: isDictado
                                  ? [Colors.blue[300]!, Colors.purple[300]!]
                                  : [Colors.green[300]!, Colors.teal[300]!],
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
                    if (isDictado)
                      Positioned(
                        top: 12,
                        right: 12,
                        child: GestureDetector(
                          onTap: () => _mostrarMenuCurso(curso, controller),
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
                    if (curso.descripcion.isNotEmpty)
                      Text(
                        curso.descripcion,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const Spacer(),
                    // ✅ ACTUALIZADO: Footer con contador real de estudiantes
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // ✅ Estudiantes con número real
                        Row(
                          children: [
                            Icon(
                              Icons.people,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            FutureBuilder<int>(
                              future: controller.getNumeroEstudiantesReales(
                                curso.id!,
                              ),
                              builder: (context, snapshot) {
                                return Text(
                                  '${snapshot.data ?? '...'}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        // Categorías
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
                    // Botón de gestionar equipos (solo para dictados)
                    if (isDictado) ...[
                      const SizedBox(
                        height: 6,
                      ), // Reducido a 6 para eliminar overflow final
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () =>
                              controller.abrirGestionEquipos(curso),
                          icon: const Icon(
                            Icons.groups,
                            size: 14,
                          ), // Reducido de 16 a 14
                          label: const Text(
                            'Gestionar Equipos',
                            style: TextStyle(
                              fontSize: 11,
                            ), // Reducido de 12 a 11
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.blue,
                            side: const BorderSide(
                              color: Colors.blue,
                              width: 1,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(
                              vertical:
                                  4, // Reducido a 4 para eliminar overflow final
                              horizontal: 10, // Reducido de 12 a 10
                            ),
                            minimumSize: const Size(
                              0,
                              24,
                            ), // Altura mínima aún más pequeña
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarMenuCurso(
    CursoDomain curso,
    HomeController controller, {
    bool isEstudiante = false,
  }) {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    curso.nombre,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (!isEstudiante) ...[
                    // Opciones para profesores
                    ListTile(
                      leading: const Icon(Icons.edit, color: Colors.blue),
                      title: const Text('Editar Curso'),
                      onTap: () {
                        Get.back();
                        Get.snackbar(
                          'Información',
                          'Funcionalidad de edición próximamente',
                          backgroundColor: Colors.orange,
                          colorText: Colors.white,
                        );
                      },
                    ),
                  ],
                  ListTile(
                    leading: const Icon(Icons.people, color: Colors.green),
                    title: Text(
                      isEstudiante ? 'Ver Compañeros' : 'Ver Estudiantes',
                    ),
                    subtitle: FutureBuilder<int>(
                      future: controller.getNumeroEstudiantesReales(curso.id!),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Text('Cargando...');
                        }
                        final numEstudiantes = snapshot.data ?? 0;
                        return Text(
                          '$numEstudiantes estudiante(s) inscrito(s)',
                        );
                      },
                    ),
                    onTap: () {
                      Get.back();
                      _mostrarEstudiantes(curso);
                    },
                  ),
                  if (!isEstudiante) ...[
                    // Solo para profesores
                    ListTile(
                      leading: const Icon(Icons.share, color: Colors.purple),
                      title: const Text('Compartir Código'),
                      subtitle: Text('Código: ${curso.codigoRegistro}'),
                      onTap: () {
                        Get.back();
                        Get.snackbar(
                          'Código de Registro',
                          'Código: ${curso.codigoRegistro}',
                          backgroundColor: Colors.purple,
                          colorText: Colors.white,
                          duration: const Duration(seconds: 5),
                        );
                      },
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.delete, color: Colors.red),
                      title: const Text('Eliminar Curso'),
                      onTap: () {
                        Get.back();
                        controller.eliminarCurso(curso);
                      },
                    ),
                  ] else ...[
                    // Para estudiantes - opción de desinscribirse
                    const Divider(),
                    ListTile(
                      leading: const Icon(
                        Icons.exit_to_app,
                        color: Colors.orange,
                      ),
                      title: const Text('Desinscribirse'),
                      onTap: () {
                        Get.back();
                        _mostrarDialogoDesinscripcion(curso, controller);
                      },
                    ),
                  ],
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarDialogoDesinscripcion(
    CursoDomain curso,
    HomeController controller,
  ) {
    Get.dialog(
      AlertDialog(
        title: const Text('Confirmar'),
        content: Text(
          '¿Estás seguro de que quieres desinscribirte del curso "${curso.nombre}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              // Aquí iría la lógica para desinscribirse
              Get.snackbar(
                'Información',
                'Funcionalidad de desinscripción próximamente',
                backgroundColor: Colors.orange,
                colorText: Colors.white,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text(
              'Desinscribirse',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _mostrarEstudiantes(CursoDomain curso) {
    final controller = Get.find<HomeController>();
    controller.mostrarEstudiantesReales(curso);
  }

  void _mostrarDialogoInscripcion(HomeController controller) {
    final TextEditingController codigoController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.login, color: Colors.green),
            const SizedBox(width: 8),
            const Text('Inscribirse a Curso'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Ingresa el código de registro del curso:'),
            const SizedBox(height: 16),
            TextField(
              controller: codigoController,
              decoration: const InputDecoration(
                labelText: 'Código de registro',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.key),
              ),
              textCapitalization: TextCapitalization.characters,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              if (codigoController.text.trim().isEmpty) {
                Get.snackbar(
                  'Error',
                  'Por favor ingresa un código de registro',
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
                return;
              }
              Get.back();
              controller.inscribirseEnCurso(codigoController.text.trim());
            },
            child: const Text('Inscribirse'),
          ),
        ],
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

  Widget? _buildFloatingActionButton(HomeController controller) {
    return Obx(
      () => AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: controller.selectedTab.value == 0
            ? FloatingActionButton.extended(
                key: const ValueKey('dictados'),
                onPressed: () {
                  Get.to(() => NewCoursePage());
                },
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                icon: const Icon(Icons.add),
                label: const Text('Crear Curso'),
                elevation: 8,
              )
            : FloatingActionButton.extended(
                key: const ValueKey('inscritos'),
                onPressed: () => _mostrarDialogoInscripcion(controller),
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
