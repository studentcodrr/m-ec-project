import 'package:flutter/material.dart';

class TaskItem extends StatefulWidget {
  final String title;
  const TaskItem({super.key, required this.title});

  @override
  State<TaskItem> createState() => _TaskItemState();
}

class _TaskItemState extends State<TaskItem> {
  bool isDone = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Checkbox(
            value: isDone,
            onChanged: (v) => setState(() => isDone = v ?? false),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          ),
          Expanded(
            child: Text(
              widget.title,
              style: TextStyle(
                fontSize: 14,
                color: isDone ? Colors.grey : Colors.white,
                decoration: isDone ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
