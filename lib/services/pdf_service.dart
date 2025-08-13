import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart' as pdf_package;
import 'package:pdf/widgets.dart' as pw;
import 'package:syncfusion_flutter_pdf/pdf.dart' as sf_pdf;
import 'package:pdf_render/pdf_render.dart' as pdf_render;
import 'package:image/image.dart' as img;
import 'package:flutter/material.dart';
import 'package:inkwise_pdf/services/performance_service.dart';

class PDFService {
  static final PDFService _instance = PDFService._internal();
  factory PDFService() => _instance;
  PDFService._internal();

  /// Merge multiple PDF files into one
  Future<File> mergePDFs(List<File> pdfFiles, {String? outputName}) async {
    return await PerformanceService().withOperationLimit(() async {
      try {
        PerformanceService().startOperation('pdf_merge');

        final sf_pdf.PdfDocument document = sf_pdf.PdfDocument();

        // Process files in parallel for better performance
        final futures = pdfFiles.map((file) async {
          final cacheKey = 'pdf_merge_${file.path}_${file.lastModifiedSync().millisecondsSinceEpoch}';
          final cachedBytes = PerformanceService().getFromCache<Uint8List>(cacheKey);

          if (cachedBytes != null) {
            return sf_pdf.PdfDocument(inputBytes: cachedBytes);
          }

          final bytes = await file.readAsBytes();
          PerformanceService().setCache(cacheKey, bytes);
          return sf_pdf.PdfDocument(inputBytes: bytes);
        });

        final documents = await Future.wait(futures);

        for (final sourceDoc in documents) {
          // Import all pages from source document
          for (int i = 0; i < sourceDoc.pages.count; i++) {
            document.pages.add().graphics.drawPdfTemplate(
              sourceDoc.pages[i].createTemplate(),
              Offset.zero,
            );
          }
          sourceDoc.dispose();
        }

        final List<int> bytes = await document.save();
        document.dispose();

        final outputPath = await _getOutputPath(outputName ?? 'merged_${DateTime.now().millisecondsSinceEpoch}.pdf');
        final outputFile = File(outputPath);
        await outputFile.writeAsBytes(bytes);

        PerformanceService().endOperation('pdf_merge');
        return outputFile;
      } catch (e) {
        PerformanceService().endOperation('pdf_merge');
        throw Exception('Failed to merge PDFs: $e');
      }
    });
  }

  /// Split PDF into multiple files
  Future<List<File>> splitPDF(File pdfFile, {List<int>? pageRanges}) async {
    return await PerformanceService().withOperationLimit(() async {
      try {
        PerformanceService().startOperation('pdf_split');

        // Check cache for document
        final cacheKey = 'pdf_split_${pdfFile.path}_${pdfFile.lastModifiedSync().millisecondsSinceEpoch}';
        final cachedBytes = PerformanceService().getFromCache<Uint8List>(cacheKey);

        final sf_pdf.PdfDocument document = sf_pdf.PdfDocument(
            inputBytes: cachedBytes ?? await pdfFile.readAsBytes()
        );

        if (cachedBytes == null) {
          PerformanceService().setCache(cacheKey, await pdfFile.readAsBytes());
        }

        final List<File> outputFiles = [];

        if (pageRanges != null) {
          // Split based on specified page ranges - process in parallel
          final futures = pageRanges.toList().asMap().entries.map((entry) async {
            final i = entry.key;
            final pageIndex = entry.value;

            final sf_pdf.PdfDocument newDoc = sf_pdf.PdfDocument();
            newDoc.pages.add().graphics.drawPdfTemplate(
              document.pages[pageIndex].createTemplate(),
              Offset.zero,
            );

            final List<int> bytes = await newDoc.save();
            newDoc.dispose();

            final outputPath = await _getOutputPath('split_${i + 1}_${DateTime.now().millisecondsSinceEpoch}.pdf');
            final outputFile = File(outputPath);
            await outputFile.writeAsBytes(bytes);
            return outputFile;
          });

          outputFiles.addAll(await Future.wait(futures));
        } else {
          // Split each page into separate file - process in parallel
          final futures = List.generate(document.pages.count, (i) async {
            final sf_pdf.PdfDocument newDoc = sf_pdf.PdfDocument();
            newDoc.pages.add().graphics.drawPdfTemplate(
              document.pages[i].createTemplate(),
              Offset.zero,
            );

            final List<int> bytes = await newDoc.save();
            newDoc.dispose();

            final outputPath = await _getOutputPath('page_${i + 1}_${DateTime.now().millisecondsSinceEpoch}.pdf');
            final outputFile = File(outputPath);
            await outputFile.writeAsBytes(bytes);
            return outputFile;
          });

          outputFiles.addAll(await Future.wait(futures));
        }

        document.dispose();
        PerformanceService().endOperation('pdf_split');
        return outputFiles;
      } catch (e) {
        PerformanceService().endOperation('pdf_split');
        throw Exception('Failed to split PDF: $e');
      }
    });
  }

  /// Compress PDF to reduce file size
  Future<File> compressPDF(File pdfFile, {double quality = 0.8}) async {
    return await PerformanceService().withOperationLimit(() async {
      try {
        PerformanceService().startOperation('pdf_compress');

        // Check cache for document
        final cacheKey = 'pdf_compress_${pdfFile.path}_${pdfFile.lastModifiedSync().millisecondsSinceEpoch}_$quality';
        final cachedBytes = PerformanceService().getFromCache<Uint8List>(cacheKey);

        if (cachedBytes != null) {
          final outputPath = await _getOutputPath('compressed_${DateTime.now().millisecondsSinceEpoch}.pdf');
          final outputFile = File(outputPath);
          await outputFile.writeAsBytes(cachedBytes);
          PerformanceService().endOperation('pdf_compress');
          return outputFile;
        }

        final sf_pdf.PdfDocument document = sf_pdf.PdfDocument(inputBytes: await pdfFile.readAsBytes());

        // Set compression options
        document.compressionLevel = sf_pdf.PdfCompressionLevel.best;

        // Process pages to compress images
        final pageFutures = List.generate(document.pages.count, (i) async {
          final sf_pdf.PdfPage page = document.pages[i];

          // Note: Direct image extraction and replacement in Syncfusion is complex
          // For now, we'll rely on the document-level compression
          // In a real implementation, you might need to convert to images and back
          // or use other techniques for more aggressive compression

          return page;
        });

        await Future.wait(pageFutures);

        final List<int> bytes = await document.save();
        document.dispose();

        // Cache the compressed result
        PerformanceService().setCache(cacheKey, bytes);

        final outputPath = await _getOutputPath('compressed_${DateTime.now().millisecondsSinceEpoch}.pdf');
        final outputFile = File(outputPath);
        await outputFile.writeAsBytes(bytes);

        PerformanceService().endOperation('pdf_compress');
        return outputFile;
      } catch (e) {
        PerformanceService().endOperation('pdf_compress');
        throw Exception('Failed to compress PDF: $e');
      }
    });
  }

  /// Remove specific pages from PDF
  Future<File> removePages(File pdfFile, List<int> pageNumbers) async {
    try {
      final sf_pdf.PdfDocument document = sf_pdf.PdfDocument(inputBytes: await pdfFile.readAsBytes());
      final sf_pdf.PdfDocument newDoc = sf_pdf.PdfDocument();

      // Sort page numbers in descending order to avoid index issues
      pageNumbers.sort((a, b) => b.compareTo(a));

      // Import all pages except the ones to be removed
      for (int i = 0; i < document.pages.count; i++) {
        if (!pageNumbers.contains(i + 1)) {
          newDoc.pages.add().graphics.drawPdfTemplate(
            document.pages[i].createTemplate(),
            Offset.zero,
          );
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
      final sf_pdf.PdfDocument document = sf_pdf.PdfDocument(inputBytes: await pdfFile.readAsBytes());

      for (int i = 0; i < count; i++) {
        document.pages.add();
        // Note: In Syncfusion, page size is typically set automatically
        // If you need specific size, you can set it during page creation
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

  /// Create PDF from images
  Future<File> createPDFFromImages(List<File> imageFiles, {String? outputName}) async {
    try {
      final pdf = pw.Document();

      for (final imageFile in imageFiles) {
        final Uint8List imageBytes = await imageFile.readAsBytes();
        final pw.MemoryImage memoryImage = pw.MemoryImage(imageBytes);

        pdf.addPage(
          pw.Page(
            pageFormat: pdf_package.PdfPageFormat.a4,
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
      final sf_pdf.PdfDocument document = sf_pdf.PdfDocument(inputBytes: await pdfFile.readAsBytes());
      final sf_pdf.PdfTextExtractor extractor = sf_pdf.PdfTextExtractor(document);
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
      final sf_pdf.PdfDocument document = sf_pdf.PdfDocument(inputBytes: await pdfFile.readAsBytes());

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
      final sf_pdf.PdfDocument document = sf_pdf.PdfDocument(inputBytes: await pdfFile.readAsBytes());

      // Set security
      final sf_pdf.PdfSecurity security = document.security;
      security.userPassword = password;
      security.ownerPassword = password;
      security.permissions.addAll([
        sf_pdf.PdfPermissionsFlags.print,
        sf_pdf.PdfPermissionsFlags.copyContent,
      ]);

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
      final sf_pdf.PdfDocument document = sf_pdf.PdfDocument(inputBytes: await pdfFile.readAsBytes(), password: password);

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

  /// Rotate PDF pages
  Future<File> rotatePDF(File pdfFile, {int? pageNumber, sf_pdf.PdfPageRotateAngle? angle}) async {
    try {
      final sf_pdf.PdfDocument document = sf_pdf.PdfDocument(inputBytes: await pdfFile.readAsBytes());
      final rotationAngle = angle ?? sf_pdf.PdfPageRotateAngle.rotateAngle90;

      if (pageNumber != null) {
        // Rotate specific page
        if (pageNumber > 0 && pageNumber <= document.pages.count) {
          final sf_pdf.PdfPage page = document.pages[pageNumber - 1];
          page.rotation = rotationAngle;
        }
      } else {
        // Rotate all pages
        for (int i = 0; i < document.pages.count; i++) {
          final sf_pdf.PdfPage page = document.pages[i];
          page.rotation = rotationAngle;
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

  /// Add text watermark to PDF
  Future<File> addTextWatermark(
      File pdfFile,
      String text, {
        String position = 'center',
        double opacity = 0.5,
        double rotation = 0.0,
        double fontSize = 24.0,
        Color color = Colors.red,
        String fontFamily = 'Arial',
      }) async {
    try {
      final sf_pdf.PdfDocument document = sf_pdf.PdfDocument(inputBytes: await pdfFile.readAsBytes());

      for (int i = 0; i < document.pages.count; i++) {
        final sf_pdf.PdfPage page = document.pages[i];
        final sf_pdf.PdfGraphics graphics = page.graphics;

        // Calculate position
        double x, y;
        final sf_pdf.PdfFont font = sf_pdf.PdfStandardFont(sf_pdf.PdfFontFamily.helvetica, fontSize);
        final sf_pdf.PdfStringFormat format = sf_pdf.PdfStringFormat();
        final Size textSize = font.measureString(text, format: format);

        switch (position) {
          case 'center':
            x = (page.size.width - textSize.width) / 2;
            y = (page.size.height - textSize.height) / 2;
            break;
          case 'top-left':
            x = 50;
            y = 50;
            break;
          case 'top-right':
            x = page.size.width - textSize.width - 50;
            y = 50;
            break;
          case 'bottom-left':
            x = 50;
            y = page.size.height - textSize.height - 50;
            break;
          case 'bottom-right':
            x = page.size.width - textSize.width - 50;
            y = page.size.height - textSize.height - 50;
            break;
          default:
            x = (page.size.width - textSize.width) / 2;
            y = (page.size.height - textSize.height) / 2;
        }

        // Apply rotation and opacity
        graphics.save();
        graphics.translateTransform(x + textSize.width / 2, y + textSize.height / 2);
        graphics.rotateTransform(rotation);
        graphics.translateTransform(-(x + textSize.width / 2), -(y + textSize.height / 2));

        // Draw watermark
        final sf_pdf.PdfBrush brush = sf_pdf.PdfSolidBrush(sf_pdf.PdfColor(
          color.red,
          color.green,
          color.blue,
        ));

        // Apply opacity using transparency
        graphics.setTransparency(opacity);
        graphics.drawString(text, font, brush: brush, bounds: Rect.fromLTWH(x, y, textSize.width, textSize.height), format: format);
        graphics.restore();
      }

      final List<int> bytes = await document.save();
      document.dispose();

      final outputPath = await _getOutputPath('watermarked_${DateTime.now().millisecondsSinceEpoch}.pdf');
      final outputFile = File(outputPath);
      await outputFile.writeAsBytes(bytes);

      return outputFile;
    } catch (e) {
      throw Exception('Failed to add text watermark: $e');
    }
  }

  /// Add image watermark to PDF
  Future<File> addImageWatermark(
      File pdfFile,
      File imageFile, {
        String position = 'center',
        double opacity = 0.5,
        double rotation = 0.0,
      }) async {
    try {
      final sf_pdf.PdfDocument document = sf_pdf.PdfDocument(inputBytes: await pdfFile.readAsBytes());
      final Uint8List imageBytes = await imageFile.readAsBytes();
      final sf_pdf.PdfBitmap image = sf_pdf.PdfBitmap(imageBytes);

      for (int i = 0; i < document.pages.count; i++) {
        final sf_pdf.PdfPage page = document.pages[i];
        final sf_pdf.PdfGraphics graphics = page.graphics;

        // Calculate position
        double x, y;
        final double imageWidth = 200.0; // Default watermark size
        final double imageHeight = 200.0; // Default watermark size

        switch (position) {
          case 'center':
            x = (page.size.width - imageWidth) / 2;
            y = (page.size.height - imageHeight) / 2;
            break;
          case 'top-left':
            x = 50;
            y = 50;
            break;
          case 'top-right':
            x = page.size.width - imageWidth - 50;
            y = 50;
            break;
          case 'bottom-left':
            x = 50;
            y = page.size.height - imageHeight - 50;
            break;
          case 'bottom-right':
            x = page.size.width - imageWidth - 50;
            y = page.size.height - imageHeight - 50;
            break;
          default:
            x = (page.size.width - imageWidth) / 2;
            y = (page.size.height - imageHeight) / 2;
        }

        // Apply rotation and opacity
        graphics.save();
        graphics.translateTransform(x + imageWidth / 2, y + imageHeight / 2);
        graphics.rotateTransform(rotation);
        graphics.translateTransform(-(x + imageWidth / 2), -(y + imageHeight / 2));

        // Draw watermark with opacity
        graphics.setTransparency(opacity);
        graphics.drawImage(image, Rect.fromLTWH(x, y, imageWidth, imageHeight));
        graphics.restore();
      }

      final List<int> bytes = await document.save();
      document.dispose();

      final outputPath = await _getOutputPath('watermarked_${DateTime.now().millisecondsSinceEpoch}.pdf');
      final outputFile = File(outputPath);
      await outputFile.writeAsBytes(bytes);

      return outputFile;
    } catch (e) {
      throw Exception('Failed to add image watermark: $e');
    }
  }

  /// Convert PDF to images
  Future<List<File>> convertPDFToImages(
      File pdfFile, {
        String format = 'png',
        double quality = 0.8,
        double scale = 2.0,
        List<int>? pageNumbers,
      }) async {
    try {
      final document = await pdf_render.PdfDocument.openData(await pdfFile.readAsBytes());
      final List<File> imageFiles = [];

      final pagesToConvert = pageNumbers ?? List.generate(document.pageCount, (i) => i + 1);

      for (final pageNum in pagesToConvert) {
        if (pageNum > 0 && pageNum <= document.pageCount) {
          final page = await document.getPage(pageNum);

          // Render page to image
          final pageImage = await page.render(
            width: (page.width * scale).round(),
            height: (page.height * scale).round(),
          );

          // Convert to bytes
          final imageBytes = await pageImage.createImageIfNotAvailable();
          final byteData = await imageBytes.toByteData(format: ui.ImageByteFormat.png);
          final bytes = byteData!.buffer.asUint8List();

          // Save image file
          final outputPath = await _getOutputPath('page_${pageNum}_${DateTime.now().millisecondsSinceEpoch}.$format');
          final outputFile = File(outputPath);
          await outputFile.writeAsBytes(bytes);
          imageFiles.add(outputFile);

          // PdfPage from pdf_render doesn't have a close method
        }
      }

      document.dispose();
      return imageFiles;
    } catch (e) {
      throw Exception('Failed to convert PDF to images: $e');
    }
  }

  /// Convert PDF to grayscale
  Future<File> convertToGrayscale(
      File pdfFile, {
        double threshold = 0.5,
        bool preserveText = true,
        bool enhanceContrast = false,
        List<int>? pageNumbers,
      }) async {
    try {
      // First convert to images, process them, then convert back to PDF
      final imageFiles = await convertPDFToImages(pdfFile, pageNumbers: pageNumbers);
      final processedImageFiles = <File>[];

      for (final imageFile in imageFiles) {
        final imageBytes = await imageFile.readAsBytes();
        final img.Image? image = img.decodeImage(imageBytes);

        if (image != null) {
          // Convert to grayscale
          img.Image grayscaleImage = img.grayscale(image);

          // Apply threshold if needed (custom implementation)
          if (threshold != 0.5) {
            grayscaleImage = _applyThreshold(grayscaleImage, threshold);
          }

          // Enhance contrast if requested
          if (enhanceContrast) {
            grayscaleImage = img.contrast(grayscaleImage, contrast: 150);
          }

          // Save processed image
          final processedBytes = Uint8List.fromList(img.encodePng(grayscaleImage));
          final processedPath = await _getOutputPath('processed_${DateTime.now().millisecondsSinceEpoch}_${processedImageFiles.length}.png');
          final processedFile = File(processedPath);
          await processedFile.writeAsBytes(processedBytes);
          processedImageFiles.add(processedFile);
        }

        // Clean up original image file
        await imageFile.delete();
      }

      // Convert processed images back to PDF
      final outputFile = await createPDFFromImages(processedImageFiles, outputName: 'grayscale_${DateTime.now().millisecondsSinceEpoch}.pdf');

      // Clean up processed image files
      for (final file in processedImageFiles) {
        await file.delete();
      }

      return outputFile;
    } catch (e) {
      throw Exception('Failed to convert to grayscale: $e');
    }
  }

  // Helper methods
  Future<String> _getOutputPath(String filename) async {
    final directory = await getApplicationDocumentsDirectory();
    final appDir = Directory('${directory.path}/inkwise_pdf');
    if (!await appDir.exists()) {
      await appDir.create(recursive: true);
    }
    return '${appDir.path}/$filename';
  }

  // Note: _compressImage method removed as it was unused

  img.Image _applyThreshold(img.Image image, double threshold) {
    final int thresholdValue = (threshold * 255).round();
    final img.Image result = img.Image.from(image);

    for (int y = 0; y < result.height; y++) {
      for (int x = 0; x < result.width; x++) {
        final pixel = result.getPixel(x, y);
        final gray = img.getLuminance(pixel);
        final newValue = gray > thresholdValue ? 255 : 0;
        result.setPixel(x, y, img.ColorRgba8(newValue, newValue, newValue, 255));
      }
    }

    return result;
  }
}