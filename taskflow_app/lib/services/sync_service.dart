import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/task_model.dart';

class SyncService {
  final Box<TaskModel> _localBox = Hive.box<TaskModel>('tasks');
  final CollectionReference _remoteCollection = FirebaseFirestore.instance.collection('tasks');


  void startMonitoring() {
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      if (result == ConnectivityResult.mobile || 
          result == ConnectivityResult.wifi) {
        print("SyncService: Network restored. Attempting sync...");
        syncLocalToRemote();
      }
    });
  }


  Future<void> syncLocalToRemote() async {
    final unsyncedTasks = _localBox.values.where((task) => !task.isSynced).toList();

    if (unsyncedTasks.isEmpty) {
      return; 
    }

    print("SyncService: Found ${unsyncedTasks.length} pending tasks");

    for (var task in unsyncedTasks) {
      try {
        await _remoteCollection.doc(task.id).set(task.toMap());
        
        task.isSynced = true;
        await task.save(); 
        
        print("SyncService: Successfully synced task '${task.title}' (${task.id})");
      } catch (e) {
        print("SyncService: Failed to sync task ${task.id}. Error: $e");
      }
    }
  }
}