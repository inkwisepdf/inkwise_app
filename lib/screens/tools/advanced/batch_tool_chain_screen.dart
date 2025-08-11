import 'package:flutter/material.dart';
import '../../../theme.dart';

class BatchToolChainScreen extends StatelessWidget {
  const BatchToolChainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Batch Tool Chain"),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.auto_fix_high,
              size: 64,
              color: AppColors.primaryPurple,
            ),
            const SizedBox(height: 16),
            Text(
              "Batch Tool Chain",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              "Apply multiple tools (compress → watermark → password lock) in one step",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Implement batch tool chain functionality
              },
              icon: const Icon(Icons.auto_fix_high),
              label: const Text("Create Chain"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryPurple,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}