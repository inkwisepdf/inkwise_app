import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'dart:io';

class OcrTool {
  static Future<String> extractTextFromImage(File imageFile) async {
    final recognizer = TextRecognizer();
    final input = InputImage.fromFilePath(imageFile.path);
    final result = await recognizer.processImage(input);
    await recognizer.close();
    return result.text;
  }
}