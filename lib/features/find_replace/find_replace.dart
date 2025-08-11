import 'package:flutter/material.dart';
import 'package:pdf_render/pdf_render.dart';

class FindReplaceScreen extends StatefulWidget {
  const FindReplaceScreen({Key? key}) : super(key: key);

  @override
  State<FindReplaceScreen> createState() => _FindReplaceScreenState();
}

class _FindReplaceScreenState extends State<FindReplaceScreen> {
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

    final imageBytes = pageImage.bytes;

    // Example debug output
    debugPrint('Extracted ${imageBytes.length} bytes from page $pageNum');

    await pageImage.dispose(); // this is valid
    await page.dispose(); // this is also valid in latest pdf_render
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
