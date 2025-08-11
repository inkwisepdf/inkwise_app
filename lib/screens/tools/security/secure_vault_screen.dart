import 'package:flutter/material.dart';
import '../../../theme.dart';

class SecureVaultScreen extends StatelessWidget {
  const SecureVaultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Secure Vault"),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.vault,
              size: 64,
              color: AppColors.primaryPurple,
            ),
            const SizedBox(height: 16),
            Text(
              "Secure Vault",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              "Store sensitive PDFs with local encryption",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Implement secure vault functionality
              },
              icon: const Icon(Icons.vault),
              label: const Text("Open Vault"),
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