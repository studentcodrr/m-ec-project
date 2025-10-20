import 'package:flutter/material.dart';
import '../models/team.dart';
import '../widgets/team_card.dart';
import 'task_list_screen.dart';

class TeamScreen extends StatelessWidget {
  const TeamScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mockTeams = [
      Team(name: "Dev Team", members: ["Alice", "Bob", "Charlie"]),
      Team(name: "Design Squad", members: ["Dana", "Eli"]),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Your Teams")),
      body: ListView.builder(
        itemCount: mockTeams.length,
        itemBuilder: (context, index) {
          final team = mockTeams[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TaskListScreen(team: team),
                ),
              );
            },
            child: TeamCard(team: team),
          );
        },
      ),
    );
  }
}
