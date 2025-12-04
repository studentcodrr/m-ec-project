import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../services/task_repository.dart';

class TaskCard extends StatelessWidget {
  final TaskModel task;
  final TaskRepository _repo = TaskRepository();

  TaskCard({super.key, required this.task});

  // Helper to format date simply without extra dependencies
  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Row 1: Checkbox, Title/Desc, Delete ---
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Checkbox
                Transform.scale(
                  scale: 1.1,
                  child: Checkbox(
                    value: task.isCompleted,
                    activeColor: Colors.teal,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    onChanged: (val) {
                      final updatedTask = TaskModel(
                        id: task.id,
                        title: task.title,
                        description: task.description,
                        listId: task.listId,
                        isCompleted: val ?? false,
                        createdBy: task.createdBy,
                        deadline: task.deadline,
                        assignedTo: task.assignedTo,
                        teamName: task.teamName,
                        isSynced: task.isSynced,
                      );
                      _repo.addTask(updatedTask);
                    },
                  ),
                ),
                
                // Title & Description
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8.0, left: 4.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                            color: task.isCompleted ? Colors.grey : Colors.black87,
                          ),
                        ),
                        if (task.description.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            task.description,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                              decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                // Delete Button & Sync Icon
                Column(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                      onPressed: () => _confirmDelete(context),
                      visualDensity: VisualDensity.compact,
                    ),
                    if (!task.isSynced)
                      const Icon(Icons.cloud_upload, color: Colors.orange, size: 16),
                  ],
                ),
              ],
            ),

            const Divider(height: 20),

            // --- Row 2: Footer Info (Deadline & Assigned) ---
            Row(
              children: [
                // Deadline
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, size: 14, color: Colors.red.shade700),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(task.deadline),
                        style: TextStyle(
                          fontSize: 12, 
                          color: Colors.red.shade900,
                          fontWeight: FontWeight.w500
                        ),
                      ),
                    ],
                  ),
                ),
                
                const Spacer(),

                // Assigned Person & Team
                if (task.assignedTo.isNotEmpty || task.teamName.isNotEmpty) ...[
                  Row(
                    children: [
                      Icon(Icons.group, size: 16, color: Colors.teal.shade700),
                      const SizedBox(width: 4),
                      Text(
                        // Format: "TeamName • Alice, Bob" or just "Alice"
                        "${task.teamName.isNotEmpty ? '${task.teamName} • ' : ''}${task.assignedTo.join(', ')}",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.teal.shade900,
                          fontWeight: FontWeight.w500
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ],
              ],
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
        title: const Text("Delete Task?"),
        content: const Text("Are you sure you want to delete this task?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              _repo.deleteTask(task.id);
              Navigator.pop(ctx);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}