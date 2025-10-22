import 'package:flutter/material.dart';
import '../widgets/task_table.dart';
import '../widgets/sidebar.dart';
import '../data/mock_data.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final Map<String, bool> _projectVisibility = {
    'Project 1': true,
    'Project 2': true,
    'Project 3': true,
  };

  void _updateProjectVisibility(String projectName, bool isVisible) {
    setState(() {
      _projectVisibility[projectName] = isVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final Widget mainContent = Expanded(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            if (_projectVisibility['Project 1'] ?? false)
              Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: TaskTableSection(
                  title: "Project 1",
                  accentColor: colorScheme.primary,
                  tasks: project1Tasks, 
                ),
              ),
            if (_projectVisibility['Project 2'] ?? false)
              Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: TaskTableSection(
                  title: "Project 2",
                  accentColor: colorScheme.secondary,
                  tasks: project2Tasks,
                ),
              ),
            if (_projectVisibility['Project 3'] ?? false)
              Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: TaskTableSection(
                  title: "Project 3",
                  accentColor: colorScheme.tertiary,
                  tasks: project3Tasks, 
                ),
              ),
          ],
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        leading: Icon(Icons.done_all_outlined, color: colorScheme.primary),
        title: const Text("TaskList"),
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Sidebar(
            currentPage: "Dashboard",
            projectVisibility: _projectVisibility,
            onProjectVisibilityChanged: _updateProjectVisibility,
          ),
          mainContent,
        ],
      ),
    );
  }
}