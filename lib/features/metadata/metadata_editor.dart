import 'package:pdf/widgets.dart' as pw;

class MetadataEditor {
  static pw.Document updateMetadata(
      pw.Document doc, String title, String author) {
    return pw.Document(
      author: author,
      title: title,
      creator: 'Inkwise PDF',
      producer: 'Inkwise PDF Engine',
    );
  }
}
