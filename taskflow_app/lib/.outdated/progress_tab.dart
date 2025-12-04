import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/services/database_services.dart';
import '../models/task_model.dart';

class ProgressTab extends StatelessWidget {
  const ProgressTab({super.key});

  // Helper to convert status string to 0.0 - 1.0 range
  double _getProgressValue(String status) {
    switch (status) {
      case 'completed': return 1.0;
      case 'in_progress': return 0.5;
      case 'pending': return 0.1;
      default: return 0.0;
    }
  }

  // Helper to color code the progress bar
  Color _getProgressColor(String status) {
    switch (status) {
      case 'completed': return Colors.green;
      case 'in_progress': return Colors.orange;
      case 'pending': return Colors.redAccent;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final dbService = DatabaseService();

    if (user == null) return const Center(child: Text("Not logged in"));

    return StreamBuilder<List<TaskModel>>(
      // Using the service we created earlier
      stream: dbService.getUserTasks(user.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
           return const Center(
             child: Column(
               mainAxisAlignment: MainAxisAlignment.center,
               children: [
                 Icon(Icons.bar_chart, size: 60, color: Colors.grey),
                 Text("No progress to track yet."),
               ],
             )
           );
        }

        final tasks = snapshot.data!;

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final task = tasks[index];
            final progress = _getProgressValue(task.status);
            final color = _getProgressColor(task.status);

            return Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and Percentage Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          task.title,
                          style: const TextStyle(
                            fontSize: 16, 
                            fontWeight: FontWeight.bold
                          ),
                        ),
                        Text(
                          "${(progress * 100).toInt()}%",
                          style: TextStyle(
                            fontWeight: FontWeight.bold, 
                            color: color
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    
                    // The Progress Bar
                    LinearProgressIndicator(
                      value: progress,
                      color: color,
                      backgroundColor: Colors.grey.shade200,
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    const SizedBox(height: 8),
                    
                    // Status Text
                    Text(
                      "Status: ${task.status.replaceAll('_', ' ').toUpperCase()}",
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}