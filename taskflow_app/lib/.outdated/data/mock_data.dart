// lib/data/mock_data.dart

import '../../models/task.dart';

final now = DateTime.now();

final List<Task> project1Tasks = [
  Task(
    id: 'p1_t1',
    title: 'Task 1',
    owner: 'Alex',
    status: TaskStatus.workingOnIt,
    startDate: now.subtract(const Duration(days: 3)),
    deadline: now.add(const Duration(days: 4)),
  ),
  Task(
    id: 'p1_t2',
    title: 'Task 2',
    owner: 'Sara',
    status: TaskStatus.done,
    startDate: now.subtract(const Duration(days: 7)),
    deadline: now.subtract(const Duration(days: 1)),
  ),
  Task(
    id: 'p1_t3',
    title: 'Task 3',
    owner: 'Mihai',
    status: TaskStatus.stuck,
    startDate: now.subtract(const Duration(days: 2)),
    deadline: now.add(const Duration(days: 2)),
  ),
];

final List<Task> project2Tasks = [
  Task(
    id: 'p2_t1',
    title: 'Task 1',
    owner: 'Maia',
    status: TaskStatus.workingOnIt,
    startDate: now,
    deadline: now.add(const Duration(days: 3)),
  ),
  Task(
    id: 'p2_t2',
    title: 'Task 2',
    owner: 'Alex',
    status: TaskStatus.stuck,
    startDate: now.subtract(const Duration(days: 4)),
    deadline: now.add(const Duration(days: 1)),
  ),
];

final List<Task> project3Tasks = [
  Task(
    id: 'p3_t1',
    title: 'Task 3',
    owner: 'Nico',
    status: TaskStatus.workingOnIt,
    startDate: now.subtract(const Duration(days: 1)),
    deadline: now.add(const Duration(days: 1)),
  ),
  Task(
    id: 'p3_t2',
    title: 'Task 1',
    owner: 'Mihai',
    status: TaskStatus.workingOnIt,
    startDate: now,
    deadline: now.add(const Duration(days: 2)),
  ),
  Task(
    id: 'p3_t3',
    title: 'Task 2',
    owner: 'Mihai',
    status: TaskStatus.done,
    startDate: now.subtract(const Duration(days: 1)),
    deadline: now,
  ),
];