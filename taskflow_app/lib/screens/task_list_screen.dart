import 'package:flutter/material.dart';
import '../models/task.dart';
import '../models/team.dart';
import '../widgets/task_card.dart';

class TaskListScreen extends StatelessWidget {
  final Team team;

  const TaskListScreen({super.key, required this.team});

  @override
  Widget build(BuildContext context) {
    final mockTasks = [
      Task(
        title: "Implement Login Screen",
        deadline: DateTime(2025, 10, 25),
        assignedTo: "Alice",
        isDone: false,
      ),
      Task(
        title: "UI Review Meeting",
        deadline: DateTime(2025, 10, 22),
        assignedTo: "Bob",
        isDone: true,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(team.name),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert)),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: mockTasks.length,
        itemBuilder: (context, index) {
          return TaskCard(task: mockTasks[index]);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}
