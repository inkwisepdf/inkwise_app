import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf_render/pdf_render.dart';
import 'package:flutter_tesseract_ocr/flutter_tesseract_ocr.dart';

class AISummarizerService {
  static const String _modelPath = 'assets/models/summarizer_model.tflite';
  static const String _vocabPath = 'assets/models/vocab.txt';
  
  // Simple keyword-based summarization for offline use
  // In a real implementation, this would use TensorFlow Lite models
  Future<String> summarizePDF(
    File pdfFile, {
    String language = 'English',
    int length = 3,
  }) async {
    try {
      // Extract text from PDF
      final text = await _extractTextFromPDF(pdfFile);
      
      if (text.isEmpty) {
        throw Exception('No text found in PDF');
      }
      
      // Generate summary using offline AI model
      final summary = await _generateSummary(text, language, length);
      
      return summary;
    } catch (e) {
      throw Exception('Failed to summarize PDF: $e');
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
  
  Future<String> _generateSummary(String text, String language, int length) async {
    // This is a simplified offline summarization algorithm
    // In a real implementation, this would use TensorFlow Lite models
    
    // Clean and preprocess text
    final cleanText = _preprocessText(text);
    
    // Split into sentences
    final sentences = _splitIntoSentences(cleanText);
    
    // Calculate sentence importance scores
    final sentenceScores = _calculateSentenceScores(sentences);
    
    // Select top sentences based on length
    final selectedSentences = _selectTopSentences(sentences, sentenceScores, length);
    
    // Generate summary
    final summary = selectedSentences.join(' ');
    
    // Apply language-specific formatting
    return _formatSummary(summary, language);
  }
  
  String _preprocessText(String text) {
    // Remove extra whitespace and normalize
    return text
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll(RegExp(r'[^\w\s\.\,\!\?\-]'), '')
        .trim();
  }
  
  List<String> _splitIntoSentences(String text) {
    // Simple sentence splitting
    return text
        .split(RegExp(r'[.!?]+'))
        .where((sentence) => sentence.trim().isNotEmpty)
        .map((sentence) => sentence.trim())
        .toList();
  }
  
  Map<String, double> _calculateSentenceScores(List<String> sentences) {
    final scores = <String, double>{};
    
    // Calculate word frequency
    final wordFreq = <String, int>{};
    for (final sentence in sentences) {
      final words = sentence.toLowerCase().split(RegExp(r'\s+'));
      for (final word in words) {
        if (word.length > 3) { // Ignore short words
          wordFreq[word] = (wordFreq[word] ?? 0) + 1;
        }
      }
    }
    
    // Calculate sentence scores based on word frequency
    for (final sentence in sentences) {
      double score = 0;
      final words = sentence.toLowerCase().split(RegExp(r'\s+'));
      
      for (final word in words) {
        if (word.length > 3) {
          score += wordFreq[word] ?? 0;
        }
      }
      
      // Normalize by sentence length
      score = score / words.length;
      scores[sentence] = score;
    }
    
    return scores;
  }
  
  List<String> _selectTopSentences(
    List<String> sentences,
    Map<String, double> scores,
    int targetLength,
  ) {
    // Sort sentences by score
    final sortedSentences = sentences.toList()
      ..sort((a, b) => (scores[b] ?? 0).compareTo(scores[a] ?? 0));
    
    // Select top sentences
    final selected = <String>[];
    int currentLength = 0;
    
    for (final sentence in sortedSentences) {
      if (currentLength >= targetLength) break;
      
      selected.add(sentence);
      currentLength++;
    }
    
    // Sort back to original order
    selected.sort((a, b) => sentences.indexOf(a).compareTo(sentences.indexOf(b)));
    
    return selected;
  }
  
  String _formatSummary(String summary, String language) {
    // Apply language-specific formatting
    switch (language.toLowerCase()) {
      case 'english':
        return summary;
      case 'spanish':
        return summary; // Could apply Spanish-specific formatting
      case 'french':
        return summary; // Could apply French-specific formatting
      default:
        return summary;
    }
  }
  
  // Advanced summarization using extractive and abstractive methods
  Future<String> _advancedSummarization(String text) async {
    // This would implement more sophisticated summarization techniques
    // such as:
    // 1. TextRank algorithm
    // 2. BERT-based sentence embeddings
    // 3. Abstractive summarization using transformer models
    
    // For now, return a simple extractive summary
    return _generateSummary(text, 'English', 3);
  }
  
  // Get summary statistics
  Map<String, dynamic> getSummaryStats(String originalText, String summary) {
    final originalWords = originalText.split(RegExp(r'\s+')).length;
    final summaryWords = summary.split(RegExp(r'\s+')).length;
    final compressionRatio = (1 - (summaryWords / originalWords)) * 100;
    
    return {
      'originalWords': originalWords,
      'summaryWords': summaryWords,
      'compressionRatio': compressionRatio.toStringAsFixed(1),
      'keyTopics': _extractKeyTopics(originalText),
    };
  }
  
  List<String> _extractKeyTopics(String text) {
    // Extract key topics using TF-IDF or similar algorithm
    final words = text.toLowerCase().split(RegExp(r'\s+'));
    final wordFreq = <String, int>{};
    
    for (final word in words) {
      if (word.length > 4 && !_isStopWord(word)) {
        wordFreq[word] = (wordFreq[word] ?? 0) + 1;
      }
    }
    
    // Sort by frequency and return top 5
    final sortedWords = wordFreq.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return sortedWords.take(5).map((e) => e.key).toList();
  }
  
  bool _isStopWord(String word) {
    const stopWords = {
      'the', 'a', 'an', 'and', 'or', 'but', 'in', 'on', 'at', 'to', 'for',
      'of', 'with', 'by', 'is', 'are', 'was', 'were', 'be', 'been', 'being',
      'have', 'has', 'had', 'do', 'does', 'did', 'will', 'would', 'could',
      'should', 'may', 'might', 'must', 'can', 'this', 'that', 'these', 'those'
    };
    
    return stopWords.contains(word.toLowerCase());
  }
}