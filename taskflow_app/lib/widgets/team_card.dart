import 'package:flutter/material.dart';
import '../models/team.dart';

class TeamCard extends StatelessWidget {
  final Team team;

  const TeamCard({super.key, required this.team});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              team.title,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const Divider(height: 24),

            Expanded(
              child: ListView.builder(
                itemCount: team.members.length,
                itemBuilder: (context, index) {
                  final member = team.members[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      radius: 20,
                      backgroundImage: AssetImage(member.avatarUrl),
                    ),
                    title: Text(member.name),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
