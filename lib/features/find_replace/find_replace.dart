import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf_render/pdf_render.dart';

class FindReplaceFeature extends StatefulWidget {
  const FindReplaceFeature({super.key});

  @override
  State<FindReplaceFeature> createState() => _FindReplaceFeatureState();
}

class _FindReplaceFeatureState extends State<FindReplaceFeature> {
  PdfDocument? document;
  int currentPage = 1;
  String searchText = '';
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    loadPdf();
  }

  Future<void> loadPdf() async {
    setState(() => isLoading = true);
    document = await PdfDocument.openAsset('assets/sample.pdf');
    setState(() => isLoading = false);
  }

  Future<void> findTextOnPage(int pageNum) async {
    if (document == null) return;

    final page = await document!.getPage(pageNum);
    final pageImage = await page.render();

    // Convert the image to bytes for processing
    final imageBytes = await pageImage.toByteData(format: ImageByteFormat.png);
    final bytes = imageBytes?.buffer.asUint8List() ?? Uint8List(0);

    // Example debug output
    debugPrint('Extracted ${bytes.length} bytes from page $pageNum');

    // pageImage.dispose() is not needed in pdf_render
    // Note: PdfPage doesn't have dispose method in pdf_render
  }

  @override
  void dispose() {
    document?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Find & Replace')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Search Text',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => searchText = value,
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => findTextOnPage(currentPage),
                    child: const Text('Search on Page'),
                  ),
                ],
              ),
            ),
    );
  }
}

