import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

class SettingsTab extends StatefulWidget {
  const SettingsTab({super.key});

  @override
  State<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
  final _passwordController = TextEditingController();
  final user = FirebaseAuth.instance.currentUser;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Change Password"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Note: For security, you may need to re-login if you haven't signed in recently.",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "New Password",
                hintText: "Enter at least 6 characters",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              _passwordController.clear();
              Navigator.pop(context);
            },
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_passwordController.text.length < 6) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Password must be at least 6 characters"),
                  ),
                );
                return;
              }

              try {
                await user?.updatePassword(_passwordController.text.trim());
                if (mounted) Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Password updated successfully!"),
                  ),
                );
                _passwordController.clear();
              } on FirebaseAuthException catch (e) {
                Navigator.pop(context);
                if (e.code == 'requires-recent-login') {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Security check failed. Please Log Out and Log In again to change password.",
                      ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error: ${e.message}")),
                  );
                }
              }
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) return const Center(child: Text("Not logged in"));

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        //Profile Card
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade300),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.teal.shade100,
                  child: Text(
                    user!.email != null && user!.email!.isNotEmpty
                        ? user!.email![0].toUpperCase()
                        : '?',
                    style: TextStyle(fontSize: 24, color: Colors.teal.shade800),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Signed in as",
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user!.email ?? "Guest User",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),
        // UID card (so admins can identify users)
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade300),
          ),
          child: ListTile(
            leading: const Icon(Icons.fingerprint),
            title: const Text("Your UID"),
            subtitle: Text(user!.uid),
            trailing: IconButton(
              icon: const Icon(Icons.copy),
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: user!.uid));
                if (!mounted) return;
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text("UID copied")));
              },
            ),
          ),
        ),
        const SizedBox(height: 24),

        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            "Account",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
          ),
        ),

        //Actions List
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade300),
          ),
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.lock_outline),
                title: const Text("Change Password"),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey,
                ),
                onTap: _showChangePasswordDialog,
              ),
              Divider(height: 1, color: Colors.grey.shade200),
              ListTile(
                leading: const Icon(Icons.fingerprint),
                title: const Text("Your UID"),
                subtitle: SelectableText(user!.uid),
                trailing: IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: user!.uid));
                    if (!mounted) return;
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(const SnackBar(content: Text("UID copied")));
                  },
                ),
              ),
              Divider(height: 1, color: Colors.grey.shade200),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text(
                  "Log Out",
                  style: TextStyle(color: Colors.red),
                ),
                onTap: _logout,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
