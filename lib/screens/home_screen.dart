import 'package:flutter/material.dart';
import 'tools_screen.dart';
import 'recent_files_screen.dart';
import '../widgets/tool_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Inkwise PDF"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(16),
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        children: [
          ToolCard(
            title: "Utility Tools",
            icon: Icons.build,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ToolsScreen()),
            ),
          ),
          ToolCard(
            title: "Recent Files",
            icon: Icons.history,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const RecentFilesScreen()),
            ),
          ),
        ],
      ),
    );
  }
}
