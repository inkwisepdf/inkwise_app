import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';

class PdfViewerScreen extends StatelessWidget {
  const PdfViewerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final filePath = ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(
      appBar: const CustomAppBar(title: 'PDF Viewer'),
      body: Center(
        child: Text(
          'Render PDF:\n$filePath',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
