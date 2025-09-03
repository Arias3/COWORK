import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/activity_controller.dart';

class AddActivityPage extends StatefulWidget {
  const AddActivityPage({super.key});

  @override
  State<AddActivityPage> createState() => _AddActivityPageState();
}

class _AddActivityPageState extends State<AddActivityPage> {
  final controllerName = TextEditingController();
  final controllerDesc = TextEditingController();
  final controllerMembers = TextEditingController();

  List<String> membersList = [];

  @override
  Widget build(BuildContext context) {
    ActivityController activityController = Get.find();

    return Scaffold(
      appBar: AppBar(title: const Text('New Activity')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            TextField(
              controller: controllerName,
              decoration: const InputDecoration(
                labelText: 'Activity Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: controllerDesc,
              decoration: const InputDecoration(
                labelText: 'Activity Description',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controllerMembers,
                    decoration: const InputDecoration(
                      labelText: 'Member Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.add, color: Colors.purple),
                  onPressed: () {
                    String member = controllerMembers.text.trim();
                    if (member.isNotEmpty) {
                      setState(() {
                        membersList.add(member);
                        controllerMembers.clear();
                      });
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: membersList.map((member) {
                return Chip(
                  backgroundColor: Colors.purple[200],
                  label: Text(
                    member,
                    style: const TextStyle(color: Colors.white),
                  ),
                  deleteIcon: const Icon(Icons.close, color: Colors.white),
                  onDeleted: () {
                    setState(() {
                      membersList.remove(member);
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: FilledButton.tonal(
                    onPressed: () async {
                      try {
                        await activityController.addActivity(
                          controllerName.text,
                          controllerDesc.text,
                          membersList,
                        );
                        Get.toNamed('/activitys');
                      } catch (err) {
                        Get.snackbar(
                          "Error",
                          err.toString(),
                          icon: const Icon(Icons.error, color: Colors.red),
                          snackPosition: SnackPosition.BOTTOM,
                        );
                      }
                    },
                    child: const Text("Save"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
