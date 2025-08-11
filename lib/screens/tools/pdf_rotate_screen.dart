import 'package:flutter/material.dart';

class PDFRotateScreen extends StatelessWidget {
  const PDFRotateScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("PDF Rotate")),
      body: const Center(child: Text("Rotate PDF Pages")),
    );
  }
}