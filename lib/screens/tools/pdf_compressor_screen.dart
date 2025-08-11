import 'package:flutter/material.dart';

class PDFCompressorScreen extends StatelessWidget {
  const PDFCompressorScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("PDF Compressor")),
      body: const Center(child: Text("PDF Compressor Tool")),
    );
  }
}
