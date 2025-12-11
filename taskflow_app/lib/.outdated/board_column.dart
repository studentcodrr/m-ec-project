import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/task_list_model.dart';
import '../models/task_model.dart';
import '../services/database_services.dart';
import '../widgets/task_card.dart';

class BoardColumn extends StatelessWidget {
  final TaskListModel list;

  const BoardColumn({super.key, required this.list});

  @override
  Widget build(BuildContext context) {
    final dbService = DatabaseService();
    final user = FirebaseAuth.instance.currentUser;

    return SizedBox(
      width: 320, // Slightly wider for comfort
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER (Title)
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0, left: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  list.title,
                  style: const TextStyle(
                    color: Colors.black87, // Dark text for white bg
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_horiz, color: Colors.grey),
                  onPressed: () {
                    // TODO: Delete list logic
                  },
                ),
              ],
            ),
          ),

          // QUICK ADD TASK BUTTON
          InkWell(
            onTap: () {
               // Quick dialog to add task to THIS specific list
               _showAddTaskDialog(context, dbService, list.id, user!.uid);
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Colors.grey.shade300),
                boxShadow: [
                  BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))
                ]
              ),
              child: const Row(
                children: [
                  Icon(Icons.add, color: Colors.teal, size: 24),
                  SizedBox(width: 12),
                  Text("Add a task", style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),

          // TASK LIST
          Expanded(
            child: StreamBuilder<List<TaskModel>>(
              stream: dbService.getTasksForList(list.id),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const SizedBox();
                
                final allTasks = snapshot.data!;
                
                // 4. DISAPPEARING LOGIC:
                // Filter out tasks where isCompleted is true
                final visibleTasks = allTasks.where((t) => !t.isCompleted).toList();

                return ListView.builder(
                  itemCount: visibleTasks.length,
                  itemBuilder: (context, index) {
                    return TaskCard(task: visibleTasks[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context, DatabaseService db, String listId, String uid) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: "What needs to be done?"),
          autofocus: true,
          onSubmitted: (val) {
             if (val.isNotEmpty) {
                db.addTask(val, listId, uid);
                Navigator.pop(context);
             }
          },
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                db.addTask(controller.text, listId, uid);
                Navigator.pop(context);
              }
            },
            child: const Text("Save"),
          )
        ],
      ),
    );
  }
}