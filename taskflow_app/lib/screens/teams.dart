import 'package:flutter/material.dart';
import '../models/team.dart';
import '../widgets/sidebar.dart';
import '../widgets/team_card.dart';

class TeamScreen extends StatefulWidget {
  const TeamScreen({super.key});

  @override
  State<TeamScreen> createState() => _TeamScreenState();
}

class _TeamScreenState extends State<TeamScreen> {
  final List<Team> _teams = [
    Team(title: 'Development', members: [
      TeamMember(name: 'Alice Johnson', avatarUrl: 'assets/avatar1.png'),
      TeamMember(name: 'Bob Williams', avatarUrl: 'assets/avatar2.png'),
      TeamMember(name: 'Eve Davis', avatarUrl: 'assets/avatar3.png'),
    ]),
    Team(title: 'Marketing', members: [
      TeamMember(name: 'Charlie Brown', avatarUrl: 'assets/avatar4.png'),
      TeamMember(name: 'Diana Prince', avatarUrl: 'assets/avatar5.png'),
    ]),
    Team(title: 'Design', members: [
      TeamMember(name: 'Frank Miller', avatarUrl: 'assets/avatar1.png'),
      TeamMember(name: 'Grace Hopper', avatarUrl: 'assets/avatar2.png'),
      TeamMember(name: 'Henry Ford', avatarUrl: 'assets/avatar4.png'),
    ]),
  ];

  // We don't need project visibility here, so we pass an empty map.
  final Map<String, bool> _projectVisibility = {};

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
     appBar: AppBar(
        leading: Icon(Icons.done_all_outlined, color: colorScheme.primary),
        title: const Text("TaskList"),
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Sidebar(
            currentPage: "Teams",
            projectVisibility: _projectVisibility,
            onProjectVisibilityChanged: (name, isVisible) {
            },
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(24),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 350, 
                crossAxisSpacing: 24,
                mainAxisSpacing: 24,
                childAspectRatio: 0.8, 
              ),
              itemCount: _teams.length,
              itemBuilder: (context, index) {
                return TeamCard(team: _teams[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}