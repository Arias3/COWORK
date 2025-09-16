import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/category_controller.dart';
import '../../../activities/presentation/controllers/activity_controller.dart';
import '../../domain/entities/category.dart';
import '../../../activities/presentation/pages/activityFormPage.dart';
import '../../../home/domain/entities/curso_entity.dart';
import '../../domain/entities/metodo_agrupacion.dart';

class CategoryFormPage extends StatefulWidget {
  final Category? category;
  final CursoDomain? curso;

  const CategoryFormPage({Key? key, this.curso, this.category}) : super(key: key);

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
    }

    // Intentar obtener curso (constructor primero, luego Get.arguments)
    cursoObject = widget.curso;
    if (cursoObject == null) {
      final args = Get.arguments;
      if (args != null && args is CursoDomain) cursoObject = args;
      // si en tu app envías Map {'curso': curso}, adapta: args['curso']
      if (cursoObject == null && args is Map && args['curso'] is CursoDomain) {
        cursoObject = args['curso'] as CursoDomain;
      }
    }

    cursoId = widget.category?.cursoId ?? cursoObject?.id;
    // Debug
    print('CategoryFormPage.init - category=${widget.category}, cursoObject=$cursoObject, cursoId=$cursoId');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _maxMembersController.dispose();
    super.dispose();
  }

  Future<void> _saveCategory() async {
    if (!_formKey.currentState!.validate()) {
      print('CategoryFormPage._saveCategory - formulario inválido');
      return;
    }

    if (cursoId == null) {
      Get.snackbar('Error', 'No se pudo determinar el curso asociado. Abre la página desde el curso.');
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
        print('CategoryFormPage._saveCategory - create returned id=$id');
        if (id > 0) {
          // Actualizar curso en Hive si está disponible
          if (cursoObject != null) {
            cursoObject!.categorias = List<String>.from(cursoObject!.categorias)..add(category.nombre);
            try {
              await cursoObject!.save();
            } catch (_) {
              // ignore
            }
          }
          Get.snackbar('Éxito', 'Categoría creada correctamente');
          // -------------- USE Navigator.pop para asegurar que se cierre el Navigator correcto --------------
          print('CategoryFormPage._saveCategory - pop true (create)');
          Navigator.of(context).pop(true);
          return;
        } else {
          Get.snackbar('Error', 'No se pudo crear la categoría');
          return;
        }
      } else {
        final success = await categoryController.editCategory(category);
        print('CategoryFormPage._saveCategory - update returned $success');
        if (success) {
          Get.snackbar('Éxito', 'Categoría actualizada');
          print('CategoryFormPage._saveCategory - pop true (update)');
          Navigator.of(context).pop(true);
          return;
        } else {
          Get.snackbar('Error', 'No se pudo actualizar la categoría');
          return;
        }
      }
    } catch (e, st) {
      print('CategoryFormPage._saveCategory - ERROR: $e\n$st');
      Get.snackbar('Error', 'Ocurrió un error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category == null ? 'Nueva Categoría' : 'Editar Categoría'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nombre de la categoría'),
                validator: (value) => value == null || value.isEmpty ? 'Ingrese un nombre' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<MetodoAgrupacion>(
                value: _selectedMethod,
                items: MetodoAgrupacion.values.map((m) => DropdownMenuItem(value: m, child: Text(m.name))).toList(),
                onChanged: (v) => setState(() => _selectedMethod = v),
                decoration: const InputDecoration(labelText: 'Método de agrupación'),
                validator: (value) => value == null ? 'Seleccione un método' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _maxMembersController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Máx. miembros por grupo'),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Ingrese un número';
                  if (int.tryParse(value) == null) return 'Ingrese un número válido';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _saveCategory, child: Text(widget.category == null ? 'Crear' : 'Guardar')),
              const SizedBox(height: 20),
              if (widget.category != null) ...[
                const Divider(),
                Text('Actividades', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 10),
                Expanded(
                  child: Obx(() {
                    final activities = activityController.activities.where((a) => a.categoryId == widget.category!.id).toList();
                    if (activities.isEmpty) return const Text('No hay actividades aún');
                    return ListView.builder(
                      itemCount: activities.length,
                      itemBuilder: (_, i) {
                        final act = activities[i];
                        return Card(
                          child: ListTile(
                            title: Text(act.name),
                            subtitle: Text(act.description),
                            onTap: () {
                              Get.toNamed('/addactivity', arguments: {'categoryId': widget.category!.id, 'activity': act});
                            },
                          ),
                        );
                      },
                    );
                  }),
                ),
              ],
            ],
          ),
        ),
      ),
      floatingActionButton: widget.category != null
          ? FloatingActionButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                  builder: (_) => Padding(
                    padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                    child: ActivityFormPage(categoryId: widget.category!.id!),
                  ),
                ).then((_) => activityController.getActivities());
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
