import 'package:flutter/material.dart';
import '../widgets/completed_section.dart';
import 'task_item.dart';

class TaskColumn extends StatelessWidget {
  final String title;
  final List<String> tasks;
  final int completedCount;
  final bool allDone;

  const TaskColumn({
    super.key,
    required this.title,
    required this.tasks,
    required this.completedCount,
    this.allDone = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 20),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              InkWell(
                onTap: () {},
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: const [
                      Icon(Icons.add_circle_outline, size: 18, color: Colors.indigoAccent),
                      SizedBox(width: 6),
                      Text("Add a task", style: TextStyle(color: Colors.indigoAccent)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),

              if (!allDone)
                ...tasks.map((t) => TaskItem(title: t)).toList(),

              const SizedBox(height: 12),

              CompletedSection(
                count: completedCount,
                allDone: allDone,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
