import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';

class TaskTableSection extends StatefulWidget {
  final String title;
  final Color accentColor;
  final List<Task> tasks;

  const TaskTableSection({
    super.key,
    required this.title,
    required this.accentColor,
    required this.tasks,
  });

  @override
  State<TaskTableSection> createState() => _TaskTableSectionState();
}

class _TaskTableSectionState extends State<TaskTableSection> {
  late List<Task> _tasks;
  late String _currentTitle;

  @override
  void initState() {
    super.initState();
    _tasks = widget.tasks;
    _currentTitle = widget.title;
  }

  void _updateTitle(String newTitle) {
    setState(() {
      _currentTitle = newTitle;
    });
  }

  void _updateTask(Task updatedTask) {
    setState(() {
      final index = _tasks.indexWhere((task) => task.id == updatedTask.id);
      if (index != -1) {
        _tasks[index] = updatedTask;
      }
    });
  }

  void _deleteTask(String taskId) {
    setState(() {
      _tasks.removeWhere((task) => task.id == taskId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 1,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _TableHeader(
              title: _currentTitle,
              accentColor: widget.accentColor,
              onTitleSubmitted: _updateTitle,
            ),
            const Divider(height: 1, thickness: 1),
            ..._tasks.map(
              (task) => _TaskRow(
                task: task,
                accentColor: widget.accentColor,
                onUpdate: _updateTask,
                onDelete: () => _deleteTask(task.id),
              ),
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: null,
              icon: const Icon(Icons.add, size: 18),
              label: const Text("Add task"),
            ),
          ],
        ),
      ),
    );
  }
}

class _TableHeader extends StatelessWidget {
  final String title;
  final Color accentColor;
  final ValueChanged<String> onTitleSubmitted;

  const _TableHeader({
    required this.title,
    required this.accentColor,
    required this.onTitleSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    const headerStyle = TextStyle(
      color: Colors.grey,
      fontWeight: FontWeight.w500,
    );
    final titleController = TextEditingController(text: title);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: TextFormField(
              controller: titleController,
              onFieldSubmitted: onTitleSubmitted,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: accentColor,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          const Expanded(flex: 3, child: Text("Responsible", style: headerStyle)),
          const Expanded(flex: 4, child: Text("Timeline", style: headerStyle)),
          const Expanded(flex: 3, child: Text("Status", style: headerStyle)),
          const Expanded(flex: 3, child: Text("Deadline", style: headerStyle)),
          const SizedBox(width: 40),
        ],
      ),
    );
  }
}

class _TaskRow extends StatelessWidget {
  final Task task;
  final Color accentColor;
  final ValueChanged<Task> onUpdate;
  final VoidCallback onDelete;

  const _TaskRow({
    required this.task,
    required this.accentColor,
    required this.onUpdate,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final titleController = TextEditingController(text: task.title);
    final ownerController = TextEditingController(text: task.owner);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: TextFormField(
              controller: titleController,
              style: const TextStyle(fontWeight: FontWeight.w500),
              decoration: InputDecoration(
                prefixIcon: Container(
                  margin: const EdgeInsets.only(right: 16.0),
                  width: 4,
                  color: accentColor,
                ),
                prefixIconConstraints: const BoxConstraints(maxHeight: 36),
                border: InputBorder.none,
                isDense: true,
              ),
              onFieldSubmitted: (newValue) {
                task.title = newValue;
                onUpdate(task);
              },
            ),
          ),
          Expanded(
            flex: 3,
            child: TextFormField(
              controller: ownerController,
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
              ),
              onFieldSubmitted: (newValue) {
                task.owner = newValue;
                onUpdate(task);
              },
            ),
          ),
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.only(right: 24.0),
              child: LinearProgressIndicator(
                value: task.progress,
                color: accentColor,
                backgroundColor: Colors.grey[200],
                minHeight: 6,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: DropdownButtonHideUnderline(
              child: DropdownButton<TaskStatus>(
                value: task.status,
                items: TaskStatus.values.map((status) {
                  return DropdownMenuItem(
                    value: status,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: status.displayColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        status.displayName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (newValue) {
                  if (newValue != null) {
                    task.status = newValue;
                    onUpdate(task);
                  }
                },
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: TextButton(
              onPressed: () async {
                final newDate = await showDatePicker(
                  context: context,
                  initialDate: task.deadline,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                );
                if (newDate != null) {
                  task.deadline = newDate;
                  onUpdate(task);
                }
              },
              child: Text(
                DateFormat.yMMMd().format(task.deadline),
                style: const TextStyle(color: Colors.grey),
              ),
            ),
          ),
          SizedBox(
            width: 40,
            child: IconButton(
              icon: const Icon(
                Icons.delete_outline,
                color: Colors.grey,
                size: 20,
              ),
              onPressed: onDelete,
            ),
          ),
        ],
      ),
    );
  }
}