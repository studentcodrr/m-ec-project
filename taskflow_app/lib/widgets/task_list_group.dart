import 'package:flutter/material.dart';
import '../models/task_list_model.dart';
import 'task_card.dart'; 

class TaskListGroup extends StatelessWidget {
  final TaskListModel list;

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
}