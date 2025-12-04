import 'package:flutter/material.dart';
import '../../../../services/database_services.dart';
import '../../../../models/team_model.dart';
import '../../../../widgets/team_card.dart';
import '../../../../widgets/add_team_dialog.dart'; 

class TeamsTab extends StatelessWidget {
  const TeamsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final dbService = DatabaseService();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => const AddTeamDialog(),
                );
              },
              icon: const Icon(Icons.group_add),
              label: const Text("Create New Team"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.teal,
                elevation: 0,
                side: const BorderSide(color: Colors.teal),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ),

        Expanded(
          child: StreamBuilder<List<TeamModel>>(
            stream: dbService.getTeams(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text("Error: ${snapshot.error}"));
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.group_off, size: 60, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      const Text("No teams created yet."),
                    ],
                  ),
                );
              }

              final teams = snapshot.data!;

              return GridView.builder(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 350,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.1, 
                ),
                itemCount: teams.length,
                itemBuilder: (context, index) {
                  return TeamCard(team: teams[index]);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}