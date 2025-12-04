import 'package:cloud_firestore/cloud_firestore.dart';

class TaskListModel {
  final String id;
  final String title;
  final String createdBy;

  TaskListModel({
    required this.id, 
    required this.title, 
    required this.createdBy
  });

  factory TaskListModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TaskListModel(
      id: doc.id,
      title: data['title'] ?? 'Untitled List',
      createdBy: data['createdBy'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'createdBy': createdBy,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}