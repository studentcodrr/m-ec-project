import 'package:flutter/material.dart';
import '../screens/dashboard.dart';
import '../screens/teams.dart'; 
import '../screens/settings.dart'; 

class Sidebar extends StatelessWidget {
  final String currentPage; 
  final Map<String, bool> projectVisibility;
  final Function(String, bool) onProjectVisibilityChanged;

  const Sidebar({
    super.key,
    required this.currentPage, 
    required this.projectVisibility,
    required this.onProjectVisibilityChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: 250,
      color: theme.cardColor,
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 20),
        children: [
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            selected: currentPage == 'Dashboard',
            selectedTileColor: colorScheme.primary,
            selectedColor: colorScheme.primary,
            onTap: () {
              if (currentPage != 'Dashboard') {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const DashboardScreen()),
                );
              }
            },
          ),

          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('Teams'),
            selected: currentPage == 'Teams',
            selectedTileColor: colorScheme.primary,
            selectedColor: colorScheme.primary,
            onTap: () {
              if (currentPage != 'Teams') {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const TeamScreen()),
                );
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            selected: currentPage == 'Settings',
            selectedTileColor: theme.colorScheme.primary,
            selectedColor: theme.colorScheme.primary,
            onTap: () {
              if (currentPage != 'Settings') {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const SettingsScreen()),
                );
              }
            },
          ),
     
          if (projectVisibility.isNotEmpty)
            ExpansionTile(
              leading: const Icon(Icons.folder_open_outlined),
              title: const Text('Projects'),
              initiallyExpanded: true,
              childrenPadding: const EdgeInsets.only(left: 16.0),
              children: [
                for (var entry in projectVisibility.entries)
                  CheckboxListTile(
                    title: Text(entry.key),
                    value: entry.value,
                    onChanged: (bool? newValue) {
                      onProjectVisibilityChanged(entry.key, newValue ?? false);
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                    activeColor: colorScheme.primary,
                  ),
              ],
            ),
        ],
      ),
    );
  }
}