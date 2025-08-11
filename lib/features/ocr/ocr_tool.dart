import 'package:flutter_tesseract_ocr/flutter_tesseract_ocr.dart';
import 'dart:io';

class OcrTool {
  static Future<String> extractTextFromImage(File imageFile) async {
    return await FlutterTesseractOcr.extractText(imageFile.path);
  }
}
