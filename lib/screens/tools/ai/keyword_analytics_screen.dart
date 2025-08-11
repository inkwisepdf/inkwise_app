import 'package:flutter/material.dart';
import '../../../theme.dart';

class KeywordAnalyticsScreen extends StatelessWidget {
  const KeywordAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Keyword Analytics"),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.analytics,
              size: 64,
              color: AppColors.primaryGreen,
            ),
            const SizedBox(height: 16),
            Text(
              "Keyword Density & Analytics",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              "Analyze word frequency for research/legal PDFs",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Implement keyword analytics functionality
              },
              icon: const Icon(Icons.analytics),
              label: const Text("Analyze Keywords"),
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