import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf_render/pdf_render.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image/image.dart' as img;
import 'dart:ui' as ui;

class OfflineTranslationService {
  static final OfflineTranslationService _instance = OfflineTranslationService._internal();
  factory OfflineTranslationService() => _instance;
  OfflineTranslationService._internal();

  // Mock translation models and vocabulary
  Map<String, dynamic>? _translationModel;
  Map<String, int>? _vocabulary;
  Map<String, Map<String, String>>? _translationDictionary;
  Map<String, List<String>>? _languageModels;

  /// Initialize the service
  Future<void> initialize() async {
    await _loadMockData();
  }

  /// Load mock data for demonstration
  Future<void> _loadMockData() async {
    // Mock translation model parameters
    _translationModel = {
      'max_length': 512,
      'vocab_size': 1000,
      'embedding_dim': 256,
      'hidden_dim': 512,
      'num_layers': 6,
      'num_heads': 8,
      'dropout': 0.1,
    };

    // Mock vocabulary for tokenization
    _vocabulary = {
      '<PAD>': 0,
      '<UNK>': 1,
      '<START>': 2,
      '<END>': 3,
      'the': 4,
      'a': 5,
      'is': 6,
      'and': 7,
      'of': 8,
      'to': 9,
      'in': 10,
      'for': 11,
      'with': 12,
      'on': 13,
      'at': 14,
      'by': 15,
      'from': 16,
      'up': 17,
      'about': 18,
      'into': 19,
      'through': 20,
      'during': 21,
      'before': 22,
      'after': 23,
      'above': 24,
      'below': 25,
      'between': 26,
      'among': 27,
      'within': 28,
      'without': 29,
      'against': 30,
      'toward': 31,
      'towards': 32,
      'upon': 33,
      'across': 34,
      'behind': 35,
      'beneath': 36,
      'beside': 37,
      'beyond': 38,
      'inside': 39,
      'outside': 40,
      'under': 41,
      'over': 42,
      'around': 43,
      'along': 44,
      'down': 45,
      'off': 46,
      'out': 47,
      'away': 48,
      'back': 49,
      'forward': 50,
    };

    // Mock translation dictionary
    _translationDictionary = {
      'en': {
        'es': {
          'hello': 'hola',
          'world': 'mundo',
          'good': 'bueno',
          'morning': 'mañana',
          'thank': 'gracias',
          'you': 'tú',
          'welcome': 'bienvenido',
          'please': 'por favor',
          'sorry': 'lo siento',
          'goodbye': 'adiós',
        },
        'fr': {
          'hello': 'bonjour',
          'world': 'monde',
          'good': 'bon',
          'morning': 'matin',
          'thank': 'merci',
          'you': 'vous',
          'welcome': 'bienvenue',
          'please': 's\'il vous plaît',
          'sorry': 'désolé',
          'goodbye': 'au revoir',
        },
        'de': {
          'hello': 'hallo',
          'world': 'welt',
          'good': 'gut',
          'morning': 'morgen',
          'thank': 'danke',
          'you': 'du',
          'welcome': 'willkommen',
          'please': 'bitte',
          'sorry': 'entschuldigung',
          'goodbye': 'auf wiedersehen',
        },
      },
    };

    // Mock language models
    _languageModels = {
      'en': ['the', 'a', 'is', 'and', 'of', 'to', 'in', 'for', 'with', 'on'],
      'es': ['el', 'la', 'es', 'y', 'de', 'a', 'en', 'por', 'con', 'para'],
      'fr': ['le', 'la', 'est', 'et', 'de', 'à', 'en', 'pour', 'avec', 'sur'],
      'de': ['der', 'die', 'ist', 'und', 'von', 'zu', 'in', 'für', 'mit', 'auf'],
    };
  }

  /// Translate text from PDF file
  Future<TranslationResult> translatePDF(File pdfFile,
      {required String sourceLanguage,
      required String targetLanguage,
      bool preserveFormatting = true}) async {
    try {
      final startTime = DateTime.now();
      
      // Extract text from PDF
      String extractedText = await _extractTextFromPDF(pdfFile);

      if (extractedText.isEmpty) {
        return TranslationResult(
          success: false,
          originalText: '',
          translatedText: '',
          sourceLanguage: sourceLanguage,
          targetLanguage: targetLanguage,
          processingTime: DateTime.now().difference(startTime),
          message: 'No text could be extracted from the PDF',
        );
      }

      // Perform translation
      final translatedText = await _translateTextOffline(
        extractedText,
        sourceLanguage: sourceLanguage,
        targetLanguage: targetLanguage,
      );

      final endTime = DateTime.now();
      final processingTime = endTime.difference(startTime);

      return TranslationResult(
        success: true,
        originalText: extractedText,
        translatedText: translatedText,
        sourceLanguage: sourceLanguage,
        targetLanguage: targetLanguage,
        processingTime: processingTime,
        message: 'Translation completed successfully',
      );
    } catch (e) {
      return TranslationResult(
        success: false,
        originalText: '',
        translatedText: '',
        sourceLanguage: sourceLanguage,
        targetLanguage: targetLanguage,
        processingTime: Duration.zero,
        message: 'Translation failed: $e',
      );
    }
  }

  /// Extract text from PDF file
  Future<String> _extractTextFromPDF(File pdfFile) async {
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
          pageText = await _performOCR(pdfFile);
        }

        extractedText += '$pageText\n';
      }

      await document.dispose();
      return extractedText.trim();
    } catch (e) {
      // If all else fails, use OCR
      return await _performOCR(pdfFile);
    }
  }

  /// Extract text from a single page
  Future<String> _extractTextFromPage(dynamic page) async {
    // This is a mock implementation since pdf_render doesn't provide text extraction
    // In a real implementation, you would use a different PDF library that supports text extraction
    return '';
  }

  /// Perform OCR on PDF
  Future<String> _performOCR(File pdfFile) async {
    try {
      // Convert PDF pages to images and perform OCR
      final document = await PdfDocument.openFile(pdfFile.path);
      String ocrText = '';
      final textRecognizer = TextRecognizer();

      for (int i = 1; i <= document.pageCount; i++) {
        final page = await document.getPage(i);
        final pageImage = await page.render(
          width: (page.width * 2).toInt(),
          height: (page.height * 2).toInt(),
        );

        await pageImage.createImageIfNotAvailable();
        final img = pageImage.imageIfAvailable!;
        final byteData = await img.toByteData(format: ui.ImageByteFormat.png);

        // Save image temporarily
        final tempDir = await getTemporaryDirectory();
        final tempPath = '${tempDir.path}/ocr_page_$i.png';
        final tempFile =
            await File(tempPath).writeAsBytes(byteData!.buffer.asUint8List());

        final inputImage = InputImage.fromFilePath(tempPath);
        final recognized = await textRecognizer.processImage(inputImage);
        final pageOcr = recognized.text;
        ocrText += '$pageOcr\n\n';

        await tempFile.delete();
        // PdfPage from pdf_render doesn't have a dispose method
      }

      await document.dispose();
      await textRecognizer.close();

      return ocrText;
    } catch (e) {
      throw Exception('OCR failed: $e');
    }
  }

  /// Tokenize text
  List<int> _tokenizeText(String text) {
    if (_vocabulary == null) return [];

    // Simple tokenization for mock purposes
    final words = text.toLowerCase().split(RegExp(r'\s+'));
    final tokens = <int>[];
    tokens.add(_vocabulary!['<START>'] ?? 2);

    for (final word in words) {
      final tokenId = _vocabulary![word] ?? _vocabulary!['<UNK>'] ?? 1;
      tokens.add(tokenId);
    }

    tokens.add(_vocabulary!['<END>'] ?? 3);

    // Pad to max length
    while (tokens.length < _translationModel!['max_length']) {
      tokens.add(_vocabulary!['<PAD>'] ?? 0);
    }

    return tokens;
  }

  /// Detect language from text
  Future<String> _detectLanguage(String text) async {
    // Simple language detection based on common words
    const commonWords = {
      'en': ['the', 'a', 'is', 'and', 'of'],
      'es': ['el', 'la', 'es', 'y', 'de'],
      'fr': ['le', 'la', 'est', 'et', 'de'],
      'de': ['der', 'die', 'ist', 'und', 'von'],
    };

    final wordCounts = <String, int>{};
    final words = text.toLowerCase().split(RegExp(r'\s+'));

    for (final lang in commonWords.keys) {
      int count = 0;
      for (final word in words) {
        if (commonWords[lang]!.contains(word)) {
          count++;
        }
      }
      wordCounts[lang] = count;
    }

    return wordCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  /// Translate text offline
  Future<String> _translateTextOffline(String text,
      {required String sourceLanguage, required String targetLanguage}) async {
    try {
      // Tokenize input
      final tokens = _tokenizeText(text);

      // Simple mock translation using dictionary lookup
      final translatedWords = <String>[];
      final words = text.split(RegExp(r'\s+'));

      for (final word in words) {
        final cleanWord = word.replaceAll(RegExp(r'[^\w]'), '').toLowerCase();
        
        if (_translationDictionary != null &&
            _translationDictionary!.containsKey(sourceLanguage) &&
            _translationDictionary![sourceLanguage]!.containsKey(targetLanguage) &&
            _translationDictionary![sourceLanguage]![targetLanguage]!.containsKey(cleanWord)) {
          
          final translation = _translationDictionary![sourceLanguage]![targetLanguage]![cleanWord];
          translatedWords.add(translation);
        } else {
          // Keep original word if no translation found
          translatedWords.add(word);
        }
      }

      return translatedWords.join(' ');
    } catch (e) {
      return text; // Return original text if translation fails
    }
  }

  /// Get available languages
  List<String> getAvailableLanguages() {
    return ['en', 'es', 'fr', 'de', 'it', 'pt', 'ru', 'zh', 'ja', 'ko', 'ar', 'hi'];
  }

  /// Get language names
  Map<String, String> getLanguageNames() {
    return {
      'en': 'English',
      'es': 'Spanish',
      'fr': 'French',
      'de': 'German',
      'it': 'Italian',
      'pt': 'Portuguese',
      'ru': 'Russian',
      'zh': 'Chinese',
      'ja': 'Japanese',
      'ko': 'Korean',
      'ar': 'Arabic',
      'hi': 'Hindi',
    };
  }

  /// Check if language is supported
  bool isLanguageSupported(String languageCode) {
    return getAvailableLanguages().contains(languageCode.toLowerCase());
  }

  /// Get translation quality score
  double getTranslationQuality(String sourceLanguage, String targetLanguage) {
    // Mock quality scores based on language pair
    const qualityScores = {
      'en': {
        'es': 0.95,
        'fr': 0.93,
        'de': 0.91,
        'it': 0.89,
        'pt': 0.87,
      },
      'es': {
        'en': 0.94,
        'fr': 0.88,
        'de': 0.86,
        'it': 0.92,
        'pt': 0.96,
      },
      'fr': {
        'en': 0.92,
        'es': 0.87,
        'de': 0.89,
        'it': 0.94,
        'pt': 0.85,
      },
    };

    return qualityScores[sourceLanguage]?[targetLanguage] ?? 0.8;
  }

  /// Batch translate multiple texts
  Future<List<TranslationResult>> batchTranslate(
      List<String> texts,
      {required String sourceLanguage,
      required String targetLanguage}) async {
    final results = <TranslationResult>[];

    for (final text in texts) {
      try {
        final translatedText = await _translateTextOffline(
          text,
          sourceLanguage: sourceLanguage,
          targetLanguage: targetLanguage,
        );

        results.add(TranslationResult(
          success: true,
          originalText: text,
          translatedText: translatedText,
          sourceLanguage: sourceLanguage,
          targetLanguage: targetLanguage,
          processingTime: Duration.zero,
          message: 'Translation completed',
        ));
      } catch (e) {
        results.add(TranslationResult(
          success: false,
          originalText: text,
          translatedText: '',
          sourceLanguage: sourceLanguage,
          targetLanguage: targetLanguage,
          processingTime: Duration.zero,
          message: 'Translation failed: $e',
        ));
      }
    }

    return results;
  }

  /// Preprocess text for better translation
  String _preprocessText(String text) {
    // Remove extra whitespace
    text = text.replaceAll(RegExp(r'\s+'), ' ');
    
    // Normalize punctuation
    text = text.replaceAll(RegExp(r'[^\w\s\.\,\!\?\;\:\-\(\)]'), '');
    
    // Normalize line breaks
    text = text.replaceAll(RegExp(r'\n+'), ' ');
    
    return text.trim();
  }

  /// Postprocess translated text
  String _postprocessText(String text, String originalText) {
    // Preserve original formatting where possible
    // This is a simplified implementation
    
    // Preserve paragraph breaks
    final paragraphs = originalText.split('\n\n');
    if (paragraphs.length > 1) {
      final translatedParagraphs = text.split('. ');
      if (translatedParagraphs.length >= paragraphs.length) {
        return translatedParagraphs.take(paragraphs.length).join('.\n\n');
      }
    }
    
    return text;
  }
}

/// Translation result containing all relevant information
class TranslationResult {
  final bool success;
  final String originalText;
  final String translatedText;
  final String sourceLanguage;
  final String targetLanguage;
  final Duration processingTime;
  final String message;

  TranslationResult({
    required this.success,
    required this.originalText,
    required this.translatedText,
    required this.sourceLanguage,
    required this.targetLanguage,
    required this.processingTime,
    required this.message,
  });

  @override
  String toString() {
    return 'TranslationResult(success: $success, from: $sourceLanguage, to: $targetLanguage, time: ${processingTime.inMilliseconds}ms)';
  }
}
Now let me show you the next file:

📄 2. Updated file_service.dart
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cross_file/cross_file.dart';

class FileService {
  static final FileService _instance = FileService._internal();
  factory FileService() => _instance;
  FileService._internal();

  /// Get application documents directory
  Future<Directory> getDocumentsDirectory() async {
    return await getApplicationDocumentsDirectory();
  }

  /// Get temporary directory
  Future<Directory> getTemporaryDirectory() async {
    return await getTemporaryDirectory();
  }

  /// Get application support directory
  Future<Directory> getApplicationSupportDirectory() async {
    return await getApplicationSupportDirectory();
  }

  /// Create directory if it doesn't exist
  Future<Directory> createDirectoryIfNotExists(String path) async {
    final directory = Directory(path);
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    return directory;
  }

  /// Check if file exists
  Future<bool> fileExists(String filePath) async {
    final file = File(filePath);
    return await file.exists();
  }

  /// Check if directory exists
  Future<bool> directoryExists(String directoryPath) async {
    final directory = Directory(directoryPath);
    return await directory.exists();
  }

  /// Get file size in bytes
  Future<int> getFileSize(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        return await file.length();
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  /// Get file size in human readable format
  String getFileSizeReadable(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// Get file extension
  String getFileExtension(String filePath) {
    final fileName = filePath.split('/').last;
    final parts = fileName.split('.');
    return parts.length > 1 ? '.${parts.last.toLowerCase()}' : '';
  }

  /// Get file name without extension
  String getFileNameWithoutExtension(String filePath) {
    final fileName = filePath.split('/').last;
    final parts = fileName.split('.');
    return parts.length > 1 ? parts.take(parts.length - 1).join('.') : fileName;
  }

  /// Get file name with extension
  String getFileName(String filePath) {
    return filePath.split('/').last;
  }

  /// Get directory path
  String getDirectoryPath(String filePath) {
    final parts = filePath.split('/');
    parts.removeLast();
    return parts.join('/');
  }

  /// Copy file
  Future<File> copyFile(String sourcePath, String destinationPath) async {
    final sourceFile = File(sourcePath);
    final destinationFile = File(destinationPath);
    
    // Create destination directory if it doesn't exist
    final destinationDir = Directory(getDirectoryPath(destinationPath));
    if (!await destinationDir.exists()) {
      await destinationDir.create(recursive: true);
    }
    
    return await sourceFile.copy(destinationPath);
  }

  /// Move file
  Future<File> moveFile(String sourcePath, String destinationPath) async {
    final sourceFile = File(sourcePath);
    final destinationFile = File(destinationPath);
    
    // Create destination directory if it doesn't exist
    final destinationDir = Directory(getDirectoryPath(destinationPath));
    if (!await destinationDir.exists()) {
      await destinationDir.create(recursive: true);
    }
    
    return await sourceFile.rename(destinationPath);
  }

  /// Delete file
  Future<bool> deleteFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Delete directory and all contents
  Future<bool> deleteDirectory(String directoryPath) async {
    try {
      final directory = Directory(directoryPath);
      if (await directory.exists()) {
        await directory.delete(recursive: true);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// List files in directory
  Future<List<FileSystemEntity>> listDirectory(String directoryPath) async {
    try {
      final directory = Directory(directoryPath);
      if (await directory.exists()) {
        return await directory.list().toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// List only files in directory
  Future<List<File>> listFiles(String directoryPath) async {
    try {
      final entities = await listDirectory(directoryPath);
      final files = <File>[];
      
      for (final entity in entities) {
        if (entity is File) {
          files.add(entity);
        }
      }
      
      return files;
    } catch (e) {
      return [];
    }
  }

  /// List only directories in directory
  Future<List<Directory>> listDirectories(String directoryPath) async {
    try {
      final entities = await listDirectory(directoryPath);
      final directories = <Directory>[];
      
      for (final entity in entities) {
        if (entity is Directory) {
          directories.add(entity);
        }
      }
      
      return directories;
    } catch (e) {
      return [];
    }
  }

  /// Read file as string
  Future<String> readFileAsString(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        return await file.readAsString();
      }
      throw Exception('File does not exist: $filePath');
    } catch (e) {
      throw Exception('Failed to read file: $e');
    }
  }

  /// Read file as bytes
  Future<Uint8List> readFileAsBytes(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        return await file.readAsBytes();
      }
      throw Exception('File does not exist: $filePath');
    } catch (e) {
      throw Exception('Failed to read file: $e');
    }
  }

  /// Write string to file
  Future<File> writeFileAsString(String filePath, String content) async {
    try {
      final file = File(filePath);
      
      // Create directory if it doesn't exist
      final directory = Directory(getDirectoryPath(filePath));
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
      
      return await file.writeAsString(content);
    } catch (e) {
      throw Exception('Failed to write file: $e');
    }
  }

  /// Write bytes to file
  Future<File> writeFileAsBytes(String filePath, Uint8List bytes) async {
    try {
      final file = File(filePath);
      
      // Create directory if it doesn't exist
      final directory = Directory(getDirectoryPath(filePath));
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
      
      return await file.writeAsBytes(bytes);
    } catch (e) {
      throw Exception('Failed to write file: $e');
    }
  }

  /// Append string to file
  Future<File> appendToFile(String filePath, String content) async {
    try {
      final file = File(filePath);
      
      // Create directory if it doesn't exist
      final directory = Directory(getDirectoryPath(filePath));
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
      
      return await file.writeAsString(content, mode: FileMode.append);
    } catch (e) {
      throw Exception('Failed to append to file: $e');
    }
  }

  /// Share file using SharePlus
  Future<void> shareFile(File file, {String? text}) async {
    try {
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          text: text ?? 'Shared from Inkwise PDF',
        ),
      );
    } catch (e) {
      throw Exception('Failed to share file: $e');
    }
  }

  /// Share multiple files
  Future<void> shareFiles(List<File> files, {String? text}) async {
    try {
      final xFiles = files.map((file) => XFile(file.path)).toList();
      await SharePlus.instance.share(
        ShareParams(
          files: xFiles,
          text: text ?? 'Shared from Inkwise PDF',
        ),
      );
    } catch (e) {
      throw Exception('Failed to share files: $e');
    }
  }

  /// Share text
  Future<void> shareText(String text, {String? subject}) async {
    try {
      await SharePlus.instance.share(
        ShareParams(
          text: text,
          subject: subject,
        ),
      );
    } catch (e) {
      throw Exception('Failed to share text: $e');
    }
  }

  /// Create backup of file
  Future<File> createBackup(String filePath) async {
    try {
      final sourceFile = File(filePath);
      if (!await sourceFile.exists()) {
        throw Exception('Source file does not exist: $filePath');
      }

      final backupDir = await getApplicationDocumentsDirectory();
      final backupPath = '${backupDir.path}/backups';
      final backupDirFile = Directory(backupPath);
      
      if (!await backupDirFile.exists()) {
        await backupDirFile.create(recursive: true);
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = getFileName(filePath);
      final backupFileName = 'backup_${timestamp}_$fileName';
      final backupPathFull = '$backupPath/$backupFileName';

      return await sourceFile.copy(backupPathFull);
    } catch (e) {
      throw Exception('Failed to create backup: $e');
    }
  }

  /// Get file information
  Future<FileInfo> getFileInfo(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('File does not exist: $filePath');
      }

      final stat = await file.stat();
      
      return FileInfo(
        path: filePath,
        name: getFileName(filePath),
        nameWithoutExtension: getFileNameWithoutExtension(filePath),
        extension: getFileExtension(filePath),
        size: stat.size,
        sizeReadable: getFileSizeReadable(stat.size),
        modified: stat.modified,
        accessed: stat.accessed,
        created: stat.changed,
        isFile: stat.type == FileSystemEntityType.file,
        isDirectory: stat.type == FileSystemEntityType.directory,
      );
    } catch (e) {
      throw Exception('Failed to get file info: $e');
    }
  }

  /// Search for files by pattern
  Future<List<File>> searchFiles(String directoryPath, String pattern) async {
    try {
      final files = await listFiles(directoryPath);
      final matchingFiles = <File>[];
      
      for (final file in files) {
        final fileName = getFileName(file.path);
        if (fileName.toLowerCase().contains(pattern.toLowerCase())) {
          matchingFiles.add(file);
        }
      }
      
      return matchingFiles;
    } catch (e) {
      return [];
    }
  }

  /// Get available disk space
  Future<int> getAvailableDiskSpace() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final stat = await directory.stat();
      return stat.size;
    } catch (e) {
      return 0;
    }
  }

  /// Clean temporary files
  Future<void> cleanTempFiles() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final files = await listFiles(tempDir.path);
      
      for (final file in files) {
        try {
          await file.delete();
        } catch (e) {
          // Ignore errors for individual file deletion
        }
      }
    } catch (e) {
      // Ignore cleanup errors
    }
  }

  /// Validate file path
  bool isValidFilePath(String filePath) {
    // Basic validation - check for invalid characters
    final invalidChars = RegExp(r'[<>:"|?*]');
    return !invalidChars.hasMatch(filePath);
  }

  /// Sanitize file name
  String sanitizeFileName(String fileName) {
    // Remove or replace invalid characters
    return fileName.replaceAll(RegExp(r'[<>:"|?*]'), '_');
  }
}

/// File information container
class FileInfo {
  final String path;
  final String name;
  final String nameWithoutExtension;
  final String extension;
  final int size;
  final String sizeReadable;
  final DateTime modified;
  final DateTime accessed;
  final DateTime created;
  final bool isFile;
  final bool isDirectory;

  FileInfo({
    required this.path,
    required this.name,
    required this.nameWithoutExtension,
    required this.extension,
    required this.size,
    required this.sizeReadable,
    required this.modified,
    required this.accessed,
    required this.created,
    required this.isFile,
    required this.isDirectory,
  });

  @override
  String toString() {
    return 'FileInfo(name: $name, size: $sizeReadable, modified: $modified)';
  }
}