import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf_render/pdf_render.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image/image.dart' as img;
import 'dart:ui' as ui;

class PDFTextService {
  static final PDFTextService _instance = PDFTextService._internal();
  factory PDFTextService() => _instance;
  PDFTextService._internal();

  /// Extract text from PDF file
  Future<String> extractTextFromPDF(File pdfFile) async {
    try {
      final document = await PdfDocument.openFile(pdfFile.path);
      String extractedText = '';

      for (int i = 1; i <= document.pageCount; i++) {
        final page = await document.getPage(i);
        
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
          pageText = await _performOCROnPage(page, i);
        }

        if (pageText.isNotEmpty) {
          extractedText += '$pageText\n\n';
        }
      }

      await document.dispose();
      return extractedText.trim();
    } catch (e) {
      throw Exception('Text extraction failed: $e');
    }
  }

  /// Extract text from specific page
  Future<String> extractTextFromPage(File pdfFile, int pageNumber) async {
    try {
      final document = await PdfDocument.openFile(pdfFile.path);

      if (pageNumber < 1 || pageNumber > document.pageCount) {
        await document.dispose();
        throw Exception('Invalid page number');
      }

      final page = await document.getPage(pageNumber);
      
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
        pageText = await _performOCROnPage(page, pageNumber);
      }

      await document.dispose();
      return pageText.trim();
    } catch (e) {
      throw Exception('Page text extraction failed: $e');
    }
  }

  /// Extract text from multiple pages
  Future<Map<int, String>> extractTextFromPages(File pdfFile, List<int> pageNumbers) async {
    try {
      final document = await PdfDocument.openFile(pdfFile.path);
      final Map<int, String> pageTexts = {};

      for (final pageNumber in pageNumbers) {
        if (pageNumber < 1 || pageNumber > document.pageCount) {
          continue; // Skip invalid page numbers
        }

        final page = await document.getPage(pageNumber);
        
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
          pageText = await _performOCROnPage(page, pageNumber);
        }

        if (pageText.isNotEmpty) {
          pageTexts[pageNumber] = pageText.trim();
        }
      }

      await document.dispose();
      return pageTexts;
    } catch (e) {
      throw Exception('Multi-page text extraction failed: $e');
    }
  }

  /// Extract text from a single page
  Future<String> _extractTextFromPage(dynamic page) async {
    // This is a mock implementation since pdf_render doesn't provide text extraction
    // In a real implementation, you would use a different PDF library that supports text extraction
    return '';
  }

  /// Perform OCR on a single page
  Future<String> _performOCROnPage(dynamic page, int pageNumber) async {
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
      final tempPath = '${tempDir.path}/ocr_page_$pageNumber.png';
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

  /// Get PDF metadata
  Future<PDFMetadata> getPDFMetadata(File pdfFile) async {
    try {
      final document = await PdfDocument.openFile(pdfFile.path);
      
      final metadata = PDFMetadata(
        pageCount: document.pageCount,
        title: document.title ?? 'Unknown',
        author: document.author ?? 'Unknown',
        subject: document.subject ?? 'Unknown',
        creator: document.creator ?? 'Unknown',
        producer: document.producer ?? 'Unknown',
        creationDate: document.creationDate,
        modificationDate: document.modificationDate,
        fileSize: await pdfFile.length(),
      );

      await document.dispose();
      return metadata;
    } catch (e) {
      throw Exception('Failed to get PDF metadata: $e');
    }
  }

  /// Get page dimensions
  Future<Map<int, PageDimensions>> getPageDimensions(File pdfFile) async {
    try {
      final document = await PdfDocument.openFile(pdfFile.path);
      final Map<int, PageDimensions> dimensions = {};

      for (int i = 1; i <= document.pageCount; i++) {
        final page = await document.getPage(i);
        dimensions[i] = PageDimensions(
          pageNumber: i,
          width: page.width,
          height: page.height,
          aspectRatio: page.width / page.height,
        );
      }

      await document.dispose();
      return dimensions;
    } catch (e) {
      throw Exception('Failed to get page dimensions: $e');
    }
  }

  /// Check if PDF has extractable text
  Future<bool> hasExtractableText(File pdfFile) async {
    try {
      final document = await PdfDocument.openFile(pdfFile.path);
      
      // Try to extract text from first page
      final firstPage = await document.getPage(1);
      String pageText = '';
      
      try {
        pageText = await _extractTextFromPage(firstPage);
      } catch (e) {
        pageText = '';
      }

      await document.dispose();
      return pageText.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Extract text with confidence scores
  Future<List<TextExtractionResult>> extractTextWithConfidence(File pdfFile) async {
    try {
      final document = await PdfDocument.openFile(pdfFile.path);
      final List<TextExtractionResult> results = [];

      for (int i = 1; i <= document.pageCount; i++) {
        final page = await document.getPage(i);
        
        // Try to extract text directly first
        String pageText = '';
        double confidence = 1.0;
        
        try {
          pageText = await _extractTextFromPage(page);
        } catch (e) {
          // If no text extracted, use OCR
          pageText = '';
        }

        if (pageText.isEmpty) {
          // Fallback to OCR for this page
          pageText = await _performOCROnPage(page, i);
          confidence = 0.8; // OCR confidence is lower
        }

        if (pageText.isNotEmpty) {
          results.add(TextExtractionResult(
            pageNumber: i,
            text: pageText.trim(),
            confidence: confidence,
            extractionMethod: confidence == 1.0 ? 'Direct' : 'OCR',
          ));
        }
      }

      await document.dispose();
      return results;
    } catch (e) {
      throw Exception('Text extraction with confidence failed: $e');
    }
  }

  /// Extract text from specific area of a page
  Future<String> extractTextFromArea(File pdfFile, int pageNumber, 
      {required double x, required double y, required double width, required double height}) async {
    try {
      final document = await PdfDocument.openFile(pdfFile.path);

      if (pageNumber < 1 || pageNumber > document.pageCount) {
        await document.dispose();
        throw Exception('Invalid page number');
      }

      final page = await document.getPage(pageNumber);
      
      // Render the specific area
      final pageImage = await page.render(
        width: (page.width * 2).toInt(),
        height: (page.height * 2).toInt(),
      );

      await pageImage.createImageIfNotAvailable();
      final img = pageImage.imageIfAvailable!;
      final byteData = await img.toByteData(format: ui.ImageByteFormat.png);

      // Save image temporarily
      final tempDir = await getTemporaryDirectory();
      final tempPath = '${tempDir.path}/area_extraction_$pageNumber.png';
      final tempFile =
          await File(tempPath).writeAsBytes(byteData!.buffer.asUint8List());

      // Crop the image to the specified area
      final croppedImage = await _cropImage(tempFile, x, y, width, height);

      // Perform OCR on the cropped area
      final inputImage = InputImage.fromFilePath(croppedImage.path);
      final textRecognizer = TextRecognizer();
      final recognized = await textRecognizer.processImage(inputImage);
      final extractedText = recognized.text;

      // Clean up
      await textRecognizer.close();
      await tempFile.delete();
      await croppedImage.delete();

      await document.dispose();
      return extractedText.trim();
    } catch (e) {
      throw Exception('Area text extraction failed: $e');
    }
  }

  /// Crop image to specified area
  Future<File> _cropImage(File imageFile, double x, double y, double width, double height) async {
    try {
      final imageBytes = await imageFile.readAsBytes();
      final image = img.decodeImage(imageBytes);
      
      if (image == null) {
        throw Exception('Failed to decode image');
      }

      // Convert coordinates to integers
      final startX = (x * image.width).round();
      final startY = (y * image.height).round();
      final cropWidth = (width * image.width).round();
      final cropHeight = (height * image.height).round();

      // Ensure coordinates are within bounds
      final safeStartX = startX.clamp(0, image.width);
      final safeStartY = startY.clamp(0, image.height);
      final safeWidth = cropWidth.clamp(1, image.width - safeStartX);
      final safeHeight = cropHeight.clamp(1, image.height - safeStartY);

      // Crop the image
      final croppedImage = img.copyCrop(
        image,
        x: safeStartX,
        y: safeStartY,
        width: safeWidth,
        height: safeHeight,
      );

      // Save cropped image
      final tempDir = await getTemporaryDirectory();
      final croppedPath = '${tempDir.path}/cropped_${DateTime.now().millisecondsSinceEpoch}.png';
      final croppedFile = File(croppedPath);
      await croppedFile.writeAsBytes(img.encodePng(croppedImage));

      return croppedFile;
    } catch (e) {
      throw Exception('Image cropping failed: $e');
    }
  }

  /// Get text statistics
  Future<TextStatistics> getTextStatistics(File pdfFile) async {
    try {
      final extractedText = await extractTextFromPDF(pdfFile);
      
      if (extractedText.isEmpty) {
        return TextStatistics(
          totalCharacters: 0,
          totalWords: 0,
          totalSentences: 0,
          totalParagraphs: 0,
          averageWordsPerSentence: 0,
          averageCharactersPerWord: 0,
        );
      }

      final characters = extractedText.length;
      final words = extractedText.split(RegExp(r'\s+')).where((word) => word.isNotEmpty).length;
      final sentences = extractedText.split(RegExp(r'[.!?]+')).where((sentence) => sentence.trim().isNotEmpty).length;
      final paragraphs = extractedText.split('\n\n').where((paragraph) => paragraph.trim().isNotEmpty).length;

      return TextStatistics(
        totalCharacters: characters,
        totalWords: words,
        totalSentences: sentences,
        totalParagraphs: paragraphs,
        averageWordsPerSentence: words > 0 ? words / sentences : 0,
        averageCharactersPerWord: words > 0 ? characters / words : 0,
      );
    } catch (e) {
      throw Exception('Failed to get text statistics: $e');
    }
  }

  /// Search text in PDF
  Future<List<TextSearchResult>> searchTextInPDF(File pdfFile, String searchText,
      {bool caseSensitive = false, bool useRegex = false}) async {
    try {
      final extractedText = await extractTextFromPDF(pdfFile);
      final List<TextSearchResult> results = [];
      
      if (extractedText.isEmpty || searchText.isEmpty) {
        return results;
      }

      String processedText = extractedText;
      String processedSearchText 
      
      if (!caseSensitive) {
        processedText = extractedText.toLowerCase();
        processedSearchText = searchText.toLowerCase();
      }

      if (useRegex) {
        try {
          final regex = RegExp(processedSearchText, caseSensitive: caseSensitive);
          final matches = regex.allMatches(processedText);
          
          for (final match in matches) {
            results.add(TextSearchResult(
              startIndex: match.start,
              endIndex: match.end,
              matchedText: extractedText.substring(match.start, match.end),
              context: _getContext(extractedText, match.start, match.end),
            ));
          }
        } catch (e) {
          // Invalid regex, fall back to simple search
          return searchTextInPDF(pdfFile, searchText,
              caseSensitive: caseSensitive);
        }
      } else {
        int startIndex = 0;
        while (true) {
          final index = processedText.indexOf(processedSearchText, startIndex);
          if (index == -1) break;

          final endIndex = index + processedSearchText.length;
          results.add(TextSearchResult(
            startIndex: index,
            endIndex: endIndex,
            matchedText: extractedText.substring(index, endIndex),
            context: _getContext(extractedText, index, endIndex),
          ));

          startIndex = index + 1;
        }
      }

      return results;
    } catch (e) {
      throw Exception('Text search failed: $e');
    }
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

  /// Extract text from PDF with options
  Future<String> extractTextWithOptions(File pdfFile, TextExtractionOptions options) async {
    try {
      final document = await PdfDocument.openFile(pdfFile.path);
      String extractedText = '';

      for (int i = 1; i <= document.pageCount; i++) {
        // Skip pages if specified
        if (options.excludePages.contains(i)) {
          continue;
        }

        final page = await document.getPage(i);
        
        // Try to extract text directly first
        String pageText = '';
        try {
          pageText = await _extractTextFromPage(page);
        } catch (e) {
          pageText = '';
        }

        if (pageText.isEmpty && options.useOCR) {
          // Fallback to OCR for this page
          pageText = await _performOCROnPage(page, i);
        }

        if (pageText.isNotEmpty) {
          // Apply text processing options
          if (options.removeExtraWhitespace) {
            pageText = _removeExtraWhitespace(pageText);
          }
          
          if (options.normalizeLineBreaks) {
            pageText = _normalizeLineBreaks(pageText);
          }

          extractedText += '$pageText\n\n';
        }
      }

      await document.dispose();
      return extractedText.trim();
    } catch (e) {
      throw Exception('Text extraction with options failed: $e');
    }
  }

  /// Remove extra whitespace from text
  String _removeExtraWhitespace(String text) {
    return text.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  /// Normalize line breaks in text
  String _normalizeLineBreaks(String text) {
    return text.replaceAll(RegExp(r'\n+'), '\n');
  }
}

/// PDF metadata container
class PDFMetadata {
  final int pageCount;
  final String title;
  final String author;
  final String subject;
  final String creator;
  final String producer;
  final DateTime? creationDate;
  final DateTime? modificationDate;
  final int fileSize;

  PDFMetadata({
    required this.pageCount,
    required this.title,
    required this.author,
    required this.subject,
    required this.creator,
    required this.producer,
    this.creationDate,
    this.modificationDate,
    required this.fileSize,
  });

  @override
  String toString() {
    return 'PDFMetadata(title: $title, pages: $pageCount, size: $fileSize)';
  }
}

/// Page dimensions container
class PageDimensions {
  final int pageNumber;
  final double width;
  final double height;
  final double aspectRatio;

  PageDimensions({
    required this.pageNumber,
    required this.width,
    required this.height,
    required this.aspectRatio,
  });

  @override
  String toString() {
    return 'PageDimensions(page: $pageNumber, ${width.toStringAsFixed(1)}x${height.toStringAsFixed(1)})';
  }
}

/// Text extraction result with confidence
class TextExtractionResult {
  final int pageNumber;
  final String text;
  final double confidence;
  final String extractionMethod;

  TextExtractionResult({
    required this.pageNumber,
    required this.text,
    required this.confidence,
    required this.extractionMethod,
  });

  @override
  String toString() {
    return 'TextExtractionResult(page: $pageNumber, method: $extractionMethod, confidence: $confidence)';
  }
}

/// Text search result
class TextSearchResult {
  final int startIndex;
  final int endIndex;
  final String matchedText;
  final String context;

  TextSearchResult({
    required this.startIndex,
    required this.endIndex,
    required this.matchedText,
    required this.context,
  });

  @override
  String toString() {
    return 'TextSearchResult(text: "$matchedText", context: "$context")';
  }
}

/// Text statistics container
class TextStatistics {
  final int totalCharacters;
  final int totalWords;
  final int totalSentences;
  final int totalParagraphs;
  final double averageWordsPerSentence;
  final double averageCharactersPerWord;

  TextStatistics({
    required this.totalCharacters,
    required this.totalWords,
    required this.totalSentences,
    required this.totalParagraphs,
    required this.averageWordsPerSentence,
    required this.averageCharactersPerWord,
  });

  @override
  String toString() {
    return 'TextStatistics(chars: $totalCharacters, words: $totalWords, sentences: $totalSentences)';
  }
}

/// Text extraction options
class TextExtractionOptions {
  final List<int> excludePages;
  final bool useOCR;
  final bool removeExtraWhitespace;
  final bool normalizeLineBreaks;

  TextExtractionOptions({
    this.excludePages = const [],
    this.useOCR = true,
    this.removeExtraWhitespace = true,
    this.normalizeLineBreaks = true,
  });
}