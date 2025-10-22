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
      TeamMember(name: 'Mihai', avatarUrl: ''),
      TeamMember(name: 'Oana', avatarUrl: ''),
      TeamMember(name: 'Alex', avatarUrl: ''),
    ]),
    Team(title: 'IT', members: [
      TeamMember(name: 'Maia', avatarUrl: ''),
      TeamMember(name: 'Diana', avatarUrl: ''),
    ]),
    Team(title: 'Design', members: [
      TeamMember(name: 'Sara', avatarUrl: ''),
      TeamMember(name: 'George', avatarUrl: ''),
      TeamMember(name: 'Ion', avatarUrl: ''),
    ]),
  ];

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