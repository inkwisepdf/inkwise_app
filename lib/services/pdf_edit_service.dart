import 'dart:io';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf_render/pdf_render.dart' as pdf_render;
import 'package:pdf/pdf.dart' as pdf_lib;
import 'package:pdf/widgets.dart' as pw;
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

/// Class to represent a text edit operation
class TextEdit {
  final Rect area;           // Area to cover with white rectangle
  final String newText;      // New text to add
  final Offset position;     // Position for new text
  final double fontSize;     // Font size for new text
  final Color textColor;     // Text color
  final String fontFamily;   // Font family

  TextEdit({
    required this.area,
    required this.newText,
    required this.position,
    this.fontSize = 12.0,
    this.textColor = const Color(0xFF000000),
    this.fontFamily = 'Arial',
  });
}

class PDFEditService {
  static final PDFEditService _instance = PDFEditService._internal();
  factory PDFEditService() => _instance;
  PDFEditService._internal();

  /// Edit text in a PDF page and return the modified PDF
  Future<File> editPdfText({
    required File sourceFile,
    required int pageNumber,
    required List<TextEdit> edits,
    String? outputFileName,
  }) async {
    try {
      // 1. Load the original PDF
      final document = await pdf_render.PdfDocument.openFile(sourceFile.path);

      if (pageNumber > document.pageCount || pageNumber < 1) {
        throw Exception('Page $pageNumber does not exist. PDF has ${document.pageCount} pages.');
      }

      // 2. Create new PDF document
      final pdf = pw.Document();

      // 3. Process each page
      for (int i = 1; i <= document.pageCount; i++) {
        if (i == pageNumber) {
          // Edit this page
          final editedPageImage = await _editPage(document, pageNumber, edits);
          pdf.addPage(_createPdfPageFromImage(editedPageImage));
        } else {
          // Keep original page as image
          final originalPageImage = await _renderPageToImage(document, i);
          pdf.addPage(_createPdfPageFromImage(originalPageImage));
        }
      }

      // 4. Save the new PDF
      final outputFile = await _savePdfToFile(pdf, outputFileName);

      // 5. Clean up
      document.dispose();

      return outputFile;
    } catch (e) {
      throw Exception('Failed to edit PDF text: $e');
    }
  }

  /// Edit multiple pages in a PDF
  Future<File> editMultiplePages({
    required File sourceFile,
    required Map<int, List<TextEdit>> pageEdits,
    String? outputFileName,
  }) async {
    try {
      final document = await pdf_render.PdfDocument.openFile(sourceFile.path);
      final pdf = pw.Document();

      for (int i = 1; i <= document.pageCount; i++) {
        if (pageEdits.containsKey(i)) {
          // Edit this page
          final editedPageImage = await _editPage(document, i, pageEdits[i]!);
          pdf.addPage(_createPdfPageFromImage(editedPageImage));
        } else {
          // Keep original page
          final originalPageImage = await _renderPageToImage(document, i);
          pdf.addPage(_createPdfPageFromImage(originalPageImage));
        }
      }

      final outputFile = await _savePdfToFile(pdf, outputFileName);
      document.dispose();

      return outputFile;
    } catch (e) {
      throw Exception('Failed to edit multiple pages: $e');
    }
  }

  /// Render a PDF page to image and apply text edits
  Future<Uint8List> _editPage(
    pdf_render.PdfDocument document,
    int pageNumber,
    List<TextEdit> edits
  ) async {
    // 1. Render original page to high-resolution image
    final page = await document.getPage(pageNumber);
    final pageImage = await page.render(
      width: (page.width * 3.0).round(),  // High resolution for quality
      height: (page.height * 3.0).round(),
    );

    // 2. Convert to Flutter Image
    final imageBytes = await pageImage.createImageIfNotAvailable();
    final byteData = await imageBytes.toByteData(format: ui.ImageByteFormat.png);
    final pngBytes = byteData!.buffer.asUint8List();

    // 3. Decode with image package for editing
    final originalImage = img.decodeImage(pngBytes);
    if (originalImage == null) {
      throw Exception('Failed to decode page image');
    }

    // 4. Apply edits to image
    final editedImage = _applyEditsToImage(originalImage, edits);

    // 5. Encode back to bytes
    return Uint8List.fromList(img.encodePng(editedImage));
  }

  /// Render PDF page to image without edits
  Future<Uint8List> _renderPageToImage(
    pdf_render.PdfDocument document,
    int pageNumber
  ) async {
    final page = await document.getPage(pageNumber);
    final pageImage = await page.render(
      width: (page.width * 2.0).round(),
      height: (page.height * 2.0).round(),
    );

    final imageBytes = await pageImage.createImageIfNotAvailable();
    final byteData = await imageBytes.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  /// Apply text edits to image
  img.Image _applyEditsToImage(img.Image originalImage, List<TextEdit> edits) {
    img.Image editedImage = img.Image.from(originalImage);

    for (final edit in edits) {
      // 1. Draw white rectangle over old text
      editedImage = img.fillRect(
        editedImage,
        x1: edit.area.left.round(),
        y1: edit.area.top.round(),
        x2: edit.area.right.round(),
        y2: edit.area.bottom.round(),
        color: img.ColorRgb8(255, 255, 255), // White background
      );

      // 2. Draw new text (simplified - in production you'd use a proper text rendering library)
      editedImage = _drawTextOnImage(
        editedImage,
        edit.newText,
        edit.position.dx.round(),
        edit.position.dy.round(),
        edit.fontSize.round(),
        edit.textColor,
      );
    }

    return editedImage;
  }

  /// Draw text on image (simplified implementation)
  img.Image _drawTextOnImage(
    img.Image image,
    String text,
    int x,
    int y,
    int fontSize,
    Color textColor,
  ) {
    // Note: This is a simplified text drawing implementation
    // For production use, consider using a proper text rendering library
    // or drawing text character by character using a bitmap font

    final color = img.ColorRgb8(
      (textColor.red * 255.0).round() & 0xff,
      (textColor.green * 255.0).round() & 0xff,
        (textColor.blue * 255.0).round() & 0xff,
    );

    // Simple text drawing - draws a rectangle to represent text
    // In production, you would implement proper text rendering
    final textWidth = text.length * (fontSize * 0.6).round();
    final textHeight = fontSize.round();

    // Draw text background (optional)
    image = img.fillRect(
      image,
      x1: x,
      y1: y,
      x2: x + textWidth,
      y2: y + textHeight,
      color: img.ColorRgb8(240, 240, 240),
    );

    // Draw text placeholder (in production, render actual text)
    // For now, we'll draw a simple representation
    for (int i = 0; i < text.length; i++) {
      final charX = x + (i * (fontSize * 0.6).round());
      final charY = y;

      // Draw a simple line to represent character
      if (charX < image.width && charY < image.height) {
        image = img.drawLine(
          image,
          x1: charX,
          y1: charY,
          x2: charX,
          y2: charY + fontSize,
          color: color,
          thickness: 2,
        );
      }
    }

    return image;
  }

  /// Create PDF page from image
  pw.Page _createPdfPageFromImage(Uint8List imageBytes) {
    return pw.Page(
      pageFormat: pdf_lib.PdfPageFormat.a4,
      build: (pw.Context context) {
        return pw.Center(
          child: pw.Image(
            pw.MemoryImage(imageBytes),
          ),
        );
      },
    );
  }

  /// Save PDF document to file
  Future<File> _savePdfToFile(pw.Document pdf, String? fileName) async {
    final bytes = await pdf.save();

    final directory = await getApplicationDocumentsDirectory();
    final appDir = Directory('${directory.path}/inkwise_pdf/edited');
    if (!await appDir.exists()) {
      await appDir.create(recursive: true);
    }

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final outputFileName = fileName ?? 'edited_pdf_$timestamp.pdf';
    final outputPath = path.join(appDir.path, outputFileName);

    final file = File(outputPath);
    await file.writeAsBytes(bytes);

    return file;
  }

  /// Helper method to create a simple text edit
  TextEdit createSimpleEdit({
    required double left,
    required double top,
    required double width,
    required double height,
    required String newText,
    double fontSize = 12.0,
    Color textColor = const Color(0xFF000000),
  }) {
    return TextEdit(
      area: Rect.fromLTWH(left, top, width, height),
      newText: newText,
      position: Offset(left + 2, top + fontSize), // Slight offset for better positioning
      fontSize: fontSize,
      textColor: textColor,
    );
  }

  /// Get font size estimation based on area height
  double estimateFontSize(double areaHeight) {
    return (areaHeight * 0.7).clamp(8.0, 24.0);
  }

  /// Preview edit without saving
  Future<Uint8List> previewPageEdit({
    required File sourceFile,
    required int pageNumber,
    required List<TextEdit> edits,
  }) async {
    try {
      final document = await pdf_render.PdfDocument.openFile(sourceFile.path);
      final editedPageImage = await _editPage(document, pageNumber, edits);
      document.dispose();
      return editedPageImage;
    } catch (e) {
      throw Exception('Failed to preview edit: $e');
    }
  }

  /// Extract text areas for editing (simplified detection)
  Future<List<Rect>> detectTextAreas({
    required File sourceFile,
    required int pageNumber,
    double minWidth = 50.0,
    double minHeight = 10.0,
  }) async {
    // This is a simplified implementation
    // In production, you would use OCR or text extraction to detect actual text areas

    try {
      final document = await pdf_render.PdfDocument.openFile(sourceFile.path);
      final page = await document.getPage(pageNumber);

      // Get page dimensions for realistic text area detection
      final pageWidth = page.width;

      // Create sample text areas (placeholder)
      final areas = <Rect>[
        Rect.fromLTWH(50, 100, pageWidth * 0.4, 20),   // Header area
        Rect.fromLTWH(50, 150, pageWidth * 0.6, 15),   // Paragraph line 1
        Rect.fromLTWH(50, 170, pageWidth * 0.55, 15),  // Paragraph line 2
        Rect.fromLTWH(50, 190, pageWidth * 0.5, 15),   // Paragraph line 3
      ];

      document.dispose();
      return areas.where((area) =>
        area.width >= minWidth && area.height >= minHeight
      ).toList();
    } catch (e) {
      throw Exception('Failed to detect text areas: $e');
    }
  }
}

