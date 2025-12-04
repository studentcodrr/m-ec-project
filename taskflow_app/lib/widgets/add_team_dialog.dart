import 'package:flutter/material.dart';
import '../services/database_services.dart';

class AddTeamDialog extends StatefulWidget {
  const AddTeamDialog({super.key});

  @override
  State<AddTeamDialog> createState() => _AddTeamDialogState();
}

class _AddTeamDialogState extends State<AddTeamDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  
  final List<TextEditingController> _memberControllers = [];

  final DatabaseService _dbService = DatabaseService();

  @override
  void initState() {
    super.initState();
    _addMemberField();
  }

  @override
  void dispose() {
    _nameController.dispose();
    for (var c in _memberControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _addMemberField() {
    setState(() {
      _memberControllers.add(TextEditingController());
    });
  }

  void _removeMemberField(int index) {
    setState(() {
      _memberControllers[index].dispose();
      _memberControllers.removeAt(index);
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final members = _memberControllers
        .map((c) => c.text.trim())
        .where((name) => name.isNotEmpty)
        .toList();

    try {
      await _dbService.addTeam(_nameController.text.trim(), members);
      if (mounted) Navigator.pop(context);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Team created successfully!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Create New Team"),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: "Team Name",
                    hintText: "e.g. Development, Marketing",
                    prefixIcon: Icon(Icons.group),
                  ),
                  validator: (val) => val!.isEmpty ? "Team name is required" : null,
                ),
                const SizedBox(height: 20),
                
                const Text("Members", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                
                ..._memberControllers.asMap().entries.map((entry) {
                  final index = entry.key;
                  final controller = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: controller,
                            decoration: InputDecoration(
                              hintText: "Member Name",
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                          onPressed: () => _removeMemberField(index),
                          tooltip: "Remove member",
                        ),
                      ],
                    ),
                  );
                }),

                TextButton.icon(
                  onPressed: _addMemberField,
                  icon: const Icon(Icons.add),
                  label: const Text("Add Member"),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context), 
          child: const Text("Cancel")
        ),
        ElevatedButton(
          onPressed: _submit, 
          child: const Text("Create Team")
        ),
      ],
    );
  }
}