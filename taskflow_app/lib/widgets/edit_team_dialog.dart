import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/database_services.dart';
import '../models/team_model.dart';

class EditTeamDialog extends StatefulWidget {
  const EditTeamDialog({super.key});

  @override
  State<EditTeamDialog> createState() => _EditTeamDialogState();
}

class _EditTeamDialogState extends State<EditTeamDialog> {
  final DatabaseService _dbService = DatabaseService();
  final TextEditingController _memberController = TextEditingController();
  
  String? _selectedTeamId;

  @override
  void dispose() {
    _memberController.dispose();
    super.dispose();
  }

  Future<void> _addMember() async {
    if (_selectedTeamId == null || _memberController.text.trim().isEmpty) return;
    
    final newMember = _memberController.text.trim();
    
    try {
      await FirebaseFirestore.instance.collection('teams').doc(_selectedTeamId).update({
        'members': FieldValue.arrayUnion([newMember])
      });
      _memberController.clear();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _removeMember(String member) async {
    if (_selectedTeamId == null) return;

    try {
      await FirebaseFirestore.instance.collection('teams').doc(_selectedTeamId).update({
        'members': FieldValue.arrayRemove([member])
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Manage Team Members"),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            StreamBuilder<List<TeamModel>>(
              stream: _dbService.getTeams(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const LinearProgressIndicator();
                final teams = snapshot.data!;
                
                if (teams.isEmpty) {
                  return const Text("No teams available.");
                }

                return DropdownButtonFormField<String>(
                  value: _selectedTeamId,
                  isExpanded: true,
                  hint: const Text("Select Team to Edit"),
                  items: teams.map((team) {
                    return DropdownMenuItem(
                      value: team.id,
                      child: Text(team.name),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedTeamId = val;
                    });
                  },
                );
              },
            ),
            
            const SizedBox(height: 20),

            if (_selectedTeamId != null) ...[
               const Align(
                 alignment: Alignment.centerLeft,
                 child: Text("Current Members:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
               ),
               const SizedBox(height: 8),

               StreamBuilder<DocumentSnapshot>(
                 stream: FirebaseFirestore.instance.collection('teams').doc(_selectedTeamId).snapshots(),
                 builder: (context, snapshot) {
                   if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                   if (!snapshot.data!.exists) return const Text("Team not found");
                   
                   final data = snapshot.data!.data() as Map<String, dynamic>;
                   final List<dynamic> rawMembers = data['members'] ?? [];
                   final List<String> members = rawMembers.map((e) => e.toString()).toList();

                   return Flexible(
                     child: Container(
                       decoration: BoxDecoration(
                         border: Border.all(color: Colors.grey.shade300),
                         borderRadius: BorderRadius.circular(8),
                       ),
                       child: members.isEmpty 
                         ? const Padding(
                             padding: EdgeInsets.all(16.0),
                             child: Text("No members yet.", style: TextStyle(color: Colors.grey)),
                           )
                         : ListView.separated(
                           shrinkWrap: true,
                           itemCount: members.length,
                           separatorBuilder: (_, __) => const Divider(height: 1),
                           itemBuilder: (context, index) {
                             final member = members[index];
                             return ListTile(
                               title: Text(member, style: const TextStyle(fontSize: 14)),
                               trailing: IconButton(
                                 icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                                 onPressed: () => _removeMember(member),
                               ),
                               dense: true,
                               contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                             );
                           },
                         ),
                     ),
                   );
                 }
               ),
               
               const SizedBox(height: 16),
               
               Row(
                 children: [
                   Expanded(
                     child: TextField(
                       controller: _memberController,
                       decoration: const InputDecoration(
                         labelText: "Add new member...",
                         isDense: true,
                         border: OutlineInputBorder(),
                         contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                       ),
                     ),
                   ),
                   const SizedBox(width: 8),
                   IconButton.filled(
                     icon: const Icon(Icons.person_add),
                     onPressed: _addMember,
                     style: IconButton.styleFrom(backgroundColor: Colors.teal),
                   )
                 ],
               ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Done"),
        )
      ],
    );
  }
}