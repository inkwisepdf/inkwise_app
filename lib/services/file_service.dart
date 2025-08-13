import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:open_filex/open_filex.dart';
import 'package:inkwise_pdf/services/performance_service.dart';

class FileService {
  static Future<String> getAppDirectoryPath() async {
    final directory = await getApplicationDocumentsDirectory();
    final appDir = Directory('${directory.path}/inkwise_pdf');
    if (!await appDir.exists()) {
      await appDir.create(recursive: true);
    }
    return appDir.path;
  }

  static Future<File> writeFile(String filename, List<int> bytes) async {
    return await PerformanceService().withOperationLimit(() async {
      PerformanceService().startOperation('file_write');

      final path = await getAppDirectoryPath();
      final file = File('$path/$filename');
      final result = await file.writeAsBytes(bytes, flush: true);

      // Cache the file data for faster subsequent access
      PerformanceService().setCache('file_$filename', bytes);

      PerformanceService().endOperation('file_write');
      return result;
    });
  }

  static Future<File?> pickFile({List<String>? allowedExtensions}) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: allowedExtensions ?? ['pdf'],
      );

      if (result != null && result.files.single.path != null) {
        return File(result.files.single.path!);
      }
      return null;
    } catch (e) {
      throw Exception('Error picking file: $e');
    }
  }

  static Future<List<File>> pickMultipleFiles({List<String>? allowedExtensions}) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: allowedExtensions ?? ['pdf'],
        allowMultiple: true,
      );

      if (result != null) {
        return result.files
            .where((file) => file.path != null)
            .map((file) => File(file.path!))
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('Error picking files: $e');
    }
  }

  static Future<void> deleteFile(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
    }
  }

  static Future<void> shareFile(File file) async {
    try {
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          text: 'Shared from Inkwise PDF',
        ),
      );
    } catch (e) {
      throw Exception('Error sharing file: $e');
    }
  }

  static Future<void> openFile(File file) async {
    try {
      await OpenFilex.open(file.path);
    } catch (e) {
      throw Exception('Error opening file: $e');
    }
  }

  static Future<List<File>> getRecentFiles() async {
    try {
      final appDir = await getAppDirectoryPath();
      final directory = Directory(appDir);

      if (!await directory.exists()) {
        return [];
      }

      final files = await directory
          .list()
          .where((entity) => entity is File && entity.path.endsWith('.pdf'))
          .cast<File>()
          .toList();

      // Sort by modification time (most recent first)
      files.sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));

      return files.take(10).toList(); // Return last 10 files
    } catch (e) {
      return [];
    }
  }

  static Future<String> getFileSize(File file) async {
    try {
      final bytes = await file.length();
      if (bytes < 1024) {
        return '$bytes B';
      } else if (bytes < 1024 * 1024) {
        return '${(bytes / 1024).toStringAsFixed(1)} KB';
      } else {
        return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
      }
    } catch (e) {
      return 'Unknown';
    }
  }

  static Future<Map<String, dynamic>> getFileInfo(File file) async {
    try {
      final stat = await file.stat();
      return {
        'name': file.path.split('/').last,
        'size': await getFileSize(file),
        'modified': stat.modified,
        'created': stat.changed,
      };
    } catch (e) {
      return {
        'name': file.path.split('/').last,
        'size': 'Unknown',
        'modified': null,
        'created': null,
      };
    }
  }

  static Future<void> copyToClipboard(String text) async {
    try {
      await Clipboard.setData(ClipboardData(text: text));
    } catch (e) {
      throw Exception('Error copying to clipboard: $e');
    }
  }

  static Future<File> saveTextAsFile(String text, String filename) async {
    try {
      final path = await getAppDirectoryPath();
      final file = File('$path/$filename');
      await file.writeAsString(text);
      return file;
    } catch (e) {
      throw Exception('Error saving text file: $e');
    }
  }
}
