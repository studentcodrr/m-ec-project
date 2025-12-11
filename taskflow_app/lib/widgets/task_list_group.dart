import 'package:flutter/material.dart';
import '../models/task_list_model.dart';
import '../services/task_repository.dart'; 
import 'task_card.dart'; 

class TaskListGroup extends StatelessWidget {
  final TaskListModel list;
  
  final TaskRepository _repo = TaskRepository(); 

  TaskListGroup({super.key, required this.list});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4, 
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: true,
          backgroundColor: Colors.white,
          collapsedBackgroundColor: Colors.white,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          
          title: Row(
            children: [
              Expanded(
                child: Text(
                  list.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.black87,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.grey),
                onPressed: () => _confirmDelete(context),
                tooltip: "Delete List",
              ),
            ],
          ),
          
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          children: [
            if (list.tasks.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  "No tasks",
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                ),
              )
            else
              Column(
                children: list.tasks.map((task) => TaskCard(task: task)).toList(),
              ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete List?"),
        content: const Text("This will delete the list and all tasks inside it."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx), 
            child: const Text("Cancel")
          ),
          TextButton(
            onPressed: () {
              _repo.deleteTaskList(list.id); 
              Navigator.pop(ctx);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}