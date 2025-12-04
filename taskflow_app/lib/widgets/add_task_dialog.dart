import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/database_services.dart';
import '../models/task_model.dart';
import '../models/team_model.dart';
import '../models/task_list_model.dart';

class AddTaskDialog extends StatefulWidget {
  const AddTaskDialog({super.key});

  @override
  State<AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  
  final DatabaseService _dbService = DatabaseService();
  
  DateTime? _deadline;
  String? _selectedTeamId;
  String? _selectedListId; 
  List<String> _assignedMembers = [];
  
  List<TeamModel> _allTeams = [];

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _deadline = picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedListId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a list for this task")),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    String teamName = '';
    if (_selectedTeamId != null && _allTeams.isNotEmpty) {
      try {
        final team = _allTeams.firstWhere((t) => t.id == _selectedTeamId);
        teamName = team.name;
      } catch (e) {
        teamName = '';
      }
    }

    final newTask = TaskModel(
      id: '',
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      listId: _selectedListId!,
      isCompleted: false,
      assignedTo: _assignedMembers,
      deadline: _deadline ?? DateTime.now().add(const Duration(days: 7)),
      createdBy: user.uid,
      teamName: teamName, 
    );

    try {
      await FirebaseFirestore.instance.collection('tasks').add(newTask.toMap());

      if (mounted) Navigator.pop(context);
      
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Task added successfully!"))
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"))
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return AlertDialog(
      title: const Text("Add New Task"),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: "Title"),
                validator: (val) => val!.isEmpty ? "Title is required" : null,
              ),
              TextField(
                controller: _descController,
                decoration: const InputDecoration(labelText: "Description"),
                maxLines: 2,
              ),
              const SizedBox(height: 16),

              StreamBuilder<List<TaskListModel>>(
                stream: _dbService.getUserLists(user!.uid),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const LinearProgressIndicator();
                  final lists = snapshot.data!;
                  
                  return DropdownButtonFormField<String>(
                    value: _selectedListId,
                    hint: const Text("Select List (e.g. Uni)"),
                    items: lists.map((list) {
                      return DropdownMenuItem(
                        value: list.id,
                        child: Text(list.title),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedListId = val),
                    validator: (val) => val == null ? "Select a list" : null,
                  );
                },
              ),
              const SizedBox(height: 10),

              StreamBuilder<List<TeamModel>>(
                stream: _dbService.getTeams(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const SizedBox();
                  
                  _allTeams = snapshot.data!;
                  
                  return DropdownButtonFormField<String>(
                    value: _selectedTeamId,
                    hint: const Text("Select Team (Optional)"),
                    items: _allTeams.map((team) {
                      return DropdownMenuItem(
                        value: team.id,
                        child: Text(team.name),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedTeamId = val;
                        _assignedMembers.clear();
                      });
                    },
                  );
                },
              ),
              const SizedBox(height: 10),

              if (_selectedTeamId != null) ...[
                const Align(
                  alignment: Alignment.centerLeft, 
                  child: Text("Assign Members:", style: TextStyle(fontWeight: FontWeight.bold))
                ),
                Builder(
                  builder: (context) {
                    final team = _allTeams.firstWhere((t) => t.id == _selectedTeamId);
                    if (team.members.isEmpty) return const Text("No members in this team.");

                    return Column(
                      children: team.members.map((member) {
                        final isSelected = _assignedMembers.contains(member);
                        return CheckboxListTile(
                          title: Text(member),
                          value: isSelected,
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          onChanged: (checked) {
                            setState(() {
                              if (checked == true) {
                                _assignedMembers.add(member);
                              } else {
                                _assignedMembers.remove(member);
                              }
                            });
                          },
                        );
                      }).toList(),
                    );
                  }
                ),
              ],

              const SizedBox(height: 10),

              OutlinedButton.icon(
                onPressed: _pickDate,
                icon: const Icon(Icons.calendar_today),
                label: Text(_deadline == null
                    ? "Pick Deadline"
                    : "Due: ${_deadline!.toLocal().toString().split(' ')[0]}"),
              ),
            ],
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
          child: const Text("Create Task")
        ),
      ],
    );
  }
}