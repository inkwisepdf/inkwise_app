import 'package:flutter/material.dart';

class PDFOCRScreen extends StatelessWidget {
  const PDFOCRScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("PDF OCR")),
      body: const Center(child: Text("OCR Text Extraction from PDF Images")),
    );
  }
}