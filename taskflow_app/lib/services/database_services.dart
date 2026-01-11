import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task_model.dart';
import '../models/team_model.dart';
import '../models/task_list_model.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<TaskListModel>> getUserLists(String userId) {
    return _db.collection('lists')
        .where('createdBy', isEqualTo: userId)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => TaskListModel.fromSnapshot(doc)).toList());
  }

  Future<void> createTaskList(String title, String userId) async {
    await _db.collection('lists').add({
      'title': title,
      'createdBy': userId,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteTaskList(String listId) async {
    await _db.collection('lists').doc(listId).delete();
    final tasks = await _db.collection('tasks').where('listId', isEqualTo: listId).get();
    for (var doc in tasks.docs) {
      await doc.reference.delete();
    }
  }

  Stream<List<TaskModel>> getTasksForList(String listId) {
    return _db.collection('tasks')
        .where('listId', isEqualTo: listId)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => TaskModel.fromSnapshot(doc)).toList());
  }
  
  Future<void> toggleTaskCompletion(String taskId, bool currentStatus) async {
    await _db.collection('tasks').doc(taskId).update({
      'isCompleted': !currentStatus,
    });
  }

  Future<void> addTask(TaskModel task) async {
    await _db.collection('tasks').add(task.toMap());
  }

  Future<void> deleteTask(String taskId) async {
    await _db.collection('tasks').doc(taskId).delete();
  }

  Stream<List<TeamModel>> getTeams() {
    return _db.collection('teams').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => TeamModel.fromSnapshot(doc)).toList());
  }

  Future<void> deleteTeam(String teamId) async {
    await _db.collection('teams').doc(teamId).delete();
  }

  Future<void> addTeam(String name, List<String> members) async {
    await _db.collection('teams').add({
      'name': name,
      'members': members,
    });
  }
}