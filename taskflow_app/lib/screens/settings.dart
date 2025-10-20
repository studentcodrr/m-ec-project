// lib/screens/settings_screen.dart

import 'package:flutter/material.dart';
import '../widgets/sidebar.dart';
import 'login.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Icon(Icons.settings, color: Theme.of(context).colorScheme.primary),
        title: const Text("Settings"),
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Sidebar(
            currentPage: 'Settings', // To highlight the correct menu item
            projectVisibility: const {}, // No projects needed here
            onProjectVisibilityChanged: (name, isVisible) {},
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(40.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Account Settings',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 32),
                  
                  // A reusable button widget for consistency
                  _SettingsButton(
                    label: 'Change Username',
                    icon: Icons.person_outline,
                    onTap: () {
                      // This button is disabled, so nothing happens.
                    },
                  ),
                  const SizedBox(height: 16),
                  _SettingsButton(
                    label: 'Change Password',
                    icon: Icons.lock_outline,
                    onTap: () {
                      // This button is also disabled.
                    },
                  ),
                  const SizedBox(height: 16),
                  _SettingsButton(
                    label: 'Log Out',
                    icon: Icons.logout,
                    isDestructive: true, // Makes the button red
                    onTap: () {
                      // Navigate to the LoginScreen and remove all previous screens
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                        (Route<dynamic> route) => false, // This predicate removes all routes
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// A helper widget for the settings buttons to avoid code repetition
class _SettingsButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  final bool isDestructive;

  const _SettingsButton({
    required this.label,
    required this.icon,
    this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? Colors.red.shade400 : Theme.of(context).colorScheme.primary;
    final isDisabled = onTap == null;

    return ElevatedButton.icon(
      icon: Icon(icon, color: isDisabled ? Colors.grey : color),
      label: Text(
        label,
        style: TextStyle(color: isDisabled ? Colors.grey : color, fontWeight: FontWeight.bold),
      ),
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(250, 50),
        alignment: Alignment.centerLeft,
        backgroundColor: Colors.white,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      // Set onPressed to null to disable the button visually and functionally
      onPressed: isDisabled ? null : onTap,
    );
  }
}