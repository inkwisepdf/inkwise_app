import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

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