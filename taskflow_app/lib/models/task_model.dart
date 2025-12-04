import 'package:cloud_firestore/cloud_firestore.dart';

class TaskModel {
  final String id;
  final String title;
  final String description;
  final String listId;
  final bool isCompleted;
  final String createdBy;
  final DateTime deadline;
  final List<String> assignedTo;
  final String teamName;

  TaskModel({
    required this.id,
    required this.title,
    this.description = '',
    required this.listId,
    this.isCompleted = false,
    required this.createdBy,
    required this.deadline,
    this.assignedTo = const [],
    this.teamName = '',
  });

  factory TaskModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return TaskModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      listId: data['listId'] ?? '',
      isCompleted: data['isCompleted'] ?? false,
      createdBy: data['createdBy'] ?? '',
      deadline: data['deadline'] != null 
          ? (data['deadline'] as Timestamp).toDate() 
          : DateTime.now(),
      assignedTo: List<String>.from(data['assignedTo'] ?? []),
      teamName: data['teamName'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'listId': listId,
      'isCompleted': isCompleted,
      'createdBy': createdBy,
      'deadline': Timestamp.fromDate(deadline),
      'assignedTo': assignedTo,
      'teamName': teamName,
    };
  }
}