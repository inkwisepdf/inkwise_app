import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _selectedLanguage = 'English';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: ListView(
        children: [
          const ListTile(
            title: Text("App Theme"),
            subtitle: Text("Currently: Light (default)"),
          ),
          ListTile(
            title: const Text("Language"),
            subtitle: Text(_selectedLanguage),
            onTap: () => _selectLanguage(context),
          ),
          ListTile(
            title: const Text("Feedback"),
            subtitle: const Text("inkwisepdf@gmail.com"),
            onTap: () {
              // Open email client
            },
          ),
        ],
      ),
    );
  }

  void _selectLanguage(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Select Language"),
        content: DropdownButton<String>(
          value: _selectedLanguage,
          items: const [
            DropdownMenuItem(value: 'English', child: Text('English')),
            DropdownMenuItem(value: 'Hindi', child: Text('Hindi')),
            DropdownMenuItem(value: 'Tamil', child: Text('Tamil')),
            // Add more
          ],
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedLanguage = value;
              });
              Navigator.pop(context);
            }
          },
        ),
      ),
    );
  }
}
