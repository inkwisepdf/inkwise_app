import 'package:flutter/material.dart';
import 'package:pdf_render/pdf_render_widgets.dart';

class PDFPageViewer extends StatelessWidget {
  final String pdfPath;

  const PDFPageViewer({Key? key, required this.pdfPath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PdfViewer.openFile(
      pdfPath,
      params: const PdfViewerParams(
        padding: 10,
        minScale: 1.0,
        maxScale: 3.0,
        scrollDirection: Axis.vertical,
      ),
    );
  }
}
