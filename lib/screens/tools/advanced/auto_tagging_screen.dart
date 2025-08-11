import 'package:flutter/material.dart';
import '../../../theme.dart';

class AutoTaggingScreen extends StatelessWidget {
  const AutoTaggingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Auto Tagging"),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.label,
              size: 64,
              color: AppColors.primaryGreen,
            ),
            const SizedBox(height: 16),
            Text(
              "Auto-Tagging PDFs",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              "Detect document type (invoice, contract, book) and auto-assign tags",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Implement auto tagging functionality
              },
              icon: const Icon(Icons.label),
              label: const Text("Auto Tag"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}