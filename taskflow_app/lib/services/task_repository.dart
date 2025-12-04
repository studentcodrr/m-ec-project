import 'package:hive/hive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';
import '../models/task_model.dart';

class TaskRepository {
  final Box<TaskModel> _localBox = Hive.box<TaskModel>('tasks');
  final CollectionReference _remoteCollection = FirebaseFirestore.instance.collection('tasks');

  // Helper: robustly check connection
  bool _isConnected(dynamic connectivityResult) {
    if (connectivityResult is List) {
      return (connectivityResult as List).contains(ConnectivityResult.mobile) || 
             (connectivityResult as List).contains(ConnectivityResult.wifi);
    } else {
      return connectivityResult == ConnectivityResult.mobile || 
             connectivityResult == ConnectivityResult.wifi;
    }
  }

  // 1. GET TASKS
  Stream<List<TaskModel>> getTasks() async* {
    if (_localBox.isNotEmpty) {
      yield _localBox.values.toList();
    } else {
      yield [];
    }

    _syncFromFirestore();

    await for (final event in _localBox.watch()) {
      yield _localBox.values.toList();
    }
  }

  Future<void> _syncFromFirestore() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    
    if (_isConnected(connectivityResult)) {
      try {
        final snapshot = await _remoteCollection.get();
        for (var doc in snapshot.docs) {
          final task = TaskModel.fromSnapshot(doc);
          await _localBox.put(task.id, task);
        }
      } catch (e) {
        print("Sync Error: $e");
      }
    }
  }

  // 2. ADD TASK (Upsert)
  Future<void> addTask(TaskModel task) async {
    task.isSynced = false; 
    await _localBox.put(task.id, task);

    final connectivityResult = await Connectivity().checkConnectivity();
    
    if (_isConnected(connectivityResult)) {
      try {
        await _remoteCollection.doc(task.id).set(task.toMap());
        task.isSynced = true;
        await task.save(); 
      } catch (e) {
        print("Upload failed, will sync later: $e");
      }
    }
  }

  // 3. DELETE TASK
  Future<void> deleteTask(String taskId) async {
    // Delete locally immediately
    await _localBox.delete(taskId);

    final connectivityResult = await Connectivity().checkConnectivity();

    // Try to delete from cloud if online
    if (_isConnected(connectivityResult)) {
      try {
        await _remoteCollection.doc(taskId).delete();
      } catch (e) {
        print("Delete failed on server: $e");
        // Note: For full offline-delete sync, we would need a "deleted_tasks" Hive box.
        // For now, this handles the optimistic UI delete.
      }
    }
  }

  // 4. DELETE TASK LIST (New)
  // Safely deletes a list and all its tasks, handling empty IDs to prevent crashes.
  Future<void> deleteTaskList(String listId) async {
    // 1. Clean up local tasks associated with this list
    final tasksToDelete = _localBox.values.where((t) => t.listId == listId).toList();
    for (var task in tasksToDelete) {
      await _localBox.delete(task.id);
    }

    // 2. CRASH FIX: If ID is empty (orphan group), stop here. 
    // Do not attempt to call Firestore with empty path.
    if (listId.isEmpty) return;

    // 3. Delete from Cloud if online
    final connectivityResult = await Connectivity().checkConnectivity();
    if (_isConnected(connectivityResult)) {
      try {
        // Delete the list document
        // Assumes collection is 'task_lists' - check your DatabaseService if different
        await FirebaseFirestore.instance.collection('task_lists').doc(listId).delete();
        
        // Optional: Delete remote tasks belonging to this list (Manual Cascade)
        // This cleans up Firestore so tasks don't reappear
        final remoteTasks = await _remoteCollection.where('listId', isEqualTo: listId).get();
        for (var doc in remoteTasks.docs) {
           await doc.reference.delete();
        }
      } catch (e) {
        print("Delete list failed on server: $e");
      }
    }
  }
}