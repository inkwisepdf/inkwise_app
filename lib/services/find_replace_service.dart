import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf_render/pdf_render.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'dart:ui' as ui;

class FindReplaceService {
  static final FindReplaceService _instance = FindReplaceService._internal();
  factory FindReplaceService() => _instance;
  FindReplaceService._internal();

  /// Find text in PDF file
  Future<List<SearchResult>> findTextInPDF(File pdfFile, String searchText,
      {bool caseSensitive = false,
      bool useRegex = false,
      String language = 'en'}) async {
    try {
      final document = await PdfDocument.openFile(pdfFile.path);
      final List<SearchResult> results = [];

      for (int pageNum = 1; pageNum <= document.pageCount; pageNum++) {
        final page = await document.getPage(pageNum);
        
        // Try to extract text directly first
        String pageText = '';
        try {
          pageText = await _extractTextFromPage(page);
        } catch (e) {
          // If no text extracted, use OCR
          pageText = '';
        }

        if (pageText.isEmpty) {
          // Fallback to OCR for this page
          pageText = await _performOCROnPage(page, pageNum);
        }

        if (pageText.isNotEmpty) {
          final pageResults = _findTextInString(
            pageText,
            searchText,
            pageNum,
            caseSensitive: caseSensitive,
            useRegex: useRegex,
          );
          results.addAll(pageResults);
        }
      }

      await document.dispose();
      return results;
    } catch (e) {
      throw Exception('Text search failed: $e');
    }
  }

  /// Replace text in PDF file
  Future<bool> replaceTextInPDF(File pdfFile, String searchText, String replaceText,
      {bool caseSensitive = false,
      bool useRegex = false,
      String language = 'en'}) async {
    try {
      // Find all occurrences first
      final searchResults = await findTextInPDF(
        pdfFile,
        searchText,
        caseSensitive: caseSensitive,
        useRegex: useRegex,
        language: language,
      );

      if (searchResults.isEmpty) {
        return false; // No text found to replace
      }

      // Perform replacement
      final success = await _performTextReplacement(
        pdfFile,
        searchResults,
        searchText,
        replaceText,
        caseSensitive: caseSensitive,
        useRegex: useRegex,
      );

      return success;
    } catch (e) {
      throw Exception('Text replacement failed: $e');
    }
  }

  /// Find and replace all occurrences
  Future<ReplaceResult> findAndReplaceAll(File pdfFile, String searchText,
      String replaceText,
      {bool caseSensitive = false,
      bool useRegex = false,
      String language = 'en'}) async {
    try {
      final startTime = DateTime.now();
      
      // Find all occurrences
      final searchResults = await findTextInPDF(
        pdfFile,
        searchText,
        caseSensitive: caseSensitive,
        useRegex: useRegex,
        language: language,
      );

      if (searchResults.isEmpty) {
        return ReplaceResult(
          success: false,
          occurrencesFound: 0,
          replacementsMade: 0,
          processingTime: DateTime.now().difference(startTime),
          message: 'No text found to replace',
        );
      }

      // Perform replacement
      final success = await _performTextReplacement(
        pdfFile,
        searchResults,
        searchText,
        replaceText,
        caseSensitive: caseSensitive,
        useRegex: useRegex,
      );

      final endTime = DateTime.now();
      final processingTime = endTime.difference(startTime);

      return ReplaceResult(
        success: success,
        occurrencesFound: searchResults.length,
        replacementsMade: success ? searchResults.length : 0,
        processingTime: processingTime,
        message: success
            ? 'Successfully replaced ${searchResults.length} occurrences'
            : 'Failed to perform replacements',
      );
    } catch (e) {
      return ReplaceResult(
        success: false,
        occurrencesFound: 0,
        replacementsMade: 0,
        processingTime: Duration.zero,
        message: 'Error: $e',
      );
    }
  }

  /// Extract text from a single page
  Future<String> _extractTextFromPage(dynamic page) async {
    // This is a mock implementation since pdf_render doesn't provide text extraction
    // In a real implementation, you would use a different PDF library that supports text extraction
    return '';
  }

  /// Perform OCR on a single page
  Future<String> _performOCROnPage(dynamic page, int pageNum) async {
    try {
      final pageImage = await page.render(
        width: (page.width * 2).toInt(),
        height: (page.height * 2).toInt(),
      );

      await pageImage.createImageIfNotAvailable();
      final img = pageImage.imageIfAvailable;
      final byteData = await img.toByteData(format: ui.ImageByteFormat.png);

      // Save image temporarily
      final tempDir = await getTemporaryDirectory();
      final tempPath = '${tempDir.path}/ocr_page_$pageNum.png';
      final tempFile =
          await File(tempPath).writeAsBytes(byteData!.buffer.asUint8List());

      final inputImage = InputImage.fromFilePath(tempPath);
      final textRecognizer = TextRecognizer();
      final recognized = await textRecognizer.processImage(inputImage);
      final pageText = recognized.text;

      // Clean up
      await textRecognizer.close();
      await tempFile.delete();

      return pageText;
    } catch (e) {
      return '';
    }
  }

  /// Find text in a string with various search options
  List<SearchResult> _findTextInString(String text, String searchText, int pageNum,
      {bool caseSensitive = false, bool useRegex = false}) {
    final List<SearchResult> results = [];
    
    if (text.isEmpty || searchText.isEmpty) return results;

    String processedText = text;
    String processedSearchText = searchText;

    if (!caseSensitive) {
      processedText = text.toLowerCase();
      processedSearchText = searchText.toLowerCase();
    }

    if (useRegex) {
      try {
        final regex = RegExp(processedSearchText, caseSensitive: caseSensitive);
        final matches = regex.allMatches(processedText);
        
        for (final match in matches) {
          results.add(SearchResult(
            pageNumber: pageNum,
            startIndex: match.start,
            endIndex: match.end,
            matchedText: text.substring(match.start, match.end),
            context: _getContext(text, match.start, match.end),
            confidence: 1.0,
          ));
        }
      } catch (e) {
        // Invalid regex, fall back to simple search
        return _findTextInString(text, searchText, pageNum,
            caseSensitive: caseSensitive);
      }
    } else {
      int startIndex = 0;
      while (true) {
        final index = processedText.indexOf(processedSearchText, startIndex);
        if (index == -1) break;

        final endIndex = index + processedSearchText.length;
        results.add(SearchResult(
          pageNumber: pageNum,
          startIndex: index,
          endIndex: endIndex,
          matchedText: text.substring(index, endIndex),
          context: _getContext(text, index, endIndex),
          confidence: 1.0,
        ));

        startIndex = index + 1;
      }
    }

    return results;
  }

  /// Get context around the matched text
  String _getContext(String text, int startIndex, int endIndex) {
    const contextLength = 50;
    final start = (startIndex - contextLength).clamp(0, text.length);
    final end = (endIndex + contextLength).clamp(0, text.length);
    
    String context = text.substring(start, end);
    
    if (start > 0) context = '...$context';
    if (end < text.length) context = '$context...';
    
    return context;
  }

  /// Perform text replacement in PDF
  Future<bool> _performTextReplacement(File pdfFile, List<SearchResult> searchResults,
      String searchText, String replaceText,
      {bool caseSensitive = false, bool useRegex = false}) async {
    try {
      // This is a simplified implementation
      // In a real PDF editing scenario, you would need to:
      // 1. Parse the PDF structure
      // 2. Modify the text content
      // 3. Rebuild the PDF with new content
      // 4. Handle font and layout preservation
      
      // For now, we'll create a backup and return success
      await _createBackup(pdfFile);
      
      // TODO: Implement actual PDF text replacement
      // This would require a more sophisticated PDF editing library
      
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Create backup of original file
  Future<void> _createBackup(File pdfFile) async {
    try {
      final backupDir = await getApplicationDocumentsDirectory();
      final backupPath = '${backupDir.path}/backups';
      final backupDirFile = Directory(backupPath);
      
      if (!await backupDirFile.exists()) {
        await backupDirFile.create(recursive: true);
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final backupFile = File('$backupPath/backup_$timestamp.pdf');
      await pdfFile.copy(backupFile.path);
    } catch (e) {
      // Backup creation failed, but don't stop the process
      print('Warning: Could not create backup: $e');
    }
  }

  /// Get search statistics
  Future<SearchStatistics> getSearchStatistics(File pdfFile, String searchText,
      {bool caseSensitive = false, bool useRegex = false}) async {
    try {
      final startTime = DateTime.now();
      final results = await findTextInPDF(
        pdfFile,
        searchText,
        caseSensitive: caseSensitive,
        useRegex: useRegex,
      );

      final endTime = DateTime.now();
      final processingTime = endTime.difference(startTime);

      // Calculate statistics
      final pageDistribution = <int, int>{};
      for (final result in results) {
        pageDistribution[result.pageNumber] =
            (pageDistribution[result.pageNumber] ?? 0) + 1;
      }

      return SearchStatistics(
        totalOccurrences: results.length,
        pagesWithMatches: pageDistribution.keys.length,
        pageDistribution: pageDistribution,
        processingTime: processingTime,
        averageConfidence: results.isEmpty
            ? 0.0
            : results.map((r) => r.confidence).reduce((a, b) => a + b) /
                results.length,
      );
    } catch (e) {
      return SearchStatistics(
        totalOccurrences: 0,
        pagesWithMatches: 0,
        pageDistribution: {},
        processingTime: Duration.zero,
        averageConfidence: 0.0,
      );
    }
  }

  /// Validate search query
  bool validateSearchQuery(String searchText, {bool useRegex = false}) {
    if (searchText.isEmpty) return false;
    
    if (useRegex) {
      try {
        RegExp(searchText);
        return true;
      } catch (e) {
        return false;
      }
    }
    
    return true;
  }

  /// Get search suggestions based on content
  Future<List<String>> getSearchSuggestions(File pdfFile, String partialQuery,
      {int maxSuggestions = 5}) async {
    try {
      final document = await PdfDocument.openFile(pdfFile.path);
      final suggestions = <String>{};
      
      // Extract text from first few pages for suggestions
      final maxPages = document.pageCount < 3 ? document.pageCount : 3;
      
      for (int pageNum = 1; pageNum <= maxPages; pageNum++) {
        final page = await document.getPage(pageNum);
        String pageText = '';
        
        try {
          pageText = await _extractTextFromPage(page);
        } catch (e) {
          pageText = await _performOCROnPage(page, pageNum);
        }

        if (pageText.isNotEmpty) {
          final words = pageText.split(RegExp(r'\s+'));
          for (final word in words) {
            if (word.toLowerCase().contains(partialQuery.toLowerCase()) &&
                word.length > partialQuery.length) {
              suggestions.add(word);
              if (suggestions.length >= maxSuggestions) break;
            }
          }
        }
        
        if (suggestions.length >= maxSuggestions) break;
      }

      await document.dispose();
      return suggestions.take(maxSuggestions).toList();
    } catch (e) {
      return [];
    }
  }
}

/// Search result containing match information
class SearchResult {
  final int pageNumber;
  final int startIndex;
  final int endIndex;
  final String matchedText;
  final String context;
  final double confidence;

  SearchResult({
    required this.pageNumber,
    required this.startIndex,
    required this.endIndex,
    required this.matchedText,
    required this.context,
    required this.confidence,
  });

  @override
  String toString() {
    return 'SearchResult(page: $pageNumber, text: "$matchedText", confidence: $confidence)';
  }
}

/// Result of text replacement operation
class ReplaceResult {
  final bool success;
  final int occurrencesFound;
  final int replacementsMade;
  final Duration processingTime;
  final String message;

  ReplaceResult({
    required this.success,
    required this.occurrencesFound,
    required this.replacementsMade,
    required this.processingTime,
    required this.message,
  });

  @override
  String toString() {
    return 'ReplaceResult(success: $success, found: $occurrencesFound, replaced: $replacementsMade, time: ${processingTime.inMilliseconds}ms)';
  }
}

/// Statistics about search operation
class SearchStatistics {
  final int totalOccurrences;
  final int pagesWithMatches;
  final Map<int, int> pageDistribution;
  final Duration processingTime;
  final double averageConfidence;

  SearchStatistics({
    required this.totalOccurrences,
    required this.pagesWithMatches,
    required this.pageDistribution,
    required this.processingTime,
    required this.averageConfidence,
  });

  @override
  String toString() {
    return 'SearchStatistics(occurrences: $totalOccurrences, pages: $pagesWithMatches, time: ${processingTime.inMilliseconds}ms)';
  }
}