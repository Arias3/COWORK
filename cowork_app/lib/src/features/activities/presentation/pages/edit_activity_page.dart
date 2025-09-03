import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loggy/loggy.dart';

import '../../../activities/domain/models/activity.dart';
import '../../../activities/presentation/controllers/activity_controller.dart';

class EditActivityPage extends StatefulWidget {
  const EditActivityPage({super.key});

  @override
  State<EditActivityPage> createState() => _EditActivityPageState();
}

class _EditActivityPageState extends State<EditActivityPage> {
  Activity activity = Get.arguments[0];
  final controllerActivityName = TextEditingController();
  final controllerActivityDesc = TextEditingController();
  final controllerActivityMembers = TextEditingController();

  late List<String> membersList;

  @override
  void initState() {
    super.initState();
    controllerActivityName.text = activity.name;
    controllerActivityDesc.text = activity.description;
    membersList = List<String>.from(activity.members);
  }

  @override
  Widget build(BuildContext context) {
    ActivityController activityController = Get.find();
    logInfo("Update page Activity $Activity");
    return Scaffold(
      appBar: AppBar(title: Text(activity.name)),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            TextField(
              controller: controllerActivityName,
              decoration: const InputDecoration(
                labelText: 'Activity Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: controllerActivityDesc,
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
                    controller: controllerActivityMembers,
                    decoration: const InputDecoration(
                      labelText: 'Agregar miembro',
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
                    String member = controllerActivityMembers.text.trim();
                    if (member.isNotEmpty) {
                      setState(() {
                        membersList.add(member);
                        controllerActivityMembers.clear();
                      });
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),
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
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  flex: 2,
                  child: FilledButton.tonal(
                    onPressed: () async {
                      activity.name = controllerActivityName.text;
                      activity.description = controllerActivityDesc.text;
                      activity.members = membersList;
                      try {
                        await activityController.updateActivity(activity);
                        Get.back();
                      } catch (err) {
                        Get.snackbar(
                          "Error",
                          err.toString(),
                          snackPosition: SnackPosition.BOTTOM,
                        );
                      }
                    },
                    child: const Text("Update"),
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
