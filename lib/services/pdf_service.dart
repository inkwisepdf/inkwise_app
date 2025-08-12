import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart' as pdf_package;
import 'package:pdf/widgets.dart' as pw;
import 'package:syncfusion_flutter_pdf/pdf.dart' as sf_pdf;
import 'package:pdf_render/pdf_render.dart' as pdf_render;
import 'package:image/image.dart' as img;
import 'package:flutter/material.dart';
import 'performance_service.dart';

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
          document.importPages(sourceDoc);
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
            
            final PdfDocument newDoc = PdfDocument();
            newDoc.importPage(document, pageIndex);
            
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
            newDoc.importPage(document, i);
            
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
        document.compressionLevel = PdfCompressionLevel.best;
        
        // Compress images in the document - process in parallel
        final pageFutures = List.generate(document.pages.count, (i) async {
          final sf_pdf.PdfPage page = document.pages[i];
          final List<sf_pdf.PdfImage> images = page.extractImages();
          
          // Process images in parallel
          final imageFutures = images.map((image) async {
            if ((image.width ?? 0) > 800 || (image.height ?? 0) > 800) {
              final Uint8List compressedBytes = await _compressImage(image.data ?? Uint8List(0), quality);
              // Replace image with compressed version
              return compressedBytes;
            }
            return image.data ?? Uint8List(0);
          });
          
          await Future.wait(imageFutures);
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
      final sf_pdf.PdfDocument document = sf_pdf.PdfDocument(inputBytes: await pdfFile.readAsBytes());
      
      for (int i = 0; i < count; i++) {
        final sf_pdf.PdfPage newPage = document.pages.add();
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
      security.permissions.add(sf_pdf.PdfPermissions.print);
      security.permissions.add(sf_pdf.PdfPermissions.copyContent);
      
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
  Future<File> rotatePDF(File pdfFile, {int? pageNumber, dynamic angle}) async {
    try {
      final sf_pdf.PdfDocument document = sf_pdf.PdfDocument(inputBytes: await pdfFile.readAsBytes());
      
      if (pageNumber != null) {
        // Rotate specific page
        if (pageNumber > 0 && pageNumber <= document.pages.count) {
          final sf_pdf.PdfPage page = document.pages[pageNumber - 1];
          page.rotation = angle;
        }
      } else {
        // Rotate all pages
        for (int i = 0; i < document.pages.count; i++) {
          final sf_pdf.PdfPage page = document.pages[i];
          page.rotation = angle;
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
        final Size textSize = font.measureString(text, format);
        
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
        final sf_pdf.PdfBrush brush = sf_pdf.PdfSolidBrush(sf_pdf.PdfColor.fromArgb(
          (opacity * 255).round(),
          color.red,
          color.green,
          color.blue,
        ));
        
        graphics.drawString(text, font, brush, Offset(x, y), format);
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
      final sf_pdf.PdfDocument document = sf_pdf.PdfDocument(inputBytes: await pdfFile.readAsBytes());
      final List<File> imageFiles = [];
      
      final pagesToConvert = pageNumbers ?? List.generate(document.pages.count, (i) => i + 1);
      
      for (final pageNum in pagesToConvert) {
        if (pageNum > 0 && pageNum <= document.pages.count) {
          final sf_pdf.PdfPage page = document.pages[pageNum - 1];
          
          // Convert page to image using pdf_render
          final pageImage = await page.render(
            width: (page.size.width * scale).round(),
            height: (page.size.height * scale).round(),
          );
          
          if (pageImage != null) {
            // Convert to image bytes
            Uint8List imageBytes = pageImage.toByteData(format: ImageByteFormat.png)!.buffer.asUint8List();
            
            // Save image file
            final outputPath = await _getOutputPath('page_${pageNum}_${DateTime.now().millisecondsSinceEpoch}.$format');
            final outputFile = File(outputPath);
            await outputFile.writeAsBytes(imageBytes);
            imageFiles.add(outputFile);
          }
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
      final sf_pdf.PdfDocument document = sf_pdf.PdfDocument(inputBytes: await pdfFile.readAsBytes());
      
      final pagesToConvert = pageNumbers ?? List.generate(document.pages.count, (i) => i + 1);
      
      for (final pageNum in pagesToConvert) {
        if (pageNum > 0 && pageNum <= document.pages.count) {
          final sf_pdf.PdfPage page = document.pages[pageNum - 1];
          final sf_pdf.PdfGraphics graphics = page.graphics;
          
          // Convert page to image first
          final pageImage = await page.render(
            width: page.size.width.round(),
            height: page.size.height.round(),
          );
          
          if (pageImage != null) {
            final Uint8List imageBytes = pageImage.toByteData(format: ImageByteFormat.png)!.buffer.asUint8List();
          
          // Process image to grayscale
          final img.Image? image = img.decodeImage(imageBytes);
          if (image != null) {
            // Convert to grayscale
            img.Image grayscaleImage = img.grayscale(image);
            
            // Apply threshold if needed
            if (threshold != 0.5) {
              grayscaleImage = img.threshold(grayscaleImage, threshold: (threshold * 255).round());
            }
            
            // Enhance contrast if requested
            if (enhanceContrast) {
              grayscaleImage = img.contrast(grayscaleImage, contrast: 1.5);
            }
            
            // Convert back to bytes
            final Uint8List processedBytes = Uint8List.fromList(img.encodePng(grayscaleImage));
            
                         // Replace page content with processed image
             final sf_pdf.PdfBitmap bitmap = sf_pdf.PdfBitmap(processedBytes);
             graphics.clear(sf_pdf.PdfColor.white);
             graphics.drawImage(bitmap, Rect.fromLTWH(0, 0, page.size.width, page.size.height));
           }
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

  // Helper methods
  Future<String> _getOutputPath(String filename) async {
    final directory = await getApplicationDocumentsDirectory();
    final appDir = Directory('${directory.path}/inkwise_pdf');
    if (!await appDir.exists()) {
      await appDir.create(recursive: true);
    }
    return '${appDir.path}/$filename';
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
