import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../services/database_services.dart';

class TaskCard extends StatelessWidget {
  final TaskModel task;

  const TaskCard({super.key, required this.task});

  Color _getAvatarColor(String name) {
    final colors = [
      Colors.blue.shade100, Colors.red.shade100, 
      Colors.green.shade100, Colors.purple.shade100
    ];
    return colors[name.length % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final dbService = DatabaseService();
    final isDone = task.isCompleted;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDone ? Colors.grey.shade100 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDone ? Colors.transparent : Colors.grey.shade200
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2, right: 12),
            child: InkWell(
              onTap: () => dbService.toggleTaskCompletion(task.id, task.isCompleted),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDone ? Colors.grey : Colors.transparent,
                  border: Border.all(
                    color: isDone ? Colors.grey : Colors.grey.shade500, 
                    width: 2
                  ),
                ),
                child: isDone 
                  ? const Icon(Icons.check, size: 16, color: Colors.white) 
                  : null,
              ),
            ),
          ),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: TextStyle(
                    fontSize: 15, 
                    fontWeight: FontWeight.w600,
                    color: isDone ? Colors.grey : Colors.black87,
                    decoration: isDone ? TextDecoration.lineThrough : null,
                  ),
                ),
                
                if (task.description.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      task.description,
                      style: TextStyle(
                        fontSize: 12, 
                        color: isDone ? Colors.grey.shade400 : Colors.grey.shade600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                const SizedBox(height: 8),

                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(4),
                        color: Colors.white,
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today, size: 10, color: Colors.grey.shade600),
                          const SizedBox(width: 4),
                          Text(
                            task.deadline.toLocal().toString().split(' ')[0],
                            style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    
                    if (task.teamName.isNotEmpty) 
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Text(
                          task.teamName,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isDone ? Colors.grey.shade400 : Colors.teal.shade700,
                          ),
                        ),
                      ),
                    
                    //Avatars
                    if (task.assignedTo.isNotEmpty)
                      Row(
                        children: task.assignedTo.map((member) {
                          return Padding(
                            padding: const EdgeInsets.only(left: 4),
                            child: Tooltip(
                              message: member,
                              child: CircleAvatar(
                                radius: 10,
                                backgroundColor: isDone ? Colors.grey.shade200 : _getAvatarColor(member),
                                child: Text(
                                  member.isNotEmpty ? member[0].toUpperCase() : '?',
                                  style: TextStyle(
                                    fontSize: 9, 
                                    color: isDone ? Colors.grey : Colors.black
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ],
            ),
          ),

          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => dbService.deleteTask(task.id),
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Icon(
                  Icons.close_rounded,
                  size: 20, 
                  color: Colors.grey.shade400,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}