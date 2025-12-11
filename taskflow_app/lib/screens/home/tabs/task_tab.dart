import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/services/database_services.dart';
import '/services/task_repository.dart'; 
import '/models/task_model.dart';
import '/models/task_list_model.dart'; 
import '/widgets/task_list_group.dart'; 

class TasksTab extends StatefulWidget {
  const TasksTab({super.key});

  @override
  State<TasksTab> createState() => _TasksTabState();
}

class _TasksTabState extends State<TasksTab> {
  final DatabaseService _dbService = DatabaseService();
  final TaskRepository _repo = TaskRepository(); 

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Center(child: Text("Please log in"));

    return Container(
      color: Colors.white,
      child: StreamBuilder<List<TaskListModel>>(
        stream: _dbService.getUserLists(user.uid),
        builder: (context, listSnapshot) {
          
          return StreamBuilder<List<TaskModel>>(
            stream: _repo.getTasks(), 
            builder: (context, taskSnapshot) {
              
              if (!listSnapshot.hasData && !taskSnapshot.hasData) {
                 if (listSnapshot.connectionState == ConnectionState.waiting) {
                   return const Center(child: CircularProgressIndicator());
                 }
              }

              final allTasks = taskSnapshot.data ?? [];
              final onlineLists = listSnapshot.data ?? [];
              
              List<TaskListModel> displayLists = [];
              Set<String> processedListIds = {};

              for (var list in onlineLists) {
                final matchingTasks = allTasks.where((t) => t.listId == list.id).toList();
                
                displayLists.add(TaskListModel(
                  id: list.id,
                  title: list.title,
                  createdBy: list.createdBy,
                  tasks: matchingTasks, 
                ));
                processedListIds.add(list.id);
              }

              final Map<String, List<TaskModel>> orphanGroups = {};
              for (var task in allTasks) {
                if (!processedListIds.contains(task.listId)) {
                  if (!orphanGroups.containsKey(task.listId)) {
                    orphanGroups[task.listId] = [];
                  }
                  orphanGroups[task.listId]!.add(task);
                }
              }

              orphanGroups.forEach((listId, tasks) {
                displayLists.add(TaskListModel(
                  id: listId,
                  title: "My List", 
                  createdBy: user.uid,
                  tasks: tasks,
                ));
              });

              return ListView(
                padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 80),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: ElevatedButton.icon(
                      onPressed: () => _showAddListDialog(context, _dbService, user.uid),
                      icon: const Icon(Icons.playlist_add),
                      label: const Text("Create New List"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.teal,
                        elevation: 0,
                        side: const BorderSide(color: Colors.teal),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),

                  if (displayLists.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Text("No lists found. Create one!"),
                      ),
                    )
                  else
                    ...displayLists.map((list) => TaskListGroup(list: list)),
                ],
              );
            },
          );
        },
      ),
    );
  }

  void _showAddListDialog(BuildContext context, DatabaseService db, String uid) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("New List"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: "List Name (e.g., Uni, Work)"),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                db.createTaskList(controller.text.trim(), uid);
                Navigator.pop(context);
              }
            },
            child: const Text("Create"),
          )
        ],
      ),
    );
  }
}