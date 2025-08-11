import 'package:flutter/material.dart';
import '../../../theme.dart';

class PDFGrayscaleScreen extends StatelessWidget {
  const PDFGrayscaleScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Convert to Grayscale"),
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
                color: AppColors.primaryOrange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.filter_bw,
                size: 64,
                color: AppColors.primaryOrange,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Convert to Grayscale",
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppColors.primaryOrange,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Convert your PDF to black and white",
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Implement grayscale conversion functionality
              },
              icon: const Icon(Icons.build),
              label: const Text("Coming Soon"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryOrange,
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