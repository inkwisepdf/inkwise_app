import 'package:flutter/material.dart';
import '../../../theme.dart';

class TableExtractorScreen extends StatelessWidget {
  const TableExtractorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Table Extractor"),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.table_chart,
              size: 64,
              color: AppColors.primaryGreen,
            ),
            const SizedBox(height: 16),
            Text(
              "PDF to Editable Tables",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              "Extract tables into editable spreadsheet-like format",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Implement table extraction functionality
              },
              icon: const Icon(Icons.table_chart),
              label: const Text("Extract Tables"),
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