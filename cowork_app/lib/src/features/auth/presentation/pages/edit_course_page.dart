import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loggy/loggy.dart';

import '../../domain/models/course.dart';
import '../controllers/course_controller.dart';

class EditCoursePage extends StatefulWidget {
  const EditCoursePage({super.key});

  @override
  State<EditCoursePage> createState() => _EditCoursePageState();
}

class _EditCoursePageState extends State<EditCoursePage> {
  Course course = Get.arguments[0];
  final controllerCourseName = TextEditingController();
  final controllerCourseDesc = TextEditingController();
  final controllerCourseMembers = TextEditingController();

  late List<String> membersList;

  @override
  void initState() {
    super.initState();
    controllerCourseName.text = course.name;
    controllerCourseDesc.text = course.description;
    membersList = List<String>.from(course.members);
  }

  @override
  Widget build(BuildContext context) {
    CourseController courseController = Get.find();
    logInfo("Update page Course $course");
    return Scaffold(
      appBar: AppBar(title: Text(course.name)),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            TextField(
              controller: controllerCourseName,
              decoration: const InputDecoration(
                labelText: 'Course Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: controllerCourseDesc,
              decoration: const InputDecoration(
                labelText: 'Course Description',
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
                    controller: controllerCourseMembers,
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
                    String member = controllerCourseMembers.text.trim();
                    if (member.isNotEmpty) {
                      setState(() {
                        membersList.add(member);
                        controllerCourseMembers.clear();
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
                      course.name = controllerCourseName.text;
                      course.description = controllerCourseDesc.text;
                      course.members = membersList;
                      try {
                        await courseController.updateCourse(course);
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
