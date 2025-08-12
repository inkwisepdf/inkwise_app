import 'dart:typed_data';
import 'package:flutter_tesseract_ocr/flutter_tesseract_ocr.dart';

class FindReplaceService {
  /// Extracts text from an image and finds matches
  static Future<String> extractTextFromImage(String imagePath) async {
    try {
      String extractedText = await FlutterTesseractOcr.extractText(
        imagePath,
        language: 'eng',
      );
      return extractedText;
    } catch (e) {
      return '';
    }
  }

  /// Finds and optionally replaces matched text in the extracted content
  static String findAndReplace(String inputText, String searchText, String replaceText) {
    return inputText.replaceAll(searchText, replaceText);
  }
}
