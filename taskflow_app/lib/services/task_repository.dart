import 'package:hive/hive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';
import '../models/task_model.dart';

class TaskRepository {
  final Box<TaskModel> _localBox = Hive.box<TaskModel>('tasks');
  final CollectionReference _remoteCollection = FirebaseFirestore.instance.collection('tasks');

  bool _isConnected(dynamic connectivityResult) {
    if (connectivityResult is List) {
      return (connectivityResult).contains(ConnectivityResult.mobile) || 
             (connectivityResult).contains(ConnectivityResult.wifi);
    } else {
      return connectivityResult == ConnectivityResult.mobile || 
             connectivityResult == ConnectivityResult.wifi;
    }
  }

  Stream<List<TaskModel>> getTasks() async* {
    if (_localBox.isNotEmpty) {
      yield _localBox.values.toList();
    } else {
      yield [];
    }

    _syncFromFirestore();

    // ignore: unused_local_variable
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

  Future<void> deleteTask(String taskId) async {
    await _localBox.delete(taskId);

    final connectivityResult = await Connectivity().checkConnectivity();

    if (_isConnected(connectivityResult)) {
      try {
        await _remoteCollection.doc(taskId).delete();
      } catch (e) {
        print("Delete failed on server: $e");
       
      }
    }
  }

  
  Future<void> deleteTaskList(String listId) async {
    final tasksToDelete = _localBox.values.where((t) => t.listId == listId).toList();
    for (var task in tasksToDelete) {
      await _localBox.delete(task.id);
    }


    if (listId.isEmpty) return;

    final connectivityResult = await Connectivity().checkConnectivity();
    if (_isConnected(connectivityResult)) {
      try {
        
        await FirebaseFirestore.instance.collection('task_lists').doc(listId).delete();
        
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