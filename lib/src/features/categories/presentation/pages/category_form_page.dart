// lib/features/categories/presentation/pages/category_form_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/category_controller.dart';
import '../../../activities/presentation/controllers/activity_controller.dart';
import '../../domain/entities/category.dart';
import '../../../activities/presentation/pages/activityFormPage.dart';
import '../../../home/domain/entities/curso_entity.dart';
import '../../domain/entities/metodo_agrupacion.dart';
import '../../../../../core/routes/app_routes.dart';

class CategoryFormPage extends StatefulWidget {
  final Category? category;
  final CursoDomain? curso;

  const CategoryFormPage({Key? key, this.curso, this.category})
    : super(key: key);

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

  CursoDomain? cursoObject;
  int? cursoId;

  @override
  void initState() {
    super.initState();
    categoryController = Get.find<CategoryController>();
    activityController = Get.find<ActivityController>();

    if (widget.category != null) {
      _nameController.text = widget.category!.nombre;
      _maxMembersController.text = widget.category!.maxMiembros.toString();
      _selectedMethod = widget.category!.metodoAgrupacion;
      activityController.getActivities(categoryId: widget.category!.id);
    }

    // Intentar obtener curso
    cursoObject = widget.curso;
    if (cursoObject == null) {
      final args = Get.arguments;
      if (args != null && args is CursoDomain) cursoObject = args;
      if (cursoObject == null && args is Map && args['curso'] is CursoDomain) {
        cursoObject = args['curso'] as CursoDomain;
      }
    }

    cursoId = widget.category?.cursoId ?? cursoObject?.id;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _maxMembersController.dispose();
    super.dispose();
  }

  Future<void> _saveCategory() async {
    if (!_formKey.currentState!.validate()) return;

    if (cursoId == null) {
      Get.snackbar('Error', 'No se pudo determinar el curso asociado.');
      return;
    }

    final category = Category(
      id: widget.category?.id,
      cursoId: cursoId!,
      nombre: _nameController.text.trim(),
      metodoAgrupacion: _selectedMethod ?? MetodoAgrupacion.random,
      maxMiembros: int.parse(_maxMembersController.text),
    );

    try {
      if (widget.category == null) {
        final id = await categoryController.addCategory(category);
        if (id > 0) {
          if (cursoObject != null) {
            cursoObject!.categorias = List<String>.from(cursoObject!.categorias)
              ..add(category.nombre);
            try {
              await cursoObject!.save();
            } catch (_) {}
          }
          Get.snackbar('Éxito', 'Categoría creada correctamente');
          Navigator.of(context).pop(true);
        } else {
          Get.snackbar('Error', 'No se pudo crear la categoría');
        }
      } else {
        final success = await categoryController.editCategory(category);
        if (success) {
          Get.snackbar('Éxito', 'Categoría actualizada');
          Navigator.of(context).pop(true);
        } else {
          Get.snackbar('Error', 'No se pudo actualizar la categoría');
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Ocurrió un error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.category != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEdit ? 'Editar Categoría' : 'Nueva Categoría',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Nombre de la categoría',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Ingrese un nombre' : null,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<MetodoAgrupacion>(
                        value: _selectedMethod,
                        items: MetodoAgrupacion.values
                            .map(
                              (m) => DropdownMenuItem(
                                value: m,
                                child: Text(m.name),
                              ),
                            )
                            .toList(),
                        onChanged: (v) => setState(() => _selectedMethod = v),
                        decoration: const InputDecoration(
                          labelText: 'Método de agrupación',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) =>
                            v == null ? 'Seleccione un método' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _maxMembersController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Máx. miembros por grupo',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Ingrese un número';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Ingrese un número válido';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _saveCategory,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: Icon(
                  isEdit ? Icons.save : Icons.check,
                  color: Colors.white,
                ),
                label: Text(
                  isEdit ? 'Guardar cambios' : 'Crear categoría',
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
              const SizedBox(height: 20),
              if (isEdit) ...[
                const Divider(),
                Text(
                  'Actividades',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 10),
                Obx(() {
                  final activities = activityController.activities
                      .where((a) => a.categoryId == widget.category!.id)
                      .toList();
                  if (activities.isEmpty) {
                    return const Text('No hay actividades aún');
                  }
                  return Column(
                    children: activities.map((act) {
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: Colors.blueAccent,
                            child: Icon(Icons.assignment, color: Colors.white),
                          ),
                          title: Text(
                            act.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(act.description),
                          onTap: () {
                            Get.toNamed(
                              AppRoutes.addActivity,
                              arguments: {
                                'categoryId': widget.category!.id,
                                'activity': act,
                              },
                            );
                          },
                        ),
                      );
                    }).toList(),
                  );
                }),
              ],
            ],
          ),
        ),
      ),
      floatingActionButton: isEdit
          ? Tooltip(
              message: "Agregar nueva actividad",
              child: FloatingActionButton(
                backgroundColor: Colors.blueAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    builder: (_) => Padding(
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom,
                      ),
                      child: ActivityFormPage(categoryId: widget.category!.id!),
                    ),
                  ).then((_) => activityController.getActivities());
                },
                child: const Icon(Icons.add, size: 28, color: Colors.white),
              ),
            )
          : null,
    );
  }
}
