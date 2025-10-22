import 'package:flutter/material.dart';

enum TaskStatus {
  workingOnIt,
  done,
  stuck;

  String get displayName {
    switch (this) {
      case TaskStatus.workingOnIt:
        return 'Working on it';
      case TaskStatus.done:
        return 'Done';
      case TaskStatus.stuck:
        return 'Stuck';
    }
  }

  Color get displayColor {
    switch (this) {
      case TaskStatus.workingOnIt:
        return Colors.grey.shade500; 
      case TaskStatus.done:
        return Colors.greenAccent.shade700; 
      case TaskStatus.stuck:
        return Colors.grey.shade800;
    }
  }
}

class Task {
  String id;
  String title;
  String owner;
  TaskStatus status;
  DateTime startDate;
  DateTime deadline;

  Task({
    required this.id,
    required this.title,
    required this.owner,
    required this.status,
    required this.startDate,
    required this.deadline,
  });

  double get progress {
    return 0.0;
  }
}