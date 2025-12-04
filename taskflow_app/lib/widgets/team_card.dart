import 'package:flutter/material.dart';
import '../models/team_model.dart';
import '../services/database_services.dart';

class TeamCard extends StatelessWidget {
  final TeamModel team;

  const TeamCard({super.key, required this.team});

  Color _getAvatarColor(String name) {
    final colors = [
      Colors.blue.shade100, Colors.red.shade100,
      Colors.green.shade100, Colors.orange.shade100,
      Colors.purple.shade100,
    ];
    return colors[name.length % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final dbService = DatabaseService();

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    team.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.grey, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  tooltip: "Delete Team",
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text("Delete Team?"),
                        content: Text("Are you sure you want to delete '${team.name}'?"),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
                          TextButton(
                            onPressed: () {
                              dbService.deleteTeam(team.id);
                              Navigator.pop(ctx);
                            },
                            child: const Text("Delete", style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
            const Divider(height: 24),
            
            const Text(
              "Members",
              style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            
            Expanded(
              child: team.members.isEmpty
                  ? const Center(child: Text("No members assigned", style: TextStyle(color: Colors.grey)))
                  : Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: team.members.map((member) {
                        final initial = member.isNotEmpty ? member[0].toUpperCase() : '?';
                        return Tooltip(
                          message: member,
                          child: CircleAvatar(
                            radius: 16,
                            backgroundColor: _getAvatarColor(member),
                            child: Text(
                              initial,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}