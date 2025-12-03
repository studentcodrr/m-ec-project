import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TaskPage extends StatefulWidget {
  const TaskPage({super.key});

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Enable Firestore offline persistence
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ======================= ADD TASK DIALOG =======================
  void _showAddTaskDialog() {
    final _titleController = TextEditingController();
    final _descController = TextEditingController();
    DateTime? _deadline;
    String? _selectedTeam;
    List<String> _assignedMembers = [];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text("Add Task"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: _titleController, decoration: const InputDecoration(labelText: "Title")),
                TextField(controller: _descController, decoration: const InputDecoration(labelText: "Description")),
                const SizedBox(height: 10),

                // Pick team
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('teams').snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const CircularProgressIndicator();
                    final teams = snapshot.data!.docs;
                    return DropdownButton<String>(
                      hint: const Text("Select Team"),
                      value: _selectedTeam,
                      isExpanded: true,
                      items: teams.map((team) {
                        return DropdownMenuItem<String>(
                          value: team.id,
                          child: Text(team['name']),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedTeam = value;
                          _assignedMembers = [];
                        });
                      },
                    );
                  },
                ),
                const SizedBox(height: 10),

                // Pick members of selected team
                if (_selectedTeam != null)
                  StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance.collection('teams').doc(_selectedTeam).snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const SizedBox();
                      final teamDoc = snapshot.data!;
                      final members = List<String>.from(teamDoc['members'] ?? []);
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: members.map((member) {
                          final isSelected = _assignedMembers.contains(member);
                          return CheckboxListTile(
                            title: Text(member),
                            value: isSelected,
                            onChanged: (value) {
                              setState(() {
                                if (value == true) {
                                  _assignedMembers.add(member);
                                } else {
                                  _assignedMembers.remove(member);
                                }
                              });
                            },
                          );
                        }).toList(),
                      );
                    },
                  ),
                const SizedBox(height: 10),

                // Pick deadline
                ElevatedButton(
                  onPressed: () async {
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                    );
                    if (pickedDate != null) setState(() => _deadline = pickedDate);
                  },
                  child: Text(_deadline == null
                      ? "Pick Deadline"
                      : "Deadline: ${_deadline!.toLocal()}".split(' ')[0]),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
            ElevatedButton(
              onPressed: () async {
                if (_titleController.text.isEmpty || _selectedTeam == null) return;

                FirebaseFirestore.instance.collection('tasks').add({
                  'title': _titleController.text,
                  'description': _descController.text,
                  'teamId': _selectedTeam,
                  'assignedTo': _assignedMembers,
                  'deadline': Timestamp.fromDate(_deadline ?? DateTime.now().add(const Duration(days: 7))),
                  'status': 'in_progress',
                  'createdBy': FirebaseAuth.instance.currentUser!.uid,
                }).then((doc) {
                  print("Task added: ${doc.id}");
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Task added successfully!")),
                  );
                }).catchError((error) {
                  print("Failed to add task: $error");
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error adding task: $error")),
                  );
                });
              },
              child: const Text("Add Task"),
            ),
          ],
        ),
      ),
    );
  }

  // ======================= ADD TEAM DIALOG =======================
  void _showAddTeamDialog() {
    final _nameController = TextEditingController();
    final _membersController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add Team"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: "Team Name")),
            TextField(
              controller: _membersController,
              decoration: const InputDecoration(labelText: "Members (comma separated)"),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              final members = _membersController.text.split(',').map((e) => e.trim()).toList();
              if (_nameController.text.isEmpty) return;

              FirebaseFirestore.instance.collection('teams').add({
                'name': _nameController.text,
                'members': members,
              }).then((doc) {
                print("Team added: ${doc.id}");
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Team added successfully!")),
                );
              }).catchError((error) {
                print("Failed to add team: $error");
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Error adding team: $error")),
                );
              });
            },
            child: const Text("Add Team"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('TaskFlow'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Theme.of(context).colorScheme.primary,
          tabs: const [
            Tab(text: 'Tasks'),
            Tab(text: 'Teams'),
            Tab(text: 'Progress'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // ======================= TASKS TAB =======================
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('tasks')
                .where('createdBy', isEqualTo: user!.uid)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              final tasks = snapshot.data!.docs;
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  final task = tasks[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      title: Text(task['title']),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(task['description']),
                          Text("Due: ${task['deadline'].toDate().toLocal()}"),
                          Text("Assigned: ${(task['assignedTo'] as List).join(', ')}"),
                        ],
                      ),
                      trailing: Text(task['status']),
                    ),
                  );
                },
              );
            },
          ),

          // ======================= TEAMS TAB =======================
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('teams').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              final teams = snapshot.data!.docs;
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: teams.length,
                itemBuilder: (context, index) {
                  final team = teams[index];
                  final members = List<String>.from(team['members'] ?? []);
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      title: Text(team['name']),
                      subtitle: Text("Members: ${members.join(', ')}"),
                    ),
                  );
                },
              );
            },
          ),

          // ======================= PROGRESS TAB =======================
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('tasks')
                .where('createdBy', isEqualTo: user.uid)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              final tasks = snapshot.data!.docs;
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  final task = tasks[index];
                  double progress = 0.0;
                  switch (task['status']) {
                    case 'completed':
                      progress = 1.0;
                      break;
                    case 'in_progress':
                      progress = 0.5;
                      break;
                    case 'pending':
                      progress = 0.1;
                      break;
                  }
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      title: Text(task['title']),
                      subtitle: LinearProgressIndicator(
                        value: progress,
                        color: Theme.of(context).colorScheme.primary,
                        backgroundColor: Colors.grey.shade300,
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'addTask',
            onPressed: _showAddTaskDialog,
            child: const Icon(Icons.add_task),
            tooltip: "Add Task",
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: 'addTeam',
            onPressed: _showAddTeamDialog,
            child: const Icon(Icons.group_add),
            tooltip: "Add Team",
          ),
        ],
      ),
    );
  }
}
