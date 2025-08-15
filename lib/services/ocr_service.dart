import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf_render/pdf_render.dart';
import 'package:flutter_tesseract_ocr/flutter_tesseract_ocr.dart';
import 'package:image/image.dart' as img;
import 'dart:ui' as ui;

class OCRService {
  static final OCRService _instance = OCRService._internal();
  factory OCRService() => _instance;
  OCRService._internal();

  /// Extract text from scanned PDF using OCR
  Future<String> extractTextFromScannedPDF(File pdfFile,
      {String language = 'eng'}) async {
    try {
      final PdfDocument document = await PdfDocument.openFile(pdfFile.path);
      String extractedText = '';

      for (int i = 1; i <= document.pageCount; i++) {
        final page = await document.getPage(i);
        final pageImage = await page.render(
          width: (page.width * 2).toInt(),
          height: (page.height * 2).toInt(),
        );

        // Save image temporarily
        final tempDir = await getTemporaryDirectory();
        final imageFile = File('${tempDir.path}/page_$i.png');
        final image = await pageImage
            .createImageIfNotAvailable(); // Use createImageIfNotAvailable
        final imageBytes =
            await image.toByteData(format: ui.ImageByteFormat.png);
        await imageFile.writeAsBytes(imageBytes!.buffer.asUint8List());

        // Perform OCR
        final pageText = await FlutterTesseractOcr.extractText(imageFile.path,
            language: language);
        extractedText += '$pageText\n';

        // Clean up
        await imageFile.delete();
      }

      await document.dispose(); // Use dispose for cleanup
      return extractedText.trim();
    } catch (e) {
      throw Exception('OCR extraction failed: $e');
    }
  }

  /// Extract text from specific page
  Future<String> extractTextFromPage(File pdfFile, int pageNumber,
      {String language = 'eng'}) async {
    try {
      final PdfDocument document = await PdfDocument.openFile(pdfFile.path);

      if (pageNumber < 1 || pageNumber > document.pageCount) {
        await document.dispose();
        throw Exception('Invalid page number');
      }

      final page = await document.getPage(pageNumber);
      final pageImage = await page.render(
        width: (page.width * 2).toInt(),
        height: (page.height * 2).toInt(),
      );

      String extractedText = '';
      // Save image temporarily
      final tempDir = await getTemporaryDirectory();
      final imageFile = File('${tempDir.path}/page_$pageNumber.png');
      final image = await pageImage
          .createImageIfNotAvailable(); // Use createImageIfNotAvailable
      final imageBytes = await image.toByteData(format: ui.ImageByteFormat.png);
      await imageFile.writeAsBytes(imageBytes!.buffer.asUint8List());

      // Perform OCR
      extractedText = await FlutterTesseractOcr.extractText(imageFile.path,
          language: language);

      // Clean up
      await imageFile.delete();

      await document.dispose(); // Use dispose for cleanup
      return extractedText.trim();
    } catch (e) {
      throw Exception('OCR extraction failed: $e');
    }
  }

  /// Extract text from image file
  Future<String> extractTextFromImage(File imageFile,
      {String language = 'eng'}) async {
    try {
      final extractedText = await FlutterTesseractOcr.extractText(
          imageFile.path,
          language: language);
      return extractedText.trim();
    } catch (e) {
      throw Exception('OCR extraction failed: $e');
    }
  }

  /// Extract text from image bytes
  Future<String> extractTextFromImageBytes(Uint8List imageBytes,
      {String language = 'eng'}) async {
    try {
      // Save bytes to temporary file
      final tempDir = await getTemporaryDirectory();
      final tempFile = File(
          '${tempDir.path}/temp_image_${DateTime.now().millisecondsSinceEpoch}.png');
      await tempFile.writeAsBytes(imageBytes);

      // Perform OCR
      final extractedText = await FlutterTesseractOcr.extractText(tempFile.path,
          language: language);

      // Clean up
      await tempFile.delete();

      return extractedText.trim();
    } catch (e) {
      throw Exception('OCR extraction failed: $e');
    }
  }

  /// Get available OCR languages
  List<String> getAvailableLanguages() {
    return [
      'eng', // English
      'spa', // Spanish
      'fra', // French
      'deu', // German
      'ita', // Italian
      'por', // Portuguese
      'rus', // Russian
      'chi_sim', // Chinese Simplified
      'chi_tra', // Chinese Traditional
      'jpn', // Japanese
      'kor', // Korean
      'ara', // Arabic
      'hin', // Hindi
      'nld', // Dutch
      'swe', // Swedish
      'nor', // Norwegian
      'dan', // Danish
      'fin', // Finnish
      'pol', // Polish
      'tur', // Turkish
    ];
  }

  /// Detect language from text
  Future<String> detectLanguage(String text) async {
    // Simple language detection based on character sets
    if (RegExp(r'[\u4e00-\u9fff]').hasMatch(text)) {
      return 'chi_sim'; // Chinese
    }
    if (RegExp(r'[\u3040-\u309f\u30a0-\u30ff]').hasMatch(text)) {
      return 'jpn'; // Japanese
    }
    if (RegExp(r'[\uac00-\ud7af]').hasMatch(text)) {
      return 'kor'; // Korean
    }
    if (RegExp(r'[\u0600-\u06ff]').hasMatch(text)) {
      return 'ara'; // Arabic
    }
    if (RegExp(r'[\u0400-\u04ff]').hasMatch(text)) {
      return 'rus'; // Russian
    }

    // Check for European languages
    final textLower = text.toLowerCase();
    if (textLower.contains('ñ') ||
        textLower.contains('á') ||
        textLower.contains('é')) {
      return 'spa'; // Spanish
    }
    if (textLower.contains('ä') ||
        textLower.contains('ö') ||
        textLower.contains('ü')) {
      return 'deu'; // German
    }
    if (textLower.contains('à') ||
        textLower.contains('ç') ||
        textLower.contains('é')) {
      return 'fra'; // French
    }

    return 'eng'; // Default to English
  }

  /// Preprocess image for better OCR results
  Future<Uint8List> preprocessImage(Uint8List imageBytes) async {
    try {
      final img.Image? image = img.decodeImage(imageBytes);
      if (image == null) return imageBytes;

      // Convert to grayscale
      img.Image processedImage = img.grayscale(image);

      // Increase contrast
      processedImage = img.contrast(processedImage, contrast: 150);

      // Apply noise reduction
      processedImage = img.gaussianBlur(processedImage, radius: 1);

      // Sharpen the image using convolution
      processedImage = img.convolution(
        processedImage,
        filter: [0, -1, 0, -1, 5, -1, 0, -1, 0], // Sharpening kernel
        div: 1,
        offset: 0,
      );

      // Resize if too small
      if (processedImage.width < 300 || processedImage.height < 300) {
        processedImage = img.copyResize(processedImage,
            width: 600, height: 600, interpolation: img.Interpolation.linear);
      }

      return Uint8List.fromList(img.encodePng(processedImage));
    } catch (e) {
      return imageBytes;
    }
  }

  /// Extract text with confidence scores
  Future<List<OCRResult>> extractTextWithConfidence(File imageFile,
      {String language = 'eng'}) async {
    try {
      // This would require a more advanced OCR implementation
      // For now, return basic result
      final text = await extractTextFromImage(imageFile, language: language);
      return [
        OCRResult(
          text: text,
          confidence: 0.8,
        ),
      ];
    } catch (e) {
      throw Exception('OCR extraction failed: $e');
    }
  }

  /// Batch OCR processing
  Future<List<String>> batchOCR(List<File> imageFiles,
      {String language = 'eng'}) async {
    final List<String> results = [];

    for (final imageFile in imageFiles) {
      try {
        final text = await extractTextFromImage(imageFile, language: language);
        results.add(text);
      } catch (e) {
        results.add(''); // Empty string for failed OCR
      }
    }

    return results;
  }

  /// Check if OCR is available
  Future<bool> isOCRAvailable() async {
    try {
      // Try to perform a simple OCR test
      final tempDir = await getTemporaryDirectory();
      final testFile = File('${tempDir.path}/test.png');

      // Create a simple test image
      final testImage = img.Image(width: 100, height: 50);
      img.fill(testImage, color: img.ColorRgb8(255, 255, 255));
      img.drawString(testImage, 'Test', font: img.arial24, x: 10, y: 10);

      await testFile.writeAsBytes(img.encodePng(testImage));

      final result = await FlutterTesseractOcr.extractText(testFile.path);
      await testFile.delete();

      return result.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}

/// OCR result with confidence and bounding box information
class OCRResult {
  final String text;
  final double confidence;
  final Map<String, double>? boundingBox;

  OCRResult({
    required this.text,
    required this.confidence,
    this.boundingBox,
  });
}
