import 'package:flutter/material.dart';
import 'tabs/task_tab.dart';
import 'tabs/teams_tab.dart'; 
import 'tabs/settings_tab.dart'; 
import '../../widgets/add_task_dialog.dart'; 
import '../../widgets/edit_team_dialog.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget? _buildFloatingActionButton() {
    if (_tabController.index == 0) {
      return FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => const AddTaskDialog(),
          );
        },
        backgroundColor: Colors.teal,
        tooltip: 'Add Task',
        child: const Icon(Icons.add, color: Colors.white),
      );
    }
    
    if (_tabController.index == 1) {
      return FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => const EditTeamDialog(),
          );
        },
        backgroundColor: Colors.indigo, 
        tooltip: 'Manage Team Members',
        child: const Icon(Icons.manage_accounts, color: Colors.white), 
      );
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TaskFlow'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.teal,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.teal,
          tabs: const [
            Tab(text: 'Board'),
            Tab(text: 'Teams'),
            Tab(text: 'Settings'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
           TasksTab(), 
           TeamsTab(),
           SettingsTab(),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }
}