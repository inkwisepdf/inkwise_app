import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import '../features/metadata/metadata_editor.dart';

class MetadataEditorScreen extends StatefulWidget {
  const MetadataEditorScreen({Key? key}) : super(key: key);

  @override
  _MetadataEditorScreenState createState() => _MetadataEditorScreenState();
}

class _MetadataEditorScreenState extends State<MetadataEditorScreen> {
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  String _result = "No PDF modified.";

  void _applyMetadata() {
    final newDoc = MetadataEditor.updateMetadata(
      pw.Document(),
      _titleController.text,
      _authorController.text,
    );

    setState(() {
      _result = "Metadata applied successfully!";
    });

    // You can later add code to save or preview `newDoc`
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
