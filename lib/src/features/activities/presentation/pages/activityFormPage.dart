import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../activities/domain/models/activity.dart';
import '../controllers/activity_controller.dart';

class ActivityFormPage extends StatefulWidget {
  final int categoryId;
  final Activity? activity;

  const ActivityFormPage({
    super.key,
    required this.categoryId,
    this.activity,
  });

  @override
  State<ActivityFormPage> createState() => _ActivityFormPageState();
}

class _ActivityFormPageState extends State<ActivityFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController nameController;
  late TextEditingController descController;
  DateTime? deliveryDate;

  final activityController = Get.find<ActivityController>();

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.activity?.name ?? '');
    descController = TextEditingController(text: widget.activity?.description ?? '');
    deliveryDate = widget.activity?.deliveryDate ?? DateTime.now();
  }

  @override
  void dispose() {
    nameController.dispose();
    descController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: deliveryDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => deliveryDate = picked);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      if (widget.activity == null) {
        await activityController.addActivity(
          widget.categoryId,
          nameController.text.trim(),
          descController.text.trim(),
          deliveryDate ?? DateTime.now(),
        );
        Get.snackbar("Éxito", "Actividad creada correctamente");
      } else {
        final updated = widget.activity!.copyWith(
          categoryId: widget.activity!.categoryId,
          name: nameController.text.trim(),
          description: descController.text.trim(),
          deliveryDate: deliveryDate ?? widget.activity!.deliveryDate,
        );
        await activityController.updateActivity(updated);
        Get.snackbar("Éxito", "Actividad actualizada correctamente");
      }

      Navigator.of(context).pop(true);
    } catch (e) {
      Get.snackbar("Error", "Ocurrió un error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.activity != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? '✏️ Editar Actividad' : '📝 Nueva Actividad'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Nombre',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.title),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Ingrese un nombre' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: descController,
                decoration: InputDecoration(
                  labelText: 'Descripción',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.description),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: const Icon(Icons.calendar_today, color: Colors.blue),
                  title: Text(
                    deliveryDate != null
                        ? "Fecha de entrega: ${deliveryDate!.toLocal().toString().split(' ')[0]}"
                        : "Seleccione una fecha",
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit_calendar),
                    onPressed: _pickDate,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _save,
                  icon: Icon(isEditing ? Icons.save : Icons.add),
                  label: Text(
                    isEditing ? "Guardar cambios" : "Crear actividad",
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    backgroundColor: Colors.blueAccent,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
