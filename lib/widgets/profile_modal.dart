import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mini_project_new/api/auth_api.dart';  // Assuming you've created auth API functions

class ProfileModal extends StatelessWidget {
  final String email;
  final String username;
  final Function(bool) onThemeToggle;
  final Function onLogout;

  const ProfileModal({
    Key? key,
    required this.email,
    required this.username,
    required this.onThemeToggle,
    required this.onLogout,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text(
        "Your Profile",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: Text(
              username.isNotEmpty ? username[0].toUpperCase() : "?",
              style: const TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            username,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          Text(email, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 20),
          Row(
            children: [
              const Icon(Icons.brightness_6, size: 20),
              const SizedBox(width: 10),
              const Text("Dark Theme"),
              const Spacer(),
              Switch(
                value: isDark,
                onChanged: (value) {
                  onThemeToggle(value);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        ],
      ),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      actions: [
        TextButton.icon(
          icon: const Icon(Icons.logout, color: Colors.red),
          label: const Text("Log Out", style: TextStyle(color: Colors.red)),
          onPressed: () async {
            // Show confirmation dialog for logout
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                title: const Text("Confirm Logout"),
                content: const Text("Are you sure you want to log out?"),
                actions: [
                  TextButton(
                    child: const Text("Cancel"),
                    onPressed: () => Navigator.pop(context),
                  ),
                  TextButton(
                    child: const Text("Log Out", style: TextStyle(color: Colors.red)),
                    onPressed: () async {
                      // Clear JWT token from secure storage on logout
                      final storage = FlutterSecureStorage();
                      await storage.delete(key: 'jwt_token');
                      onLogout();  // Call the logout callback
                      Navigator.pop(context); // Close confirmation dialog
                      Navigator.pop(context); // Close profile modal
                    },
                  ),
                ],
              ),
            );
          },
        ),
        TextButton(
          child: const Text("Close"),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }
}
