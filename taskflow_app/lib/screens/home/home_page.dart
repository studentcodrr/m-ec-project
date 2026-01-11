import 'package:flutter/material.dart';

import 'tabs/task_tab.dart';
import 'tabs/teams_tab.dart';
import 'tabs/settings_tab.dart';
import 'tabs/admin_tab.dart';

import '../../widgets/add_task_dialog.dart';
import '../../widgets/edit_team_dialog.dart';

import '../../services/admin_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  late Future<bool> _isAdminFuture;

  @override
  void initState() {
    super.initState();
    _isAdminFuture = AdminService().isCurrentUserAdmin();
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  Widget? _buildFloatingActionButton(bool isAdmin) {
    final tc = _tabController;
    if (tc == null) return null;

    // index mapping depends on whether admin tab exists
    // Tabs: 0 board, 1 teams, 2 settings, (3 admin if admin)
    if (tc.index == 0) {
      return FloatingActionButton(
        onPressed: () {
          showDialog(context: context, builder: (_) => const AddTaskDialog());
        },
        backgroundColor: Colors.teal,
        tooltip: 'Add Task',
        child: const Icon(Icons.add, color: Colors.white),
      );
    }

    if (tc.index == 1) {
      return FloatingActionButton(
        onPressed: () {
          showDialog(context: context, builder: (_) => const EditTeamDialog());
        },
        backgroundColor: Colors.teal,
        tooltip: 'Manage Team Members',
        child: const Icon(Icons.manage_accounts, color: Colors.white),
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _isAdminFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final isAdmin = snapshot.data!;
        final tabCount = isAdmin ? 4 : 3;

        if (_tabController == null || _tabController!.length != tabCount) {
          final prevIndex = _tabController?.index ?? 0;
          _tabController?.dispose();

          _tabController = TabController(length: tabCount, vsync: this);
          _tabController!.index = prevIndex.clamp(0, tabCount - 1);

          _tabController!.addListener(() => setState(() {}));
        }

        final tabs = <Tab>[
          const Tab(text: 'Board'),
          const Tab(text: 'Teams'),
          const Tab(text: 'Settings'),
          if (isAdmin) const Tab(text: 'Admin'),
        ];

        final views = <Widget>[
          const TasksTab(),
          const TeamsTab(),
          const SettingsTab(),
          if (isAdmin) const AdminTab(),
        ];

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
              tabs: tabs,
            ),
          ),
          body: TabBarView(controller: _tabController, children: views),
          floatingActionButton: _buildFloatingActionButton(isAdmin),
        );
      },
    );
  }
}
