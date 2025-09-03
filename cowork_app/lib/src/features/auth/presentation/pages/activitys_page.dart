import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/activity_controller.dart';

class ActivityPage extends StatelessWidget {
  const ActivityPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ActivityController activityController = Get.find();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cursos'),
        backgroundColor: Colors.purple[400],
      ),
      body: Obx(() {
        final activitys = activityController.activitys;
        if (activitys.isEmpty) {
          return const Center(
            child: Text(
              'No hay cursos guardados',
              style: TextStyle(color: Colors.purple, fontSize: 18),
            ),
          );
        }
        return ListView.builder(
          itemCount: activitys.length,
          itemBuilder: (context, index) {
            final activity = activitys[index];
            return Card(
              color: Colors.purple[100 + (index % 4) * 100],
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: ListTile(
                title: Text(
                  activity.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  activity.description,
                  style: const TextStyle(color: Colors.white70),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.white),
                  onPressed: () async {
                    await activityController.deleteActivity(activity);
                  },
                ),
                onTap: () {
                  Get.toNamed('/editActivity', arguments: [activity]);
                },
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.purple,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          Get.toNamed('/addActivitys');
        },
      ),
    );
  }
}
