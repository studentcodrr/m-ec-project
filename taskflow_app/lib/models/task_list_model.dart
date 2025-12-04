import 'package:cloud_firestore/cloud_firestore.dart';
import 'task_model.dart';

class TaskListModel {
  final String id;
  final String title;
  final String createdBy;
  final List<TaskModel> tasks; // Added field

  TaskListModel({
    required this.id, 
    required this.title, 
    required this.createdBy,
    this.tasks = const [], 
  });

  factory TaskListModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TaskListModel(
      id: doc.id,
      title: data['title'] ?? 'Untitled List',
      createdBy: data['createdBy'] ?? '',
    );
  }
}