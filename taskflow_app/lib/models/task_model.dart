import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';

part 'task_model.g.dart'; //dart run build_runner build

@HiveType(typeId: 0)
class TaskModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final String listId;

  @HiveField(4)
  final bool isCompleted;

  @HiveField(5)
  final String createdBy;

  @HiveField(6)
  final DateTime deadline;

  @HiveField(7)
  final List<String> assignedTo;

  @HiveField(8)
  final String teamName;

  @HiveField(9)
  bool isSynced; 

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
    this.isSynced = true,
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
      isSynced: true, 
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