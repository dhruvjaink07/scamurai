import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: ListView(
        children: [
          _buildSectionTitle("Profile Settings"),
          _buildSettingsTile(Icons.person, "Edit Profile", () {
            // Navigate to Edit Profile Screen
          }),
          _buildSettingsTile(Icons.lock, "Change Password", () {
            // Navigate to Change Password Screen
          }),
          _buildSectionTitle("Notification Settings"),
          _buildSettingsTile(Icons.notifications, "Enable Notifications", () {
            // Toggle Push Notifications
          }, hasSwitch: true),
          _buildSectionTitle("Appearance Settings"),
          _buildSettingsTile(Icons.dark_mode, "Dark Mode", () {
            // Toggle Dark Mode
          }, hasSwitch: true),
          _buildSectionTitle("Privacy & Security"),
          _buildSettingsTile(Icons.delete, "Clear Cache", () {
            // Clear Cache Action
          }),
          _buildSettingsTile(Icons.logout, "Logout", () {
            // Handle Logout
          }),
          _buildSectionTitle("About App"),
          _buildSettingsTile(Icons.info, "Version Info", () {}),
          _buildSettingsTile(Icons.article, "Terms & Conditions", () {}),
          _buildSettingsTile(Icons.contact_mail, "Contact Us", () {}),
          _buildSectionTitle("Critical Settings ⚠"),
          _buildSettingsTile(Icons.language, "Change Default Browser", () {
            // Change Default Browser Action
          }),
          _buildSettingsTile(Icons.delete_forever, "Delete User", () {
            // Confirm Delete User Action
          }, isCritical: true),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Text(title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildSettingsTile(IconData icon, String title, VoidCallback onTap,
      {bool hasSwitch = false, bool isCritical = false}) {
    return ListTile(
      leading: Icon(icon, color: isCritical ? Colors.red : Colors.blue),
      title: Text(title,
          style: TextStyle(color: isCritical ? Colors.red : Colors.black)),
      trailing: hasSwitch
          ? Switch(value: true, onChanged: (val) {})
          : const Icon(Icons.arrow_forward_ios),
      onTap: onTap,
    );
  }
}
