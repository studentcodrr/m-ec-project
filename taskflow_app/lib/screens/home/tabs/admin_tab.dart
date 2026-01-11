import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

import '../../../services/database_services.dart';

class AdminTab extends StatefulWidget {
  const AdminTab({super.key});

  @override
  State<AdminTab> createState() => _AdminTabState();
}

class _AdminTabState extends State<AdminTab> {
  final uidCtrl = TextEditingController();
  bool makeAdmin = true;
  bool loading = false;

  Future<void> _submit() async {
    setState(() => loading = true);
    try {
      final callable = FirebaseFunctions.instance.httpsCallable('setAdmin');
      final res = await callable.call({
        'uid': uidCtrl.text.trim(),
        'admin': makeAdmin,
      });

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("OK: ${res.data}")));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  void dispose() {
    uidCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          const Text(
            "Admin Panel",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: uidCtrl,
            decoration: InputDecoration(
              labelText: "Target user UID",
              border: const OutlineInputBorder(),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: "Paste",
                    icon: const Icon(Icons.content_paste),
                    onPressed: () async {
                      final data = await Clipboard.getData('text/plain');
                      final text = (data?.text ?? '').trim();
                      if (text.isNotEmpty) {
                        uidCtrl.text = text;
                        setState(() {}); // refresh if needed
                      }
                    },
                  ),
                  IconButton(
                    tooltip: "Clear",
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      uidCtrl.clear();
                      setState(() {});
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            value: makeAdmin,
            onChanged: (v) => setState(() => makeAdmin = v),
            title: Text(makeAdmin ? "Set admin = true" : "Set admin = false"),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: loading ? null : _submit,
            child: Text(loading ? "Working..." : "Apply"),
          ),
          const SizedBox(height: 24),
          const Text(
            "All Users",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .orderBy('lastLoginAt', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final docs = snapshot.data!.docs;

              if (docs.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    "No user profiles found.\nMake sure you create users/{uid} documents after login/signup.",
                    style: TextStyle(color: Colors.grey),
                  ),
                );
              }

              return Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
                child: Column(
                  children: docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final uid = (data['uid'] ?? doc.id).toString();
                    final email = (data['email'] ?? '').toString();
                    final name = (data['displayName'] ?? '').toString();

                    return Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.person_outline),
                          title: Text(
                            name.isNotEmpty
                                ? name
                                : (email.isNotEmpty ? email : uid),
                          ),
                          subtitle: SelectableText(uid),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                tooltip: "Copy UID",
                                icon: const Icon(Icons.copy),
                                onPressed: () async {
                                  await Clipboard.setData(
                                    ClipboardData(text: uid),
                                  );
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("UID copied")),
                                  );
                                },
                              ),
                              IconButton(
                                tooltip: "Load into target field",
                                icon: const Icon(Icons.north_west),
                                onPressed: () {
                                  uidCtrl.text = uid;
                                  setState(() {});
                                },
                              ),
                            ],
                          ),
                        ),
                        Divider(height: 1, color: Colors.grey.shade200),
                      ],
                    );
                  }).toList(),
                ),
              );
            },
          ),

          const SizedBox(height: 24),
          const Text(
            'Projects (Lists)',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),

          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('lists').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    'Error loading projects: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(12),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final docs = snapshot.data?.docs ?? [];

              if (docs.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(12),
                  child: Text(
                    'No projects found in Firestore collection "lists".',
                    style: TextStyle(color: Colors.grey),
                  ),
                );
              }

              //shrinkWrap + NeverScrollablePhysics if AdminTab is a ListView
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: docs.length,
                itemBuilder: (context, i) {
                  final doc = docs[i];
                  final data = doc.data() as Map<String, dynamic>;

                  final title = (data['title'] ?? 'Untitled project')
                      .toString();
                  final createdBy = (data['createdBy'] ?? '').toString();

                  return ListTile(
                    title: Text(title),
                    subtitle: Text('createdBy: $createdBy'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        final ok = await showDialog<bool>(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('Delete project'),
                            content: Text(
                              'Delete "$title"?\n\nThis will also delete its tasks.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text(
                                  'Delete',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        );

                        if (ok == true) {
                          await DatabaseService().deleteTaskList(doc.id);
                        }
                      },
                    ),
                  );
                },
              );
            },
          ),

          const SizedBox(height: 8),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('lists')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;

                if (docs.isEmpty) {
                  return const Center(child: Text('No projects found.'));
                }

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, i) {
                    final doc = docs[i];
                    final data = doc.data() as Map<String, dynamic>;

                    final title = (data['title'] ?? 'Untitled project')
                        .toString();
                    final createdBy = (data['createdBy'] ?? '').toString();

                    return ListTile(
                      title: Text(title),
                      subtitle: Text('createdBy: $createdBy'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          final ok = await showDialog<bool>(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text('Delete project'),
                              content: Text(
                                'Delete "$title"?\n\nThis will also delete its tasks.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text(
                                    'Delete',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          );

                          if (ok == true) {
                            await DatabaseService().deleteTaskList(doc.id);
                          }
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
