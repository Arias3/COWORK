// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/category_controller.dart';
import '../../../activities/presentation/controllers/activity_controller.dart';
import '../../domain/entities/category.dart';
import '../../../activities/domain/models/activity.dart';

class CategoryFormPage extends StatefulWidget {
  final Category? category;

  const CategoryFormPage({super.key, this.category});

  @override
  State<CategoryFormPage> createState() => _CategoryFormPageState();
}

class _CategoryFormPageState extends State<CategoryFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _maxMembersController = TextEditingController();
  MetodoAgrupacion? _selectedMethod;

  late final CategoryController categoryController;
  late final ActivityController activityController;

  @override
  void initState() {
    super.initState();
    categoryController = Get.find<CategoryController>();
    activityController = Get.find<ActivityController>();

    if (widget.category != null) {
      _nameController.text = widget.category!.nombre;
      _maxMembersController.text = widget.category!.maxMiembros.toString();
      _selectedMethod = widget.category!.metodoAgrupacion;
    }
  }

  @override
  Widget build(BuildContext context) {
    // 🔹 Filtrar actividades de esta categoría
    final List<Activity> activities = widget.category == null
        ? []
        : activityController.activities
              .where((a) => a.categoryId == widget.category!.id)
              .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.category == null ? 'Nueva Categoría' : 'Editar Categoría',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nombre
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre de la categoría',
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Ingrese un nombre' : null,
              ),
              const SizedBox(height: 16),

              // Método de agrupación
              DropdownButtonFormField<MetodoAgrupacion>(
                value: _selectedMethod,
                items: MetodoAgrupacion.values.map((method) {
                  return DropdownMenuItem(
                    value: method,
                    child: Text(
                      method.name,
                    ), // "random", "selfAssigned", "manual"
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedMethod = value;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Método de agrupación',
                ),
                validator: (value) =>
                    value == null ? 'Seleccione un método' : null,
              ),
              const SizedBox(height: 16),

              // Máx. miembros
              TextFormField(
                controller: _maxMembersController,
                decoration: const InputDecoration(
                  labelText: 'Máx. miembros por grupo',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Ingrese un número';
                  if (int.tryParse(value) == null)
                    return 'Ingrese un número válido';
                  return null;
                },
              ),
              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final category = Category(
                      id: widget.category?.id,
                      cursoId: widget.category?.cursoId ?? 1, // ⚠️ temporal
                      nombre: _nameController.text,
                      metodoAgrupacion: _selectedMethod!,
                      maxMiembros: int.parse(_maxMembersController.text),
                    );

                    if (widget.category == null) {
                      await categoryController.addCategory(category);
                    } else {
                      await categoryController.editCategory(category);
                    }
                    Get.back();
                  }
                },
                child: Text(widget.category == null ? 'Crear' : 'Guardar'),
              ),
              const SizedBox(height: 20),

              // 🔹 Mostrar actividades asociadas a la categoría
              if (widget.category != null) ...[
                const Divider(),
                Text(
                  "Actividades",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: activities.isEmpty
                      ? const Text("No hay actividades aún")
                      : ListView.builder(
                          itemCount: activities.length,
                          itemBuilder: (context, index) {
                            final activity = activities[index];
                            return Card(
                              child: ListTile(
                                title: Text(activity.name),
                                subtitle: Text(activity.description),
                                onTap: () {
                                  Get.toNamed(
                                    '/addactivity', // ✅ usa la misma página, cambia solo el argumento
                                    arguments: {
                                      "categoryId": widget.category!.id,
                                      "activity": activity,
                                    },
                                  );
                                },
                              ),
                            );
                          },
                        ),
                ),
              ],
            ],
          ),
        ),
      ),
      // 🔹 Botón para agregar actividad si la categoría existe
      floatingActionButton: widget.category != null
          ? FloatingActionButton(
              onPressed: () {
                Get.toNamed(
                  '/addactivity',
                  arguments: {"categoryId": widget.category!.id},
                );
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
