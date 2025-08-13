import 'package:flutter/material.dart';
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
    try {
      document = await PdfDocument.openAsset('assets/sample.pdf');
    } catch (e) {
      debugPrint('Error loading PDF: $e');
    }
    setState(() => isLoading = false);
  }

  Future<void> findTextOnPage(int pageNum) async {
    if (document == null) return;

    try {
      final page = await document!.getPage(pageNum);
      final pageImage = await page.render();

      // Get the actual image bytes from PdfPageImage
      final bytes = pageImage.pixels;

      // Example debug output
      debugPrint('Extracted ${bytes.length} bytes from page $pageNum');
      debugPrint('Image dimensions: ${pageImage.width}x${pageImage.height}');

      // Note: PdfPage doesn't need manual disposal in pdf_render package
    } catch (e) {
      debugPrint('Error processing page $pageNum: $e');
    }
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