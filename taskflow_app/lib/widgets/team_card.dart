import 'package:flutter/material.dart';
import '../models/team.dart';

class TeamCard extends StatelessWidget {
  final Team team;

  const TeamCard({super.key, required this.team});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(child: Text(team.name[0])),
        title: Text(team.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("${team.members.length} members"),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
