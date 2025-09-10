// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../activities/domain/models/activity.dart';
import '../controllers/activity_controller.dart';

class ActivityFormPage extends StatefulWidget {
  final int
  categoryId; // 🔹 Necesario para vincular la actividad a la categoría
  final Activity? activity; // 🔹 Si es null → creación, si no → edición

  const ActivityFormPage({super.key, required this.categoryId, this.activity});

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
    descController = TextEditingController(
      text: widget.activity?.description ?? '',
    );
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

  void _save() {
    if (_formKey.currentState!.validate()) {
      if (widget.activity == null) {
        // Crear nueva actividad vinculada a la categoría actual
        activityController.addActivity(
          widget.categoryId,
          nameController.text,
          descController.text,
          deliveryDate ?? DateTime.now(),
        );
      } else {
        // Actualizar actividad existente
        final updated = widget.activity!.copyWith(
          categoryId: widget.activity!.categoryId,
          name: nameController.text,
          description: descController.text,
          deliveryDate: deliveryDate ?? widget.activity!.deliveryDate,
        );
        activityController.updateActivity(updated);
      }

      // 🔹 Al volver, CategoryFormPage (con Obx) se refresca automáticamente
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.activity != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Actividad' : 'Nueva Actividad'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: descController,
                decoration: const InputDecoration(labelText: 'Descripción'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Fecha de entrega: ${deliveryDate != null ? deliveryDate!.toLocal().toString().split(' ')[0] : 'No seleccionada'}',
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: _pickDate,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _save,
                child: Text(isEditing ? 'Actualizar' : 'Guardar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
