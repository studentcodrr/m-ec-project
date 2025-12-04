import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../services/database_services.dart'; 
import '../../../../models/task_list_model.dart';
import '../../../../widgets/task_list_group.dart';

class TasksTab extends StatelessWidget {
  const TasksTab({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final dbService = DatabaseService();

    if (user == null) return const Center(child: Text("Please log in"));

    return Container(
      color: Colors.white,
      child: StreamBuilder<List<TaskListModel>>(
        stream: dbService.getUserLists(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
             debugPrint("Firestore Error: ${snapshot.error}");
             return Center(child: Text("Error: ${snapshot.error}"));
          }

          final lists = snapshot.data ?? [];

          return ListView(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 80),
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: ElevatedButton.icon(
                  onPressed: () => _showAddListDialog(context, dbService, user.uid),
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

              if (lists.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Text("No lists yet. Create one above!"),
                  ),
                )
              else
                ...lists.map((list) => TaskListGroup(list: list)),
            ],
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