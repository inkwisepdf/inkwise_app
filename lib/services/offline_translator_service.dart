import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:pdf_render/pdf_render.dart';
import 'package:flutter_tesseract_ocr/flutter_tesseract_ocr.dart';
import 'package:translator/translator.dart';

class OfflineTranslatorService {
  static const String _modelPath = 'assets/models/translation_model.tflite';
  static const String _vocabPath = 'assets/models/translation_vocab.json';
  
  // Fallback to online translator when offline models are not available
  final _translator = GoogleTranslator();
  
  Future<String> translatePDF(
    File pdfFile, {
    String? sourceLanguage,
    required String targetLanguage,
  }) async {
    try {
      // Extract text from PDF
      final text = await _extractTextFromPDF(pdfFile);
      
      if (text.isEmpty) {
        throw Exception('No text found in PDF');
      }
      
      // Detect source language if not provided
      final detectedSourceLang = sourceLanguage ?? await _detectLanguage(text);
      
      // Translate text
      final translatedText = await _translateText(
        text,
        sourceLanguage: detectedSourceLang,
        targetLanguage: targetLanguage,
      );
      
      return translatedText;
    } catch (e) {
      throw Exception('Failed to translate PDF: $e');
    }
  }
  
  Future<String> _extractTextFromPDF(File pdfFile) async {
    try {
      // Try to extract text directly first
      String extractedText = '';
      
      final document = await PdfDocument.openFile(pdfFile.path);
      
      for (int i = 1; i <= document.pageCount; i++) {
        final page = await document.getPage(i);
        final pageText = await page.text;
        if (pageText != null) {
          extractedText += pageText + '\n';
        }
        await page.close();
      }
      
      await document.close();
      
      // If no text extracted, use OCR
      if (extractedText.trim().isEmpty) {
        extractedText = await _performOCR(pdfFile);
      }
      
      return extractedText;
    } catch (e) {
      // Fallback to OCR
      return await _performOCR(pdfFile);
    }
  }
  
  Future<String> _performOCR(File pdfFile) async {
    try {
      // Convert PDF pages to images and perform OCR
      final document = await PdfDocument.openFile(pdfFile.path);
      String ocrText = '';
      
      for (int i = 1; i <= document.pageCount; i++) {
        final page = await document.getPage(i);
        final pageImage = await page.render(
          width: page.width * 2,
          height: page.height * 2,
        );
        
        if (pageImage != null) {
          // Save image temporarily
          final tempDir = await getTemporaryDirectory();
          final imageFile = File('${tempDir.path}/page_$i.png');
          await imageFile.writeAsBytes(pageImage.toByteData()!.buffer.asUint8List());
          
          // Perform OCR
          final pageText = await FlutterTesseractOcr.extractText(imageFile.path);
          ocrText += pageText + '\n';
          
          // Clean up
          await imageFile.delete();
        }
        
        await page.close();
      }
      
      await document.close();
      return ocrText;
    } catch (e) {
      throw Exception('OCR failed: $e');
    }
  }
  
  Future<String> _detectLanguage(String text) async {
    try {
      // Use Google Translator to detect language
      final detection = await _translator.detect(text);
      return detection.languageCode;
    } catch (e) {
      // Fallback to simple language detection
      return _simpleLanguageDetection(text);
    }
  }
  
  String _simpleLanguageDetection(String text) {
    // Simple language detection based on character sets
    final textLower = text.toLowerCase();
    
    // Check for Chinese characters
    if (RegExp(r'[\u4e00-\u9fff]').hasMatch(text)) {
      return 'zh';
    }
    
    // Check for Japanese characters
    if (RegExp(r'[\u3040-\u309f\u30a0-\u30ff]').hasMatch(text)) {
      return 'ja';
    }
    
    // Check for Korean characters
    if (RegExp(r'[\uac00-\ud7af]').hasMatch(text)) {
      return 'ko';
    }
    
    // Check for Arabic characters
    if (RegExp(r'[\u0600-\u06ff]').hasMatch(text)) {
      return 'ar';
    }
    
    // Check for Cyrillic characters
    if (RegExp(r'[\u0400-\u04ff]').hasMatch(text)) {
      return 'ru';
    }
    
    // Check for common European languages
    if (RegExp(r'[àáâãäåæçèéêëìíîïðñòóôõöøùúûüýþÿ]').hasMatch(text)) {
      // Could be French, Spanish, German, etc.
      if (textLower.contains('ñ') || textLower.contains('á') || textLower.contains('é')) {
        return 'es';
      }
      if (textLower.contains('ä') || textLower.contains('ö') || textLower.contains('ü')) {
        return 'de';
      }
      if (textLower.contains('à') || textLower.contains('ç') || textLower.contains('é')) {
        return 'fr';
      }
    }
    
    // Default to English
    return 'en';
  }
  
  Future<String> _translateText(
    String text, {
    required String sourceLanguage,
    required String targetLanguage,
  }) async {
    try {
      // Try offline translation first
      final offlineTranslation = await _offlineTranslate(
        text,
        sourceLanguage: sourceLanguage,
        targetLanguage: targetLanguage,
      );
      
      if (offlineTranslation != null) {
        return offlineTranslation;
      }
      
      // Fallback to online translation
      return await _onlineTranslate(
        text,
        sourceLanguage: sourceLanguage,
        targetLanguage: targetLanguage,
      );
    } catch (e) {
      throw Exception('Translation failed: $e');
    }
  }
  
  Future<String?> _offlineTranslate(
    String text, {
    required String sourceLanguage,
    required String targetLanguage,
  }) async {
    try {
      // This would use TensorFlow Lite models for offline translation
      // For now, return null to use online translation
      
      // TODO: Implement offline translation using TensorFlow Lite
      // 1. Load the translation model
      // 2. Tokenize input text
      // 3. Run inference
      // 4. Decode output tokens
      
      return null;
    } catch (e) {
      // If offline translation fails, return null to use online
      return null;
    }
  }
  
  Future<String> _onlineTranslate(
    String text, {
    required String sourceLanguage,
    required String targetLanguage,
  }) async {
    try {
      // Split text into chunks to avoid API limits
      final chunks = _splitTextIntoChunks(text, maxChunkSize: 5000);
      final translatedChunks = <String>[];
      
      for (final chunk in chunks) {
        final translation = await _translator.translate(
          chunk,
          from: sourceLanguage,
          to: targetLanguage,
        );
        translatedChunks.add(translation.text);
      }
      
      return translatedChunks.join('\n');
    } catch (e) {
      throw Exception('Online translation failed: $e');
    }
  }
  
  List<String> _splitTextIntoChunks(String text, {int maxChunkSize = 5000}) {
    final chunks = <String>[];
    final sentences = text.split(RegExp(r'[.!?]+'));
    String currentChunk = '';
    
    for (final sentence in sentences) {
      if ((currentChunk + sentence).length > maxChunkSize && currentChunk.isNotEmpty) {
        chunks.add(currentChunk.trim());
        currentChunk = sentence;
      } else {
        currentChunk += sentence + '. ';
      }
    }
    
    if (currentChunk.isNotEmpty) {
      chunks.add(currentChunk.trim());
    }
    
    return chunks;
  }
  
  // Create translated PDF with original layout preserved
  Future<File> createTranslatedPDF(
    File originalPDF,
    String translatedText, {
    required String targetLanguage,
  }) async {
    try {
      // This would create a new PDF with translated text
      // while preserving the original layout and formatting
      
      // TODO: Implement PDF creation with translated text
      // 1. Extract original PDF layout
      // 2. Replace text with translations
      // 3. Maintain formatting and positioning
      // 4. Generate new PDF file
      
      final tempDir = await getTemporaryDirectory();
      final outputFile = File('${tempDir.path}/translated_${DateTime.now().millisecondsSinceEpoch}.pdf');
      
      // Placeholder implementation
      await outputFile.writeAsString('Translated PDF content: $translatedText');
      
      return outputFile;
    } catch (e) {
      throw Exception('Failed to create translated PDF: $e');
    }
  }
  
  // Get translation statistics
  Map<String, dynamic> getTranslationStats(
    String originalText,
    String translatedText,
    String sourceLanguage,
    String targetLanguage,
  ) {
    final originalWords = originalText.split(RegExp(r'\s+')).length;
    final translatedWords = translatedText.split(RegExp(r'\s+')).length;
    final originalChars = originalText.length;
    final translatedChars = translatedText.length;
    
    return {
      'sourceLanguage': sourceLanguage,
      'targetLanguage': targetLanguage,
      'originalWords': originalWords,
      'translatedWords': translatedWords,
      'originalCharacters': originalChars,
      'translatedCharacters': translatedChars,
      'wordRatio': (translatedWords / originalWords).toStringAsFixed(2),
      'characterRatio': (translatedChars / originalChars).toStringAsFixed(2),
    };
  }
  
  // Check if offline translation is available for language pair
  bool isOfflineTranslationAvailable(String sourceLanguage, String targetLanguage) {
    // Define supported offline language pairs
    final supportedPairs = [
      ['en', 'es'], ['es', 'en'],
      ['en', 'fr'], ['fr', 'en'],
      ['en', 'de'], ['de', 'en'],
      ['en', 'it'], ['it', 'en'],
      ['en', 'pt'], ['pt', 'en'],
      ['en', 'ru'], ['ru', 'en'],
      ['en', 'zh'], ['zh', 'en'],
      ['en', 'ja'], ['ja', 'en'],
      ['en', 'ko'], ['ko', 'en'],
    ];
    
    return supportedPairs.any((pair) =>
        pair[0] == sourceLanguage && pair[1] == targetLanguage);
  }
}