import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/category_controller.dart';
import '../../domain/entities/category.dart';
import 'category_form_page.dart';

class CategoryListPage extends StatelessWidget {
  const CategoryListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CategoryController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Categorías'),
      ),
      body: Obx(() {
        if (controller.categories.isEmpty) {
          return const Center(child: Text("No hay categorías"));
        }

        return ListView.builder(
          itemCount: controller.categories.length,
          itemBuilder: (context, index) {
            final Category category = controller.categories[index];

            return ListTile(
              title: Text(category.nombre),
              subtitle: Text(
                "Método: ${category.metodoAgrupacion.name} | Máx: ${category.maxMiembros}",
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () async {
                  await controller.removeCategory(category.id!);
                },
              ),
              onTap: () {
                Get.to(() => CategoryFormPage(category: category));
              },
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(() => const CategoryFormPage());
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
