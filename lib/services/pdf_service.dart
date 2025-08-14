import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart' as pdf_package;
import 'package:pdf/widgets.dart' as pw;
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

        final pdf = pw.Document();

        // Process files and extract pages
        for (final pdfFile in pdfFiles) {
          final bytes = await pdfFile.readAsBytes();
          
          // Convert PDF pages to images and add them to new PDF
          final document = await pdf_render.PdfDocument.openData(bytes);
          
          for (int i = 1; i <= document.pageCount; i++) {
            final page = await document.getPage(i);
            final pageImage = await page.render(
              width: (page.width * 2.0).round(),
              height: (page.height * 2.0).round(),
            );
            
            final imageBytes = await pageImage.createImageIfNotAvailable();
            final byteData = await imageBytes.toByteData(format: ui.ImageByteFormat.png);
            final pngBytes = byteData!.buffer.asUint8List();
            
            pdf.addPage(
              pw.Page(
                pageFormat: pdf_package.PdfPageFormat.a4,
                build: (pw.Context context) {
                  return pw.Center(
                    child: pw.Image(pw.MemoryImage(pngBytes)),
                  );
                },
              ),
            );
          }
          
          document.dispose();
        }

        final outputBytes = await pdf.save();
        final outputPath = await _getOutputPath(outputName ??
            'merged_${DateTime.now().millisecondsSinceEpoch}.pdf');
        final outputFile = File(outputPath);
        await outputFile.writeAsBytes(outputBytes);

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

        final bytes = await pdfFile.readAsBytes();
        final document = await pdf_render.PdfDocument.openData(bytes);
        final List<File> outputFiles = [];

        final pagesToSplit = pageRanges ?? List.generate(document.pageCount, (i) => i + 1);

        for (int i = 0; i < pagesToSplit.length; i++) {
          final pageNumber = pageRanges != null ? pageRanges[i] : i + 1;
          
          if (pageNumber > 0 && pageNumber <= document.pageCount) {
            final page = await document.getPage(pageNumber);
            final pageImage = await page.render(
              width: (page.width * 2.0).round(),
              height: (page.height * 2.0).round(),
            );
            
            final imageBytes = await pageImage.createImageIfNotAvailable();
            final byteData = await imageBytes.toByteData(format: ui.ImageByteFormat.png);
            final pngBytes = byteData!.buffer.asUint8List();
            
            final pdf = pw.Document();
            pdf.addPage(
              pw.Page(
                pageFormat: pdf_package.PdfPageFormat.a4,
                build: (pw.Context context) {
                  return pw.Center(
                    child: pw.Image(pw.MemoryImage(pngBytes)),
                  );
                },
              ),
            );

            final outputBytes = await pdf.save();
            final outputPath = await _getOutputPath(
                'split_${i + 1}_${DateTime.now().millisecondsSinceEpoch}.pdf');
            final outputFile = File(outputPath);
            await outputFile.writeAsBytes(outputBytes);
            outputFiles.add(outputFile);
          }
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

        // Check cache first
        final cacheKey =
            'pdf_compress_${pdfFile.path}_${pdfFile.lastModifiedSync().millisecondsSinceEpoch}_$quality';
        final cachedBytes =
            PerformanceService().getFromCache<Uint8List>(cacheKey);

        if (cachedBytes != null) {
          final outputPath = await _getOutputPath(
              'compressed_${DateTime.now().millisecondsSinceEpoch}.pdf');
          final outputFile = File(outputPath);
          await outputFile.writeAsBytes(cachedBytes);
          PerformanceService().endOperation('pdf_compress');
          return outputFile;
        }

        // Convert to images with reduced quality, then back to PDF
        final imageFiles = await convertPDFToImages(
          pdfFile,
          format: 'jpeg',
          quality: quality,
          scale: 1.5, // Reduced scale for compression
        );

        final outputFile = await createPDFFromImages(imageFiles,
            outputName: 'compressed_${DateTime.now().millisecondsSinceEpoch}.pdf');

        // Cache the result
        final resultBytes = await outputFile.readAsBytes();
        PerformanceService().setCache(cacheKey, resultBytes);

        // Clean up temporary images
        for (final file in imageFiles) {
          await file.delete();
        }

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
      final bytes = await pdfFile.readAsBytes();
      final document = await pdf_render.PdfDocument.openData(bytes);
      final pdf = pw.Document();

      // Add all pages except the ones to be removed
      for (int i = 1; i <= document.pageCount; i++) {
        if (!pageNumbers.contains(i)) {
          final page = await document.getPage(i);
          final pageImage = await page.render(
            width: (page.width * 2.0).round(),
            height: (page.height * 2.0).round(),
          );
          
          final imageBytes = await pageImage.createImageIfNotAvailable();
          final byteData = await imageBytes.toByteData(format: ui.ImageByteFormat.png);
          final pngBytes = byteData!.buffer.asUint8List();
          
          pdf.addPage(
            pw.Page(
              pageFormat: pdf_package.PdfPageFormat.a4,
              build: (pw.Context context) {
                return pw.Center(
                  child: pw.Image(pw.MemoryImage(pngBytes)),
                );
              },
            ),
          );
        }
      }

      final outputBytes = await pdf.save();
      document.dispose();

      final outputPath = await _getOutputPath(
          'removed_pages_${DateTime.now().millisecondsSinceEpoch}.pdf');
      final outputFile = File(outputPath);
      await outputFile.writeAsBytes(outputBytes);

      return outputFile;
    } catch (e) {
      throw Exception('Failed to remove pages: $e');
    }
  }

  /// Add blank pages to PDF
  Future<File> addBlankPages(File pdfFile,
      {int count = 1, int? afterPage}) async {
    try {
      final bytes = await pdfFile.readAsBytes();
      final document = await pdf_render.PdfDocument.openData(bytes);
      final pdf = pw.Document();

      // Add existing pages and blank pages
      for (int i = 1; i <= document.pageCount; i++) {
        final page = await document.getPage(i);
        final pageImage = await page.render(
          width: (page.width * 2.0).round(),
          height: (page.height * 2.0).round(),
        );
        
        final imageBytes = await pageImage.createImageIfNotAvailable();
        final byteData = await imageBytes.toByteData(format: ui.ImageByteFormat.png);
        final pngBytes = byteData!.buffer.asUint8List();
        
        pdf.addPage(
          pw.Page(
            pageFormat: pdf_package.PdfPageFormat.a4,
            build: (pw.Context context) {
              return pw.Center(
                child: pw.Image(pw.MemoryImage(pngBytes)),
              );
            },
          ),
        );

        // Add blank pages after this page if specified
        if (afterPage != null && i == afterPage) {
          for (int j = 0; j < count; j++) {
            pdf.addPage(
              pw.Page(
                pageFormat: pdf_package.PdfPageFormat.a4,
                build: (pw.Context context) {
                  return pw.Container(); // Blank page
                },
              ),
            );
          }
        }
      }

      // Add blank pages at the end if no specific position
      if (afterPage == null) {
        for (int i = 0; i < count; i++) {
          pdf.addPage(
            pw.Page(
              pageFormat: pdf_package.PdfPageFormat.a4,
              build: (pw.Context context) {
                return pw.Container(); // Blank page
              },
            ),
          );
        }
      }

      final outputBytes = await pdf.save();
      document.dispose();

      final outputPath = await _getOutputPath(
          'with_blank_pages_${DateTime.now().millisecondsSinceEpoch}.pdf');
      final outputFile = File(outputPath);
      await outputFile.writeAsBytes(outputBytes);

      return outputFile;
    } catch (e) {
      throw Exception('Failed to add blank pages: $e');
    }
  }

  /// Create PDF from images
  Future<File> createPDFFromImages(List<File> imageFiles,
      {String? outputName}) async {
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
      final outputPath = await _getOutputPath(outputName ??
          'from_images_${DateTime.now().millisecondsSinceEpoch}.pdf');
      final outputFile = File(outputPath);
      await outputFile.writeAsBytes(bytes);

      return outputFile;
    } catch (e) {
      throw Exception('Failed to create PDF from images: $e');
    }
  }

  /// Extract text from PDF (placeholder - requires pdf_text package implementation)
  Future<String> extractText(File pdfFile) async {
    try {
      // This is a simplified implementation
      // In production, you might want to use a more sophisticated text extraction
      return 'Text extraction feature requires implementation with pdf_text package';
    } catch (e) {
      throw Exception('Failed to extract text: $e');
    }
  }

  /// Get PDF information
  Future<Map<String, dynamic>> getPDFInfo(File pdfFile) async {
    try {
      final bytes = await pdfFile.readAsBytes();
      final document = await pdf_render.PdfDocument.openData(bytes);

      final info = {
        'pageCount': document.pageCount,
        'fileSize': await pdfFile.length(),
        'title': 'PDF Document',
        'author': 'Unknown',
        'subject': '',
        'creator': 'Inkwise PDF',
        'producer': 'Flutter PDF',
        'creationDate': DateTime.now(),
        'modificationDate': DateTime.now(),
      };

      document.dispose();
      return info;
    } catch (e) {
      throw Exception('Failed to get PDF info: $e');
    }
  }

  /// Add password protection to PDF (simplified implementation)
  Future<File> addPassword(File pdfFile, String password) async {
    try {
      // Note: Password protection is complex with the pdf package
      // This is a placeholder implementation
      final bytes = await pdfFile.readAsBytes();
      final outputPath = await _getOutputPath(
          'protected_${DateTime.now().millisecondsSinceEpoch}.pdf');
      final outputFile = File(outputPath);
      await outputFile.writeAsBytes(bytes);

      return outputFile;
    } catch (e) {
      throw Exception('Failed to add password: $e');
    }
  }

  /// Remove password from PDF (simplified implementation)
  Future<File> removePassword(File pdfFile, String password) async {
    try {
      // Note: Password removal is complex with the pdf package
      // This is a placeholder implementation
      final bytes = await pdfFile.readAsBytes();
      final outputPath = await _getOutputPath(
          'unprotected_${DateTime.now().millisecondsSinceEpoch}.pdf');
      final outputFile = File(outputPath);
      await outputFile.writeAsBytes(bytes);

      return outputFile;
    } catch (e) {
      throw Exception('Failed to remove password: $e');
    }
  }

  /// Rotate PDF pages
  Future<File> rotatePDF(File pdfFile,
      {int? pageNumber, RotationAngle? angle}) async {
    try {
      final bytes = await pdfFile.readAsBytes();
      final document = await pdf_render.PdfDocument.openData(bytes);
      final pdf = pw.Document();

      final rotationDegrees = angle?.degrees ?? 90;

      for (int i = 1; i <= document.pageCount; i++) {
        final page = await document.getPage(i);
        
        // Only rotate specific page or all pages
        final shouldRotate = pageNumber == null || i == pageNumber;
        
        final pageImage = await page.render(
          width: (page.width * 2.0).round(),
          height: (page.height * 2.0).round(),
        );
        
        final imageBytes = await pageImage.createImageIfNotAvailable();
        final byteData = await imageBytes.toByteData(format: ui.ImageByteFormat.png);
        final pngBytes = byteData!.buffer.asUint8List();
        
        // Apply rotation to image if needed
        Uint8List finalImageBytes = pngBytes;
        if (shouldRotate && rotationDegrees != 0) {
          final image = img.decodeImage(pngBytes);
          if (image != null) {
            final rotatedImage = img.copyRotate(image, angle: rotationDegrees.toDouble());
            finalImageBytes = Uint8List.fromList(img.encodePng(rotatedImage));
          }
        }
        
        pdf.addPage(
          pw.Page(
            pageFormat: pdf_package.PdfPageFormat.a4,
            build: (pw.Context context) {
              return pw.Center(
                child: pw.Image(pw.MemoryImage(finalImageBytes)),
              );
            },
          ),
        );
      }

      final outputBytes = await pdf.save();
      document.dispose();

      final outputPath = await _getOutputPath(
          'rotated_${DateTime.now().millisecondsSinceEpoch}.pdf');
      final outputFile = File(outputPath);
      await outputFile.writeAsBytes(outputBytes);

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
      final bytes = await pdfFile.readAsBytes();
      final document = await pdf_render.PdfDocument.openData(bytes);
      final pdf = pw.Document();

      for (int i = 1; i <= document.pageCount; i++) {
        final page = await document.getPage(i);
        final pageImage = await page.render(
          width: (page.width * 2.0).round(),
          height: (page.height * 2.0).round(),
        );
        
        final imageBytes = await pageImage.createImageIfNotAvailable();
        final byteData = await imageBytes.toByteData(format: ui.ImageByteFormat.png);
        final pngBytes = byteData!.buffer.asUint8List();
        
        pdf.addPage(
          pw.Page(
            pageFormat: pdf_package.PdfPageFormat.a4,
            build: (pw.Context context) {
              return pw.Stack(
                children: [
                  pw.Center(
                    child: pw.Image(pw.MemoryImage(pngBytes)),
                  ),
                  _buildWatermarkText(text, position, fontSize, color, opacity, rotation),
                ],
              );
            },
          ),
        );
      }

      final outputBytes = await pdf.save();
      document.dispose();

      final outputPath = await _getOutputPath(
          'watermarked_${DateTime.now().millisecondsSinceEpoch}.pdf');
      final outputFile = File(outputPath);
      await outputFile.writeAsBytes(outputBytes);

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
      final bytes = await pdfFile.readAsBytes();
      final document = await pdf_render.PdfDocument.openData(bytes);
      final watermarkBytes = await imageFile.readAsBytes();
      final pdf = pw.Document();

      for (int i = 1; i <= document.pageCount; i++) {
        final page = await document.getPage(i);
        final pageImage = await page.render(
          width: (page.width * 2.0).round(),
          height: (page.height * 2.0).round(),
        );
        
        final imageBytes = await pageImage.createImageIfNotAvailable();
        final byteData = await imageBytes.toByteData(format: ui.ImageByteFormat.png);
        final pngBytes = byteData!.buffer.asUint8List();
        
        pdf.addPage(
          pw.Page(
            pageFormat: pdf_package.PdfPageFormat.a4,
            build: (pw.Context context) {
              return pw.Stack(
                children: [
                  pw.Center(
                    child: pw.Image(pw.MemoryImage(pngBytes)),
                  ),
                  _buildWatermarkImage(watermarkBytes, position, opacity),
                ],
              );
            },
          ),
        );
      }

      final outputBytes = await pdf.save();
      document.dispose();

      final outputPath = await _getOutputPath(
          'watermarked_${DateTime.now().millisecondsSinceEpoch}.pdf');
      final outputFile = File(outputPath);
      await outputFile.writeAsBytes(outputBytes);

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
      final document =
          await pdf_render.PdfDocument.openData(await pdfFile.readAsBytes());
      final List<File> imageFiles = [];

      final pagesToConvert =
          pageNumbers ?? List.generate(document.pageCount, (i) => i + 1);

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
          ui.ImageByteFormat imageFormat;
          switch (format.toLowerCase()) {
            case 'jpeg':
            case 'jpg':
              imageFormat = ui.ImageByteFormat.rawRgba;
              break;
            default:
              imageFormat = ui.ImageByteFormat.png;
          }
          
          final byteData = await imageBytes.toByteData(format: imageFormat);
          var bytes = byteData!.buffer.asUint8List();

          // Apply JPEG compression if needed
          if (format.toLowerCase() == 'jpeg' || format.toLowerCase() == 'jpg') {
            final image = img.decodeImage(bytes);
            if (image != null) {
              bytes = Uint8List.fromList(img.encodeJpg(image, quality: (quality * 100).round()));
            }
          }

          // Save image file
          final outputPath = await _getOutputPath(
              'page_${pageNum}_${DateTime.now().millisecondsSinceEpoch}.$format');
          final outputFile = File(outputPath);
          await outputFile.writeAsBytes(bytes);
          imageFiles.add(outputFile);
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
      final imageFiles =
          await convertPDFToImages(pdfFile, pageNumbers: pageNumbers);
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
          final processedBytes =
              Uint8List.fromList(img.encodePng(grayscaleImage));
          final processedPath = await _getOutputPath(
              'processed_${DateTime.now().millisecondsSinceEpoch}_${processedImageFiles.length}.png');
          final processedFile = File(processedPath);
          await processedFile.writeAsBytes(processedBytes);
          processedImageFiles.add(processedFile);
        }

        // Clean up original image file
        await imageFile.delete();
      }

      // Convert processed images back to PDF
      final outputFile = await createPDFFromImages(processedImageFiles,
          outputName: 'grayscale_${DateTime.now().millisecondsSinceEpoch}.pdf');

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

  pw.Widget _buildWatermarkText(String text, String position, double fontSize, 
      Color color, double opacity, double rotation) {
    double x = 0, y = 0;
    
    switch (position) {
      case 'center':
        x = 0.5;
        y = 0.5;
        break;
      case 'top-left':
        x = 0.1;
        y = 0.1;
        break;
      case 'top-right':
        x = 0.9;
        y = 0.1;
        break;
      case 'bottom-left':
        x = 0.1;
        y = 0.9;
        break;
      case 'bottom-right':
        x = 0.9;
        y = 0.9;
        break;
    }

    return pw.Positioned(
      left: x * 500, // Approximate page width
      top: y * 700,  // Approximate page height
      child: pw.Transform.rotate(
        angle: rotation * 3.14159 / 180,
        child: pw.Opacity(
          opacity: opacity,
          child: pw.Text(
            text,
            style: pw.TextStyle(
              fontSize: fontSize,
              color: pdf_package.PdfColor(
                color.red / 255.0,
                color.green / 255.0,
                color.blue / 255.0,
              ),
            ),
          ),
        ),
      ),
    );
  }

  pw.Widget _buildWatermarkImage(Uint8List imageBytes, String position, double opacity) {
    double x = 0, y = 0;
    
    switch (position) {
      case 'center':
        x = 0.5;
        y = 0.5;
        break;
      case 'top-left':
        x = 0.1;
        y = 0.1;
        break;
      case 'top-right':
        x = 0.9;
        y = 0.1;
        break;
      case 'bottom-left':
        x = 0.1;
        y = 0.9;
        break;
      case 'bottom-right':
        x = 0.9;
        y = 0.9;
        break;
    }

    return pw.Positioned(
      left: x * 500,
      top: y * 700,
      child: pw.Opacity(
        opacity: opacity,
        child: pw.Container(
          width: 100,
          height: 100,
          child: pw.Image(pw.MemoryImage(imageBytes)),
        ),
      ),
    );
  }

  img.Image _applyThreshold(img.Image image, double threshold) {
    final int thresholdValue = (threshold * 255).round();
    final img.Image result = img.Image.from(image);

    for (int y = 0; y < result.height; y++) {
      for (int x = 0; x < result.width; x++) {
        final pixel = result.getPixel(x, y);
        final gray = img.getLuminance(pixel);
        final newValue = gray > thresholdValue ? 255 : 0;
        result.setPixel(
            x, y, img.ColorRgba8(newValue, newValue, newValue, 255));
      }
    }

    return result;
  }
}

// Enum to replace Syncfusion's PdfPageRotateAngle
enum RotationAngle {
  rotate0(0),
  rotate90(90),
  rotate180(180),
  rotate270(270);

  const RotationAngle(this.degrees);
  final int degrees;
}

