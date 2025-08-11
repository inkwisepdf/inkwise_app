import 'package:flutter/material.dart';
import '../../../theme.dart';

class PDFPasswordScreen extends StatelessWidget {
  const PDFPasswordScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Password Protection"),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primaryRed.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.lock,
                size: 64,
                color: AppColors.primaryRed,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Password Protection",
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppColors.primaryRed,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Add or remove password protection from your PDF",
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Implement password protection functionality
              },
              icon: const Icon(Icons.build),
              label: const Text("Coming Soon"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryRed,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}