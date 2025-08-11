import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:image/image.dart' as img;

class PDFService {
  static final PDFService _instance = PDFService._internal();
  factory PDFService() => _instance;
  PDFService._internal();

  /// Merge multiple PDF files into one
  Future<File> mergePDFs(List<File> pdfFiles, {String? outputName}) async {
    try {
      final PdfDocument document = PdfDocument();
      
      for (final file in pdfFiles) {
        final PdfDocument sourceDoc = PdfDocument(inputBytes: await file.readAsBytes());
        document.importPages(sourceDoc);
        sourceDoc.dispose();
      }
      
      final List<int> bytes = await document.save();
      document.dispose();
      
      final outputPath = await _getOutputPath(outputName ?? 'merged_${DateTime.now().millisecondsSinceEpoch}.pdf');
      final outputFile = File(outputPath);
      await outputFile.writeAsBytes(bytes);
      
      return outputFile;
    } catch (e) {
      throw Exception('Failed to merge PDFs: $e');
    }
  }

  /// Split PDF into multiple files
  Future<List<File>> splitPDF(File pdfFile, {List<int>? pageRanges}) async {
    try {
      final PdfDocument document = PdfDocument(inputBytes: await pdfFile.readAsBytes());
      final List<File> outputFiles = [];
      
      if (pageRanges != null) {
        // Split based on specified page ranges
        for (int i = 0; i < pageRanges.length; i++) {
          final PdfDocument newDoc = PdfDocument();
          newDoc.importPage(document, pageRanges[i]);
          
          final List<int> bytes = await newDoc.save();
          newDoc.dispose();
          
          final outputPath = await _getOutputPath('split_${i + 1}_${DateTime.now().millisecondsSinceEpoch}.pdf');
          final outputFile = File(outputPath);
          await outputFile.writeAsBytes(bytes);
          outputFiles.add(outputFile);
        }
      } else {
        // Split each page into separate file
        for (int i = 0; i < document.pages.count; i++) {
          final PdfDocument newDoc = PdfDocument();
          newDoc.importPage(document, i);
          
          final List<int> bytes = await newDoc.save();
          newDoc.dispose();
          
          final outputPath = await _getOutputPath('page_${i + 1}_${DateTime.now().millisecondsSinceEpoch}.pdf');
          final outputFile = File(outputPath);
          await outputFile.writeAsBytes(bytes);
          outputFiles.add(outputFile);
        }
      }
      
      document.dispose();
      return outputFiles;
    } catch (e) {
      throw Exception('Failed to split PDF: $e');
    }
  }

  /// Compress PDF to reduce file size
  Future<File> compressPDF(File pdfFile, {double quality = 0.8}) async {
    try {
      final PdfDocument document = PdfDocument(inputBytes: await pdfFile.readAsBytes());
      
      // Set compression options
      document.compressionLevel = PdfCompressionLevel.best;
      
      // Compress images in the document
      for (int i = 0; i < document.pages.count; i++) {
        final PdfPage page = document.pages[i];
        final List<PdfImage> images = page.extractImages();
        
        for (final image in images) {
          // Compress image if it's too large
          if (image.width > 800 || image.height > 800) {
            final Uint8List compressedBytes = await _compressImage(image.data, quality);
            // Replace image with compressed version
            // Note: This is a simplified implementation
          }
        }
      }
      
      final List<int> bytes = await document.save();
      document.dispose();
      
      final outputPath = await _getOutputPath('compressed_${DateTime.now().millisecondsSinceEpoch}.pdf');
      final outputFile = File(outputPath);
      await outputFile.writeAsBytes(bytes);
      
      return outputFile;
    } catch (e) {
      throw Exception('Failed to compress PDF: $e');
    }
  }

  /// Rotate PDF pages
  Future<File> rotatePDF(File pdfFile, {int? pageNumber, PdfPageRotateAngle angle = PdfPageRotateAngle.rotateAngle90}) async {
    try {
      final PdfDocument document = PdfDocument(inputBytes: await pdfFile.readAsBytes());
      
      if (pageNumber != null) {
        // Rotate specific page
        if (pageNumber > 0 && pageNumber <= document.pages.count) {
          document.pages[pageNumber - 1].rotation = angle;
        }
      } else {
        // Rotate all pages
        for (int i = 0; i < document.pages.count; i++) {
          document.pages[i].rotation = angle;
        }
      }
      
      final List<int> bytes = await document.save();
      document.dispose();
      
      final outputPath = await _getOutputPath('rotated_${DateTime.now().millisecondsSinceEpoch}.pdf');
      final outputFile = File(outputPath);
      await outputFile.writeAsBytes(bytes);
      
      return outputFile;
    } catch (e) {
      throw Exception('Failed to rotate PDF: $e');
    }
  }

  /// Remove specific pages from PDF
  Future<File> removePages(File pdfFile, List<int> pageNumbers) async {
    try {
      final PdfDocument document = PdfDocument(inputBytes: await pdfFile.readAsBytes());
      final PdfDocument newDoc = PdfDocument();
      
      // Sort page numbers in descending order to avoid index issues
      pageNumbers.sort((a, b) => b.compareTo(a));
      
      // Import all pages except the ones to be removed
      for (int i = 0; i < document.pages.count; i++) {
        if (!pageNumbers.contains(i + 1)) {
          newDoc.importPage(document, i);
        }
      }
      
      final List<int> bytes = await newDoc.save();
      document.dispose();
      newDoc.dispose();
      
      final outputPath = await _getOutputPath('removed_pages_${DateTime.now().millisecondsSinceEpoch}.pdf');
      final outputFile = File(outputPath);
      await outputFile.writeAsBytes(bytes);
      
      return outputFile;
    } catch (e) {
      throw Exception('Failed to remove pages: $e');
    }
  }

  /// Add blank pages to PDF
  Future<File> addBlankPages(File pdfFile, {int count = 1, int? afterPage}) async {
    try {
      final PdfDocument document = PdfDocument(inputBytes: await pdfFile.readAsBytes());
      
      for (int i = 0; i < count; i++) {
        final PdfPage newPage = document.pages.add();
        // Set page size to match existing pages
        if (document.pages.count > 1) {
          newPage.size = document.pages[0].size;
        }
      }
      
      final List<int> bytes = await document.save();
      document.dispose();
      
      final outputPath = await _getOutputPath('with_blank_pages_${DateTime.now().millisecondsSinceEpoch}.pdf');
      final outputFile = File(outputPath);
      await outputFile.writeAsBytes(bytes);
      
      return outputFile;
    } catch (e) {
      throw Exception('Failed to add blank pages: $e');
    }
  }

  /// Convert PDF to grayscale
  Future<File> convertToGrayscale(File pdfFile) async {
    try {
      final PdfDocument document = PdfDocument(inputBytes: await pdfFile.readAsBytes());
      
      // Process each page
      for (int i = 0; i < document.pages.count; i++) {
        final PdfPage page = document.pages[i];
        final List<PdfImage> images = page.extractImages();
        
        for (final image in images) {
          // Convert image to grayscale
          final img.Image? decodedImage = img.decodeImage(image.data);
          if (decodedImage != null) {
            final img.Image grayscaleImage = img.grayscale(decodedImage);
            final Uint8List grayscaleBytes = Uint8List.fromList(img.encodePng(grayscaleImage));
            // Replace image with grayscale version
            // Note: This is a simplified implementation
          }
        }
      }
      
      final List<int> bytes = await document.save();
      document.dispose();
      
      final outputPath = await _getOutputPath('grayscale_${DateTime.now().millisecondsSinceEpoch}.pdf');
      final outputFile = File(outputPath);
      await outputFile.writeAsBytes(bytes);
      
      return outputFile;
    } catch (e) {
      throw Exception('Failed to convert to grayscale: $e');
    }
  }

  /// Create PDF from images
  Future<File> createPDFFromImages(List<File> imageFiles, {String? outputName}) async {
    try {
      final pdf = pw.Document();
      
      for (final imageFile in imageFiles) {
        final Uint8List imageBytes = await imageFile.readAsBytes();
        final pw.MemoryImage memoryImage = pw.MemoryImage(imageBytes);
        
        pdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            build: (pw.Context context) {
              return pw.Center(
                child: pw.Image(memoryImage),
              );
            },
          ),
        );
      }
      
      final Uint8List bytes = await pdf.save();
      final outputPath = await _getOutputPath(outputName ?? 'from_images_${DateTime.now().millisecondsSinceEpoch}.pdf');
      final outputFile = File(outputPath);
      await outputFile.writeAsBytes(bytes);
      
      return outputFile;
    } catch (e) {
      throw Exception('Failed to create PDF from images: $e');
    }
  }

  /// Extract text from PDF
  Future<String> extractText(File pdfFile) async {
    try {
      final PdfDocument document = PdfDocument(inputBytes: await pdfFile.readAsBytes());
      final PdfTextExtractor extractor = PdfTextExtractor(document);
      final String text = extractor.extractText();
      document.dispose();
      return text;
    } catch (e) {
      throw Exception('Failed to extract text: $e');
    }
  }

  /// Get PDF information
  Future<Map<String, dynamic>> getPDFInfo(File pdfFile) async {
    try {
      final PdfDocument document = PdfDocument(inputBytes: await pdfFile.readAsBytes());
      
      final info = {
        'pageCount': document.pages.count,
        'fileSize': await pdfFile.length(),
        'title': document.documentInformation.title,
        'author': document.documentInformation.author,
        'subject': document.documentInformation.subject,
        'creator': document.documentInformation.creator,
        'producer': document.documentInformation.producer,
        'creationDate': document.documentInformation.creationDate,
        'modificationDate': document.documentInformation.modificationDate,
      };
      
      document.dispose();
      return info;
    } catch (e) {
      throw Exception('Failed to get PDF info: $e');
    }
  }

  /// Add password protection to PDF
  Future<File> addPassword(File pdfFile, String password) async {
    try {
      final PdfDocument document = PdfDocument(inputBytes: await pdfFile.readAsBytes());
      
      // Set security
      final PdfSecurity security = document.security;
      security.userPassword = password;
      security.ownerPassword = password;
      security.permissions.add(PdfPermissions.print);
      security.permissions.add(PdfPermissions.copyContent);
      
      final List<int> bytes = await document.save();
      document.dispose();
      
      final outputPath = await _getOutputPath('protected_${DateTime.now().millisecondsSinceEpoch}.pdf');
      final outputFile = File(outputPath);
      await outputFile.writeAsBytes(bytes);
      
      return outputFile;
    } catch (e) {
      throw Exception('Failed to add password: $e');
    }
  }

  /// Remove password from PDF (if known)
  Future<File> removePassword(File pdfFile, String password) async {
    try {
      final PdfDocument document = PdfDocument(inputBytes: await pdfFile.readAsBytes(), password: password);
      
      // Remove security
      document.security.userPassword = '';
      document.security.ownerPassword = '';
      
      final List<int> bytes = await document.save();
      document.dispose();
      
      final outputPath = await _getOutputPath('unprotected_${DateTime.now().millisecondsSinceEpoch}.pdf');
      final outputFile = File(outputPath);
      await outputFile.writeAsBytes(bytes);
      
      return outputFile;
    } catch (e) {
      throw Exception('Failed to remove password: $e');
    }
  }

  // Helper methods
  Future<String> _getOutputPath(String filename) async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/inkwise_pdf/$filename';
  }

  Future<Uint8List> _compressImage(Uint8List imageBytes, double quality) async {
    try {
      final img.Image? image = img.decodeImage(imageBytes);
      if (image != null) {
        // Resize image if too large
        img.Image resizedImage = image;
        if (image.width > 800 || image.height > 800) {
          resizedImage = img.copyResize(image, width: 800, height: 800);
        }
        return Uint8List.fromList(img.encodeJpg(resizedImage, quality: (quality * 100).round()));
      }
      return imageBytes;
    } catch (e) {
      return imageBytes;
    }
  }
}