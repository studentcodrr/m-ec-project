import 'package:flutter/material.dart';
import '../widgets/task_table.dart';
import '../widgets/sidebar.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final Map<String, bool> _projectVisibility = {
    'Project Phoenix': true,
    'Project Orion': true,
    'Project Nova': true,
  };

  void _updateProjectVisibility(String projectName, bool isVisible) {
    setState(() {
      _projectVisibility[projectName] = isVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get the current theme's color scheme.
    final colorScheme = Theme.of(context).colorScheme;

    final Widget mainContent = Expanded(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            if (_projectVisibility['Project Phoenix'] ?? false)
              Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: TaskTableSection(
                  title: "",
                  accentColor: colorScheme.primary,
                  tasks: [],
                ),
              ),
            if (_projectVisibility['Project Orion'] ?? false)
              Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: TaskTableSection(
                  title: "",
                  accentColor: colorScheme.secondary,
                  tasks: [],
                ),
              ),
            if (_projectVisibility['Project Nova'] ?? false)
              Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: TaskTableSection(
                  title: "",
                  accentColor: colorScheme.tertiary,
                  tasks: [],
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