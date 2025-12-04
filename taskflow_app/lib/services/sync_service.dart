import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/task_model.dart';

class SyncService {
  final Box<TaskModel> _localBox = Hive.box<TaskModel>('tasks');
  final CollectionReference _remoteCollection = FirebaseFirestore.instance.collection('tasks');

  /// Starts listening to network changes. 
  /// Call this once when the app starts (e.g., in Home initState).
  void startMonitoring() {
    // UPDATED: Adjusted to listen for a single ConnectivityResult (older package version)
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      // If we have mobile or wifi, try to sync
      if (result == ConnectivityResult.mobile || 
          result == ConnectivityResult.wifi) {
        print("SyncService: Network restored. Attempting sync...");
        syncLocalToRemote();
      }
    });
  }

  /// Iterates through local Hive tasks marked as `isSynced: false`
  /// and pushes them to Firestore.
  Future<void> syncLocalToRemote() async {
    // 1. Filter tasks that need syncing
    final unsyncedTasks = _localBox.values.where((task) => !task.isSynced).toList();

    if (unsyncedTasks.isEmpty) {
      return; // Nothing to do
    }

    print("SyncService: Found ${unsyncedTasks.length} pending tasks.");

    // 2. Process each task
    for (var task in unsyncedTasks) {
      try {
        // Upload to Firestore using the ID as the document key
        await _remoteCollection.doc(task.id).set(task.toMap());
        
        // 3. If successful, mark as synced locally
        task.isSynced = true;
        await task.save(); // Efficiently updates just this object in Hive
        
        print("SyncService: Successfully synced task '${task.title}' (${task.id})");
      } catch (e) {
        print("SyncService: Failed to sync task ${task.id}. Error: $e");
        // We leave isSynced = false so it tries again next time
      }
    }
  }
}