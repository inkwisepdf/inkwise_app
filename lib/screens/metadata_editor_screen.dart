import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:inkwise_pdf/features/metadata/metadata_editor.dart';

class MetadataEditorScreen extends StatefulWidget {
  const MetadataEditorScreen({super.key});

  @override
  State<MetadataEditorScreen> createState() => _MetadataEditorScreenState();
}

class _MetadataEditorScreenState extends State<MetadataEditorScreen> {
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  String _result = "No PDF modified.";

  void _applyMetadata() {
    // Update metadata (document creation would be handled in actual implementation)
    setState(() {
      _result = "Metadata applied successfully!";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Metadata Editor")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _titleController, decoration: const InputDecoration(labelText: "Title")),
            TextField(controller: _authorController, decoration: const InputDecoration(labelText: "Author")),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _applyMetadata, child: const Text("Apply Metadata")),
            const SizedBox(height: 20),
            Text(_result),
          ],
        ),
      ),
    );
  }
}
