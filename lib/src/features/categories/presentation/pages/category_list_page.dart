// lib/features/categories/presentation/pages/category_list_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/category_controller.dart';
import '../../domain/entities/category.dart';
import '../../../home/domain/entities/curso_entity.dart';
import 'category_form_page.dart';

class CategoryListPage extends StatelessWidget {
  final CursoDomain? curso; // opcional: puede venir por constructor o por Get.arguments

  const CategoryListPage({Key? key, this.curso}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CategoryController>();

    // Prioridad: constructor > Get.arguments
    final CursoDomain? cursoLocal =
        curso ?? (Get.arguments is CursoDomain ? Get.arguments as CursoDomain : null);

    // Si tenemos curso, cargar las categorías de ese curso; si no, cargar todas
    if (cursoLocal != null) {
      controller.loadCategoriesByCurso(cursoLocal.id!);
    } else {
      controller.loadCategories();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          cursoLocal != null ? 'Categorías - ${cursoLocal.nombre}' : 'Categorías',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 4,
      ),
      body: Obx(() {
        if (controller.categories.isEmpty) {
          return const Center(
            child: Text(
              "No hay categorías",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: controller.categories.length,
          itemBuilder: (context, index) {
            final Category category = controller.categories[index];

            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 3,
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                leading: CircleAvatar(
                  backgroundColor: Colors.blueAccent,
                  radius: 24,
                  child: const Icon(Icons.category, color: Colors.white, size: 24),
                ),
                title: Text(
                  category.nombre,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    "Método: ${category.metodoAgrupacion.name}\nMáx. miembros: ${category.maxMiembros}",
                    style: TextStyle(color: Colors.grey[700], fontSize: 14),
                  ),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    final success = await controller.removeCategory(category.id!);
                    if (success) {
                      Get.snackbar("Éxito", "Categoría eliminada correctamente");
                      if (cursoLocal != null) {
                        await controller.loadCategoriesByCurso(cursoLocal.id!);
                      } else {
                        await controller.loadCategories();
                      }
                    } else {
                      Get.snackbar("Error", "No se pudo eliminar la categoría");
                    }
                  },
                ),
                onTap: () async {
                  if (cursoLocal != null) {
                    final result = await Get.to(
                      () => CategoryFormPage(curso: cursoLocal, category: category),
                    );
                    if (result == true) {
                      await controller.loadCategoriesByCurso(cursoLocal.id!);
                    }
                  } else {
                    final result = await Get.to(
                      () => CategoryFormPage(category: category),
                    );
                    if (result == true) {
                      await controller.loadCategories();
                    }
                  }
                },
              ),
            );
          },
        );
      }),
      floatingActionButton: Tooltip(
        message: "Agregar nueva categoría",
        child: FloatingActionButton(
          backgroundColor: Colors.blueAccent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          onPressed: () async {
            if (cursoLocal != null) {
              final result = await Get.to(
                () => CategoryFormPage(curso: cursoLocal),
              );
              if (result == true) {
                // recargar categorías al volver
                await controller.loadCategoriesByCurso(cursoLocal.id!);
              }
            } else {
              Get.snackbar(
                'Info',
                'Abre la lista desde un curso para crear una categoría ligada.',
              );
            }
          },
          child: const Icon(Icons.add, size: 28, color: Colors.white),
        ),
      ),
    );
  }
}
