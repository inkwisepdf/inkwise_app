import 'dart:io';
import 'package:path_provider/path_provider.dart';

class FileService {
  static Future<String> getAppDirectoryPath() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  static Future<File> writeFile(String filename, List<int> bytes) async {
    final path = await getAppDirectoryPath();
    final file = File('$path/$filename');
    return file.writeAsBytes(bytes, flush: true);
  }

  static Future<File?> pickFile() async {
    // Placeholder for file picker logic using file_picker or similar
    return null;
  }

  static Future<void> deleteFile(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
    }
  }
}
