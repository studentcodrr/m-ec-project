import 'package:flutter/material.dart';
import '../screens/dashboard.dart';
import '../screens/teams.dart'; 
import '../screens/settings.dart'; 

class Sidebar extends StatelessWidget {
  final String currentPage; // To know which page is currently active
  final Map<String, bool> projectVisibility;
  final Function(String, bool) onProjectVisibilityChanged;

  const Sidebar({
    super.key,
    required this.currentPage, // Add this required parameter
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
          // Dashboard Navigation
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            // <<< CHANGE: Selection is now dynamic
            selected: currentPage == 'Dashboard',
            selectedTileColor: colorScheme.primary.withOpacity(0.1),
            selectedColor: colorScheme.primary,
            onTap: () {
              // <<< CHANGE: Added navigation
              if (currentPage != 'Dashboard') {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const DashboardScreen()),
                );
              }
            },
          ),

          // Teams Navigation
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('Teams'),
            // <<< CHANGE: Selection is now dynamic
            selected: currentPage == 'Team',
            selectedTileColor: colorScheme.primary.withOpacity(0.1),
            selectedColor: colorScheme.primary,
            onTap: () {
              // <<< CHANGE: Added navigation
              if (currentPage != 'Team') {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const TeamScreen()),
                );
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            selected: currentPage == 'Settings', // Highlight if active
            selectedTileColor: theme.colorScheme.primary.withOpacity(0.1),
            selectedColor: theme.colorScheme.primary,
            onTap: () {
              // Navigate to SettingsScreen
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