import 'package:flutter/material.dart';

class PDFMergeScreen extends StatelessWidget {
  const PDFMergeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("PDF Merger")),
      body: const Center(child: Text("Merge multiple PDFs")),
    );
  }
}