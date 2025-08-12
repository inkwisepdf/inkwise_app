import 'package:flutter/material.dart';
import '../features/find_replace/find_replace.dart';
import '../services/find_replace_service.dart';

class FindReplaceScreen extends StatefulWidget {
  const FindReplaceScreen({Key? key}) : super(key: key);

  @override
  _FindReplaceScreenState createState() => _FindReplaceScreenState();
}

class _FindReplaceScreenState extends State<FindReplaceScreen> {
  final TextEditingController _pathController = TextEditingController();
  final TextEditingController _findController = TextEditingController();
  final TextEditingController _replaceController = TextEditingController();
  String _output = '';

  void _runFindReplace() async {
    final result = await FindReplaceService.replaceTextInPdf(
      _pathController.text,
      _findController.text,
      _replaceController.text,
    );

    setState(() {
      _output = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Find & Replace")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _pathController, decoration: const InputDecoration(labelText: 'PDF Path')),
            TextField(controller: _findController, decoration: const InputDecoration(labelText: 'Find Text')),
            TextField(controller: _replaceController, decoration: const InputDecoration(labelText: 'Replace With')),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _runFindReplace, child: const Text("Run")),
            const SizedBox(height: 20),
            Expanded(child: SingleChildScrollView(child: Text(_output))),
          ],
        ),
      ),
    );
  }
}
