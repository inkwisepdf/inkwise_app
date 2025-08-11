import 'package:flutter/material.dart';
import '../../../theme.dart';

class ColorConverterScreen extends StatelessWidget {
  const ColorConverterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Color Converter"),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.palette,
              size: 64,
              color: AppColors.primaryOrange,
            ),
            const SizedBox(height: 16),
            Text(
              "Color to B/W Converter",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              "Advanced scanner-like processing with threshold control",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Implement color conversion functionality
              },
              icon: const Icon(Icons.palette),
              label: const Text("Convert Colors"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryOrange,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}