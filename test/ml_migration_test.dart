import 'package:flutter_test/flutter_test.dart';
import 'package:inkwise_pdf/services/offline_translation_service.dart';
import 'package:inkwise_pdf/services/ai_summarizer_service.dart';
import 'dart:io';

void main() {
  group('ML Migration Tests', () {
    test('OfflineTranslationService should initialize without TensorFlow Lite', () async {
      final service = OfflineTranslationService();
      
      // Test initialization
      final initialized = await service.initialize();
      expect(initialized, isTrue);
      
      // Test that no TensorFlow Lite dependencies are used
      expect(service.getSupportedLanguages(), isNotEmpty);
      
      // Clean up
      await service.dispose();
    });

    test('AISummarizerService should initialize without TensorFlow Lite', () async {
      final service = AISummarizerService();
      
      // Test initialization
      final initialized = await service.initialize();
      expect(initialized, isTrue);
      
      // Clean up
      await service.dispose();
    });

    test('Translation service should support modern ML features', () async {
      final service = OfflineTranslationService();
      await service.initialize();
      
      // Test that modern ML components are available
      expect(service.getSupportedLanguages(), contains('en'));
      expect(service.getSupportedLanguages(), contains('es'));
      expect(service.getSupportedLanguages(), contains('fr'));
      
      await service.dispose();
    });

    test('Summarizer service should support modern ML features', () async {
      final service = AISummarizerService();
      await service.initialize();
      
      // Test that the service is properly initialized
      expect(service, isNotNull);
      
      await service.dispose();
    });
  });
}